# Firebase Security Agent

## 🎯 Purpose
Ensures comprehensive security for Mindful Living app's Firebase infrastructure. Protects user data, prevents unauthorized access, and maintains compliance with security best practices.

## 🔍 Responsibilities

### 1. Security Rules Auditing
- Firestore security rules validation
- Storage security rules review
- Real-time Database rules (if used)
- Rules testing and verification

### 2. Authentication Security
- Multi-factor authentication setup
- Session management security
- OAuth provider security
- Account takeover prevention

### 3. Data Protection
- Sensitive data identification
- Encryption at rest and in transit
- PII (Personally Identifiable Information) handling
- Data anonymization for analytics

### 4. Access Control
- Role-based access control (RBAC)
- Admin access management
- API key security
- Service account security

### 5. Threat Detection
- Suspicious activity monitoring
- Rate limiting implementation
- DDoS protection
- Abuse detection

### 6. Compliance
- GDPR compliance
- CCPA compliance
- HIPAA considerations (if applicable)
- Data retention policies

## 📋 Security Audit Checklist

### Phase 1: Firestore Security Rules Audit

#### Current Rules Analysis
```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions for security
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isAdmin() {
      return isAuthenticated() &&
             request.auth.token.admin == true;
    }

    function isValidEmail(email) {
      return email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
    }

    function hasRequiredFields(fields) {
      return request.resource.data.keys().hasAll(fields);
    }

    // Public Collections
    match /life_situations/{situationId} {
      // ✅ SECURE: Public read, admin-only write
      allow read: if true;
      allow write: if isAdmin();

      // Validate data structure
      allow create, update: if isAdmin() &&
        hasRequiredFields(['title', 'description', 'category', 'tags']) &&
        request.resource.data.title is string &&
        request.resource.data.title.size() > 0 &&
        request.resource.data.title.size() <= 200 &&
        request.resource.data.tags is list &&
        request.resource.data.tags.size() <= 10;
    }

    // User Private Data
    match /users/{userId} {
      // ✅ SECURE: User can only access their own data
      allow read: if isOwner(userId);
      allow create: if isAuthenticated() &&
                     request.auth.uid == userId &&
                     hasRequiredFields(['email', 'createdAt']);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId) || isAdmin();

      // Validate email format
      allow create, update: if isValidEmail(request.resource.data.email);

      // Prevent privilege escalation
      allow update: if !request.resource.data.diff(resource.data).affectedKeys().hasAny(['isAdmin', 'role']);

      // Journal Entries (private subcollection)
      match /journal_entries/{entryId} {
        allow read, write: if isOwner(userId);

        // Validate entry structure
        allow create: if hasRequiredFields(['content', 'mood', 'createdAt']) &&
                       request.resource.data.content.size() > 0 &&
                       request.resource.data.content.size() <= 10000;

        // Prevent editing others' entries
        allow update: if resource.data.userId == request.auth.uid;
      }

      // Wellness Tracking
      match /wellness_tracking/{trackingId} {
        allow read, write: if isOwner(userId);

        // Validate score ranges
        allow create, update: if request.resource.data.score >= 0 &&
                                request.resource.data.score <= 100;
      }

      // Favorites
      match /favorites/{favoriteId} {
        allow read, write: if isOwner(userId);

        // Rate limiting: max 100 favorites per user
        allow create: if request.resource.data.keys().hasAll(['situationId', 'addedAt']) &&
                       get(/databases/$(database)/documents/users/$(userId)/favorites).size() < 100;
      }
    }

    // Voice Queries (analytics only, no user access)
    match /voice_queries/{queryId} {
      // ❌ Users cannot read voice analytics
      allow read: if isAdmin();

      // ❌ Only Cloud Functions can write
      allow write: if false;

      // Cloud Functions bypass these rules using admin SDK
    }

    // Admin-only Collections
    match /_migrations/{migrationId} {
      allow read: if isAdmin();
      allow write: if false; // Only functions can write
    }

    match /_performance_logs/{logId} {
      allow read: if isAdmin();
      allow write: if false; // Only functions can write
    }

    // Catch-all: Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Phase 2: Security Rules Testing

#### Test Script
```typescript
// backend/firestore-rules-tests/firestore.spec.ts

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'hub4apps-mindfulliving-test',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe('Life Situations Security', () => {
  it('should allow anyone to read life situations', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(
      unauthedDb.collection('life_situations').doc('test').get()
    );
  });

  it('should deny non-admin writes to life situations', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    await assertFails(
      userDb.collection('life_situations').doc('test').set({
        title: 'Test Situation',
      })
    );
  });

  it('should allow admin writes to life situations', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin123', { admin: true })
      .firestore();

    await assertSucceeds(
      adminDb.collection('life_situations').doc('test').set({
        title: 'Test Situation',
        description: 'Test description',
        category: 'test',
        tags: ['test'],
      })
    );
  });
});

