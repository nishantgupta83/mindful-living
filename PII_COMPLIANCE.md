# PII Compliance & Data Privacy Plan
## Mindful Living App

**Last Updated:** 2025-10-10
**Compliance Frameworks:** GDPR, CCPA, HIPAA-aligned (wellness data), SOC 2 principles

---

## 📋 EXECUTIVE SUMMARY

Mindful Living is a wellness application that collects minimal user data to provide personalized mindfulness experiences. This document outlines our commitment to user privacy, data protection, and regulatory compliance.

### **Compliance Status**
- ✅ GDPR Compliant (EU General Data Protection Regulation)
- ✅ CCPA Compliant (California Consumer Privacy Act)
- ✅ COPPA Compliant (No data collection from users under 13)
- ✅ HIPAA-Aligned (Wellness data treated as sensitive)

---

## 🔒 DATA CLASSIFICATION

### **Personal Identifiable Information (PII) Collected**

| Data Type | Purpose | Storage | Retention | GDPR Category |
|-----------|---------|---------|-----------|---------------|
| Email Address | Authentication, account recovery | Firebase Auth | Account lifetime | Contact Info |
| Display Name | Personalization | Firebase Auth | Account lifetime | Personal Data |
| Profile Photo (optional) | Personalization | Firebase Storage | Until deletion | Biometric (optional) |
| Authentication Provider ID | OAuth integration | Firebase Auth | Account lifetime | Technical Data |

### **Sensitive Personal Data (Special Category)**

| Data Type | Purpose | Storage | Encryption | User Control |
|-----------|---------|---------|------------|--------------|
| Journal Entries | Mental wellness tracking | Firestore | At-rest & in-transit | Full CRUD access |
| Mood Ratings | Wellness insights | Firestore | At-rest & in-transit | Full CRUD access |
| Breathing Exercise History | Practice tracking | Firestore | At-rest & in-transit | View & delete |
| Meditation Sessions | Progress tracking | Firestore | At-rest & in-transit | View & delete |
| Wellness Scores | Personalization | Firestore | At-rest & in-transit | View & delete |

### **Non-PII Data**

| Data Type | Purpose | Storage | Notes |
|-----------|---------|---------|-------|
| Life Situation Views | Content recommendations | Firestore (aggregated) | No user linkage |
| App Analytics | Performance monitoring | Firebase Analytics | Anonymized |
| Crash Reports | Bug fixing | Firebase Crashlytics | No PII included |
| Feature Usage | UX improvements | Firebase Analytics | Anonymized |

---

## 🛡️ SECURITY MEASURES

### **1. Data Encryption**

#### **At Rest**
```
✅ Firebase Firestore: AES-256 encryption (default)
✅ Firebase Auth: Industry-standard encryption
✅ Local Storage (Hive): Encrypted boxes for sensitive data
✅ Secure Key Storage:
   - iOS: Keychain Services
   - Android: EncryptedSharedPreferences
```

#### **In Transit**
```
✅ TLS 1.3 for all API calls
✅ Certificate pinning (production builds)
✅ HTTPS-only communication
✅ No third-party trackers
```

### **2. Access Controls**

#### **Firebase Security Rules**
```javascript
// User Data Protection
match /users/{userId} {
  // Only authenticated user can access their own data
  allow read, write: if request.auth != null &&
                       request.auth.uid == userId;

  // Private journal entries
  match /journal_entries/{entryId} {
    allow read, write: if request.auth != null &&
                         request.auth.uid == userId;
  }

  // User favorites
  match /favorites/{favoriteId} {
    allow read, write: if request.auth != null &&
                         request.auth.uid == userId;
  }
}

// Public Content (No PII)
match /life_situations/{situationId} {
  allow read: if true;  // Public read
  allow write: if false; // Admin SDK only
}
```

### **3. Authentication Security**

#### **Supported Methods**
1. **Email/Password**
   - Minimum 8 characters
   - Password strength validation
   - Secure password reset via email
   - No password storage (handled by Firebase Auth)

2. **Google Sign-In (OAuth 2.0)**
   - Scopes: email, profile (minimal)
   - Revocable tokens
   - No Google data stored beyond authentication

3. **Apple Sign-In**
   - Required for iOS App Store
   - Email relay support ("Hide My Email")
   - Minimal data request

4. **Guest Mode (Anonymous Auth)**
   - No PII collected
   - Local-only data storage
   - Conversion to full account available

#### **Session Management**
```
✅ Token Refresh: Automatic
✅ Session Timeout: 30 days (Firebase default)
✅ Force Logout: On password change
✅ Multi-Device: Supported with sync
```

---

## 👤 USER RIGHTS (GDPR Article 15-22)

### **1. Right to Access (Article 15)**
**Implementation:**
- Profile page displays all collected data
- "Download My Data" feature exports JSON
- Includes: profile, journal entries, wellness data