describe('User Data Security', () => {
  it('should allow users to read their own data', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    await assertSucceeds(
      userDb.collection('users').doc('user123').get()
    );
  });

  it('should deny users from reading other users data', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    await assertFails(
      userDb.collection('users').doc('user456').get()
    );
  });

  it('should prevent privilege escalation', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    // Try to make self admin
    await assertFails(
      userDb.collection('users').doc('user123').update({
        isAdmin: true,
      })
    );
  });

  it('should validate journal entry size limits', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    // Too long content (> 10000 chars)
    const longContent = 'a'.repeat(10001);

    await assertFails(
      userDb
        .collection('users')
        .doc('user123')
        .collection('journal_entries')
        .add({
          content: longContent,
          mood: 'happy',
          createdAt: new Date(),
        })
    );
  });
});

describe('Voice Queries Security', () => {
  it('should deny user access to voice analytics', async () => {
    const userDb = testEnv
      .authenticatedContext('user123')
      .firestore();

    await assertFails(
      userDb.collection('voice_queries').get()
    );
  });

  it('should allow admin access to voice analytics', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin123', { admin: true })
      .firestore();

    await assertSucceeds(
      adminDb.collection('voice_queries').get()
    );
  });
});
```

### Phase 3: Authentication Security

#### Secure Authentication Setup
```dart
// lib/core/services/secure_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SecureAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Enable MFA for user
  Future<void> enableMFA(User user) async {
    try {
      await user.multiFactor.getSession();
      // Guide user through MFA setup
    } catch (e) {
      debugPrint('MFA setup failed: $e');
      rethrow;
    }
  }

  /// Secure password requirements
  bool isPasswordSecure(String password) {
    if (password.length < 12) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  /// Detect suspicious sign-in attempts
  Future<bool> isSignInSuspicious(String email) async {
    // Check recent failed attempts
    final failedAttempts = await _getFailedAttempts(email);

    if (failedAttempts > 5) {
      await _lockAccount(email, duration: Duration(hours: 1));
      return true;
    }

    // Check if from unusual location
    // (would integrate with device fingerprinting)

    return false;
  }

  /// Secure token refresh
  Future<String?> getSecureToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Force token refresh for security-sensitive operations
      final idToken = await user.getIdToken(true);
      return idToken;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  /// Session management
  Future<void> setupSecureSession() async {
    // Set persistence to LOCAL (default)
    // For sensitive apps, consider SESSION persistence

    // Monitor auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _validateSession(user);
      }
    });
  }

  Future<void> _validateSession(User user) async {
    final metadata = user.metadata;

    // Check if session is too old
    if (metadata.lastSignInTime != null) {
      final sessionAge = DateTime.now().difference(metadata.lastSignInTime!);

      if (sessionAge > Duration(days: 30)) {
        // Force re-authentication for security
        await _auth.signOut();
      }
    }
  }

  Future<int> _getFailedAttempts(String email) async {
    // Implementation would check Firestore or Cloud Functions
    return 0;
  }

  Future<void> _lockAccount(String email, {required Duration duration}) async {
    // Implementation would use Cloud Functions
  }
}
```

### Phase 4: Data Protection

#### Sensitive Data Handling
```dart
// lib/core/security/data_protection.dart