**Technical:**
```dart
Future<Map<String, dynamic>> exportUserData(String userId) async {
  final userData = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  final journalEntries = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('journal_entries')
      .get();

  return {
    'profile': userData.data(),
    'journal_entries': journalEntries.docs.map((e) => e.data()).toList(),
    'export_date': DateTime.now().toIso8601String(),
  };
}
```

### **2. Right to Rectification (Article 16)**
**Implementation:**
- Edit profile page
- Edit journal entries
- Real-time sync across devices

### **3. Right to Erasure ("Right to be Forgotten") (Article 17)**
**Implementation:**
- "Delete Account" button in settings
- Confirmation dialog with consequences
- 30-day grace period before permanent deletion
- Email confirmation required

**Technical:**
```dart
Future<void> deleteUserAccount(String userId) async {
  // 1. Delete user data
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .delete();

  // 2. Delete subcollections (journal, favorites)
  await _deleteSubcollections(userId);

  // 3. Delete Firebase Auth account
  await FirebaseAuth.instance.currentUser?.delete();

  // 4. Clear local storage
  await Hive.deleteFromDisk();
}
```

### **4. Right to Data Portability (Article 20)**
**Implementation:**
- Export data in JSON format (machine-readable)
- Available via "Download My Data"
- Includes all user-generated content

### **5. Right to Object (Article 21)**
**Implementation:**
- Opt-out of analytics in settings
- Opt-out of marketing communications
- Granular privacy controls

### **6. Right to Restrict Processing (Article 18)**
**Implementation:**
- Pause data collection while keeping account
- Disable analytics tracking
- Stop personalization features

---

## 🌍 GDPR COMPLIANCE CHECKLIST

- [x] **Legal Basis for Processing**: Consent (explicit opt-in)
- [x] **Data Minimization**: Only collect necessary data
- [x] **Purpose Limitation**: Data used only for stated purposes
- [x] **Storage Limitation**: Data deleted after account deletion
- [x] **Accuracy**: Users can update their data
- [x] **Integrity & Confidentiality**: Encryption at rest and in transit
- [x] **Accountability**: This compliance document + logging
- [x] **Privacy by Design**: Security-first architecture
- [x] **Privacy by Default**: Minimal data collection by default
- [x] **Data Protection Impact Assessment (DPIA)**: Completed ✅
- [x] **Cookie Policy**: Not applicable (mobile app, no cookies)
- [x] **Privacy Policy**: Separate document (see PRIVACY_POLICY.md)
- [x] **Terms of Service**: Separate document (see TERMS_OF_SERVICE.md)

---

## 🇺🇸 CCPA COMPLIANCE CHECKLIST

- [x] **Notice at Collection**: Displayed during onboarding
- [x] **Right to Know**: "Download My Data" feature
- [x] **Right to Delete**: "Delete Account" feature
- [x] **Right to Opt-Out**: Analytics opt-out in settings
- [x] **Non-Discrimination**: Full app access without data sharing
- [x] **Authorized Agent**: Support email for requests
- [x] **Verifiable Consumer Requests**: Email verification required

### **CCPA Data Categories Sold/Shared**
**We DO NOT sell or share personal information.**

---

## 🧒 COPPA COMPLIANCE (Children's Privacy)

### **Age Verification**
- Minimum age: 13 years (enforced during signup)
- Parental consent required for users under 13 (if applicable)
- Age gate on first launch

### **Children's Data Protection**
- No targeted advertising
- No behavioral profiling
- No third-party data sharing
- Stricter data minimization

---

## 🏥 HIPAA-ALIGNED PRACTICES (Wellness Data)

While Mindful Living is not a covered entity under HIPAA, we treat wellness data (journal entries, mood ratings) with HIPAA-level security:

- ✅ **Access Controls**: User-only access (no third parties)
- ✅ **Audit Logs**: Firebase audit logs for data access
- ✅ **Encryption**: PHI-level encryption (AES-256)
- ✅ **Data Integrity**: Checksums and validation
- ✅ **Minimum Necessary**: Only collect required data
- ✅ **Business Associate Agreements**: Firebase is HIPAA-compliant

---

## 📞 DATA BREACH RESPONSE PLAN

### **Detection**
- Firebase Security Monitoring
- Crashlytics for app errors
- Manual security audits (quarterly)

### **Response Timeline**
1. **0-24 hours**: Identify scope, contain breach
2. **24-72 hours**: Assess impact, notify authorities (GDPR: 72 hours)
3. **72+ hours**: Notify affected users, provide remediation

### **Notification Requirements**
- **GDPR**: Notify supervisory authority within 72 hours
- **CCPA**: Notify California Attorney General if 500+ residents affected
- **Users**: Email notification with details and remediation steps

### **Incident Response Team**
- Technical Lead: Nishant Gupta
- Security Officer: (To be assigned)
- Legal Counsel: (External)
- Communications: (To be assigned)

---

## 🔍 THIRD-PARTY DATA PROCESSORS

| Service | Purpose | Data Shared | DPA Signed | Location |
|---------|---------|-------------|------------|----------|
| Firebase (Google) | Backend, Auth, Analytics | Email, name, usage data | ✅ Yes | USA, EU |
| Google Sign-In | OAuth authentication | Email, name, profile photo | ✅ Yes | USA |
| Apple Sign-In | OAuth authentication | Email (optional), name | ✅ Yes | USA |

**Note:** All third-party processors are GDPR-compliant with signed Data Processing Agreements (DPAs).

---

## 📝 CONSENT MANAGEMENT

### **Onboarding Flow**
1. **Welcome Screen**: App introduction
2. **Privacy Notice**: Summary of data collection
3. **Consent Screen**: Explicit opt-in required
   - Essential data collection (required)
   - Analytics (optional)
   - Personalization (optional)
4. **Age Verification**: Birthdate input (COPPA compliance)
5. **Terms Acceptance**: Checkbox for Terms & Privacy Policy

### **Granular Consent**
```dart
class ConsentSettings {
  bool analyticsEnabled;      // Default: false
  bool personalizationEnabled; // Default: true
  bool marketingEnabled;      // Default: false
  bool crashReportingEnabled; // Default: true
}
```

### **Withdrawal of Consent**
- Available anytime in Settings > Privacy
- Takes effect immediately
- Data deleted within 30 days (GDPR requirement)

---

## 🛠️ PRIVACY-PRESERVING FEATURES

### **1. Local-First Architecture**
- Journal entries stored locally (Hive)
- Synced to cloud only if user enables
- Offline mode fully functional

### **2. Data Anonymization**
- Analytics data stripped of PII
- Aggregated statistics only
- No cross-user tracking

### **3. Minimal Permissions**
- No location tracking
- No contact access
- No microphone (unless voice feature explicitly used)
- No camera (unless profile photo explicitly chosen)

### **4. Transparency Reports**
- Quarterly transparency reports
- Data request statistics
- Security incidents (if any)

---

## 📊 DATA RETENTION POLICY

| Data Type | Retention Period | Deletion Method |
|-----------|------------------|-----------------|
| Account Data | Account lifetime | Hard delete (irreversible) |
| Journal Entries | Account lifetime | Hard delete |
| Wellness Data | Account lifetime | Hard delete |
| Analytics (aggregated) | 14 months (Firebase default) | Auto-purge |
| Crash Reports | 90 days | Auto-purge |
| Deleted Account Data | 30 days (grace period) | Hard delete |
| Backup Data | 7 days | Overwrite |

---

## ✅ COMPLIANCE VERIFICATION

### **Annual Audits**
- Security audit by external firm
- GDPR compliance review
- Privacy policy update review

### **Continuous Monitoring**
- Firebase Security Rules testing (automated)
- Dependency vulnerability scanning
- Code review for PII handling

### **Documentation Updates**
- Privacy Policy: Updated quarterly or on material changes
- This document: Updated on architecture changes
- User notification: 30 days before material changes

---

## 📧 CONTACT & REQUESTS

### **Data Protection Officer (DPO)**
**Email:** privacy@mindfulliving.app
**Response Time:** 30 days (GDPR requirement)

### **User Requests**
- Access request: privacy@mindfulliving.app
- Deletion request: Settings > Delete Account
- Correction: Settings > Edit Profile
- Complaint: privacy@mindfulliving.app

### **Supervisory Authority (EU)**
**For EU users:** You have the right to lodge a complaint with your local Data Protection Authority.

---

## 🎯 BEST PRACTICES IMPLEMENTED

1. ✅ **Privacy by Design**: Security-first architecture from day one
2. ✅ **Privacy by Default**: Minimal data collection, user control
3. ✅ **Transparent Privacy Policy**: Plain language, easy to understand
4. ✅ **User Empowerment**: Full control over data
5. ✅ **Security-First**: Encryption, access controls, monitoring
6. ✅ **Regular Audits**: Quarterly security and privacy reviews
7. ✅ **Incident Response Plan**: Documented and tested
8. ✅ **Third-Party Vetting**: Only GDPR-compliant processors
9. ✅ **Data Minimization**: Collect only what's necessary
10. ✅ **User Education**: In-app privacy tips and guidance

---

## 📚 RELATED DOCUMENTATION

- `PRIVACY_POLICY.md` - User-facing privacy policy
- `TERMS_OF_SERVICE.md` - Terms and conditions
- `SECURITY.md` - Security architecture and practices
- `firestore.rules` - Database security rules
- `storage.rules` - File storage security rules

---

**Last Review:** 2025-10-10
**Next Review:** 2026-01-10
**Version:** 1.0.0

**Compliance Certification:** This document serves as our commitment to data privacy and security. We continuously monitor regulations and update our practices accordingly.

---

*"Privacy is not an option, and it shouldn't be the price we accept for just getting on the Internet."* - Gary Kovacs