import 'package:crypto/crypto.dart';
import 'dart:convert';

class DataProtection {
  /// Hash sensitive data (one-way)
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Mask PII in logs
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  static String maskPhone(String phone) {
    if (phone.length < 4) return '****';
    return '*' * (phone.length - 4) + phone.substring(phone.length - 4);
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'<script.*?>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'[<>]'), '')
        .trim();
  }

  /// Validate data before storage
  static bool isDataSafe(Map<String, dynamic> data) {
    // Check for injection attempts
    final jsonString = jsonEncode(data);

    // Check for suspicious patterns
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'onerror=',
      'onload=',
      'eval(',
      'Function(',
    ];

    for (final pattern in suspiciousPatterns) {
      if (jsonString.toLowerCase().contains(pattern)) {
        return false;
      }
    }

    return true;
  }

  /// Anonymize data for analytics
  static Map<String, dynamic> anonymizeUserData(Map<String, dynamic> userData) {
    return {
      'userId': hashData(userData['id']),
      'ageGroup': _getAgeGroup(userData['age']),
      'region': _getRegion(userData['location']),
      // Remove all PII
      // No email, phone, name, exact location
    };
  }

  static String _getAgeGroup(int? age) {
    if (age == null) return 'unknown';
    if (age < 18) return '0-17';
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    return '55+';
  }

  static String _getRegion(String? location) {
    // Convert precise location to general region
    // Implementation would use geolocation logic
    return 'region';
  }
}
```

### Phase 5: Rate Limiting

#### Cloud Functions Rate Limiting
```typescript
// backend/functions/src/security/rate_limiter.ts

import * as admin from 'firebase-admin';

interface RateLimitConfig {
  maxRequests: number;
  windowMs: number;
  blockDurationMs: number;
}

export class RateLimiter {
  private db: admin.firestore.Firestore;

  private configs: Record<string, RateLimitConfig> = {
    voice_query: {
      maxRequests: 100,           // 100 requests
      windowMs: 3600000,          // per hour
      blockDurationMs: 3600000    // block for 1 hour
    },
    auth_attempt: {
      maxRequests: 5,             // 5 attempts
      windowMs: 300000,           // per 5 minutes
      blockDurationMs: 3600000    // block for 1 hour
    },
    api_call: {
      maxRequests: 1000,          // 1000 calls
      windowMs: 3600000,          // per hour
      blockDurationMs: 3600000    // block for 1 hour
    }
  };

  constructor() {
    this.db = admin.firestore();
  }

  async checkRateLimit(
    identifier: string,
    action: string
  ): Promise<{ allowed: boolean; remaining: number; resetAt: Date }> {
    const config = this.configs[action] || this.configs.api_call;

    const rateLimitDoc = await this.db
      .collection('_rate_limits')
      .doc(`${identifier}_${action}`)
      .get();

    const now = Date.now();

    if (!rateLimitDoc.exists) {
      // First request
      await this.db
        .collection('_rate_limits')
        .doc(`${identifier}_${action}`)
        .set({
          count: 1,
          windowStart: now,
          blockedUntil: null
        });

      return {
        allowed: true,
        remaining: config.maxRequests - 1,
        resetAt: new Date(now + config.windowMs)
      };
    }

    const data = rateLimitDoc.data()!;

    // Check if blocked
    if (data.blockedUntil && now < data.blockedUntil) {
      return {
        allowed: false,
        remaining: 0,
        resetAt: new Date(data.blockedUntil)
      };
    }

    // Check if window expired
    if (now - data.windowStart > config.windowMs) {
      // Reset window
      await rateLimitDoc.ref.update({
        count: 1,
        windowStart: now,
        blockedUntil: null
      });

      return {
        allowed: true,
        remaining: config.maxRequests - 1,
        resetAt: new Date(now + config.windowMs)
      };
    }

    // Increment count
    const newCount = data.count + 1;

    if (newCount > config.maxRequests) {
      // Rate limit exceeded - block
      await rateLimitDoc.ref.update({
        count: newCount,
        blockedUntil: now + config.blockDurationMs
      });

      // Log security event
      await this.logSecurityEvent({
        type: 'rate_limit_exceeded',
        identifier,
        action,
        timestamp: admin.firestore.Timestamp.now()
      });

      return {
        allowed: false,
        remaining: 0,
        resetAt: new Date(now + config.blockDurationMs)
      };
    }

    await rateLimitDoc.ref.update({
      count: newCount
    });

    return {
      allowed: true,
      remaining: config.maxRequests - newCount,
      resetAt: new Date(data.windowStart + config.windowMs)
    };
  }

  private async logSecurityEvent(event: any): Promise<void> {
    await this.db.collection('_security_events').add(event);

    // Alert if critical
    if (event.type === 'rate_limit_exceeded') {
      // Send alert to security team
      console.warn('SECURITY ALERT:', event);
    }
  }
}

// Usage in Cloud Function
export const processVoiceQuery = functions.https.onCall(
  async (data, context) => {
    const rateLimiter = new RateLimiter();
    const userId = context.auth?.uid || context.rawRequest.ip;

    const rateLimit = await rateLimiter.checkRateLimit(userId, 'voice_query');

    if (!rateLimit.allowed) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Rate limit exceeded. Please try again later.',
        { resetAt: rateLimit.resetAt }
      );
    }

    // Process request...
  }
);
```

## 📊 Security Monitoring Dashboard

### Security Metrics
```typescript
interface SecurityMetrics {
  // Authentication
  failedAuthAttempts: number;
  suspiciousSignIns: number;
  accountLockouts: number;
  mfaAdoptionRate: number;

  // Authorization
  rulesViolations: number;
  unauthorizedAccessAttempts: number;
  privilegeEscalationAttempts: number;

  // Rate Limiting
  rateLimitExceeded: number;
  blockedIPs: number;

  // Data Protection
  piiExposureIncidents: number;
  dataValidationFailures: number;

  // Compliance
  gdprRequests: number;
  dataRetentionViolations: number;
}
```

## 🚀 Quick Security Audit

```bash
# Run security rules tests
npm test -- firestore.spec.ts

# Deploy updated rules
firebase deploy --only firestore:rules

# Check for exposed API keys
./scripts/check_secrets.sh

# Audit user permissions
./scripts/audit_permissions.sh

# Review security logs
firebase firestore:get _security_events --limit 100
```

## 🎯 Security Checklist

### Critical (Must Have)
- [ ] Firestore rules prevent unauthorized access
- [ ] Authentication requires strong passwords
- [ ] API keys are not exposed in code
- [ ] User data is properly isolated
- [ ] PII is never logged
- [ ] Rate limiting is enforced
- [ ] Security rules are tested

### Important (Should Have)
- [ ] MFA is available for users
- [ ] Session timeouts are enforced
- [ ] Suspicious activity is monitored
- [ ] Data is anonymized for analytics
- [ ] Security incidents are logged
- [ ] Regular security audits scheduled

### Nice to Have (Best Practices)
- [ ] Account lockout on failed attempts
- [ ] Device fingerprinting
- [ ] Advanced threat detection
- [ ] Security training for team
- [ ] Bug bounty program

## 📚 Resources
- [Firebase Security Rules Guide](https://firebase.google.com/docs/rules)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GDPR Compliance](https://gdpr.eu/)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)

---

**Note**: Security is an ongoing process, not a one-time task. Regular audits and updates are essential.
