# Firebase Performance Agent

## 🎯 Purpose
Monitors, analyzes, and optimizes Firebase services performance for Mindful Living app. Ensures fast, reliable, and cost-effective Firebase operations.

## 🔍 Responsibilities

### 1. Firestore Performance
- Query optimization and indexing
- Read/write operation monitoring
- Document structure optimization
- Subcollection usage patterns
- Real-time listener efficiency

### 2. Firebase Functions Performance
- Execution time monitoring
- Cold start optimization
- Memory usage tracking
- Concurrent execution limits
- Cost optimization

### 3. Firebase Storage Performance
- Upload/download speed
- File size optimization
- CDN effectiveness
- Cache hit rates

### 4. Firebase Auth Performance
- Authentication latency
- Token refresh efficiency
- Provider performance comparison

### 5. Cost Optimization
- Operation cost analysis
- Usage pattern optimization
- Budget alert configuration
- Resource allocation tuning

## 📋 Monitoring Setup

### Phase 1: Firebase Performance Monitoring SDK

#### Flutter Integration
```dart
// lib/core/services/firebase_performance_service.dart

import 'package:firebase_performance/firebase_performance.dart';

class FirebasePerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Track custom trace
  static Future<T> traceOperation<T>({
    required String name,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    final trace = _performance.newTrace(name);
    await trace.start();

    if (attributes != null) {
      attributes.forEach((key, value) {
        trace.putAttribute(key, value);
      });
    }

    try {
      final result = await operation();
      return result;
    } catch (error) {
      trace.putAttribute('error', error.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track network request
  static HttpMetric createHttpMetric(String url, HttpMethod method) {
    return _performance.newHttpMetric(url, method);
  }

  /// Track screen rendering
  static Future<void> trackScreenRender(String screenName) async {
    final trace = _performance.newTrace('screen_$screenName');
    await trace.start();

    // Stop after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await trace.stop();
    });
  }
}

// Usage example
class LifeSituationsRepository {
  Future<List<LifeSituation>> fetchSituations() async {
    return FirebasePerformanceService.traceOperation(
      name: 'fetch_life_situations',
      attributes: {
        'collection': 'life_situations',
        'limit': '20',
      },
      operation: () async {
        // Firestore query
        final snapshot = await FirebaseFirestore.instance
            .collection('life_situations')
            .limit(20)
            .get();

        return snapshot.docs
            .map((doc) => LifeSituation.fromFirestore(doc))
            .toList();
      },
    );
  }
}
```

### Phase 2: Firestore Performance Monitoring

#### Query Performance Tracking
```typescript
// backend/functions/src/monitoring/firestore_monitor.ts

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface QueryMetrics {
  collectionPath: string;
  queryType: 'get' | 'list' | 'stream';
  documentsRead: number;
  executionTime: number;
  indexUsed: boolean;
  timestamp: admin.firestore.Timestamp;
}

export class FirestoreMonitor {
  private db: admin.firestore.Firestore;

  constructor() {
    this.db = admin.firestore();
  }

  /**
   * Wrap Firestore query with performance tracking
   */
  async trackQuery<T>(
    operation: () => Promise<T>,
    metadata: {
      collection: string;
      queryType: 'get' | 'list' | 'stream';
    }
  ): Promise<T> {
    const startTime = Date.now();

    try {
      const result = await operation();
      const executionTime = Date.now() - startTime;

      // Log slow queries (> 1 second)
      if (executionTime > 1000) {
        await this.logSlowQuery({
          ...metadata,
          executionTime,
          timestamp: admin.firestore.Timestamp.now()
        });
      }

      return result;
    } catch (error) {
      const executionTime = Date.now() - startTime;
      await this.logFailedQuery({
        ...metadata,
        executionTime,
        error: error.message,
        timestamp: admin.firestore.Timestamp.now()
      });
      throw error;
    }
  }

  /**
   * Analyze query patterns and suggest optimizations
   */
  async analyzeQueryPatterns(): Promise<OptimizationSuggestions> {
    const logs = await this.db
      .collection('_performance_logs')
      .where('type', '==', 'slow_query')
      .where('timestamp', '>', new Date(Date.now() - 86400000)) // Last 24 hours
      .get();

    const patterns = new Map<string, number>();
    const suggestions: OptimizationSuggestions = {
      indexRecommendations: [],
      restructuringNeeds: [],
      cachingOpportunities: []
    };

    for (const doc of logs.docs) {
      const data = doc.data();
      const key = `${data.collection}_${data.queryType}`;
      patterns.set(key, (patterns.get(key) || 0) + 1);

      // Analyze patterns
      if (data.indexUsed === false) {
        suggestions.indexRecommendations.push({
          collection: data.collection,
          fields: data.queryFields,
          reason: 'Missing composite index causing slow queries'
        });
      }

      if (data.documentsRead > 100) {
        suggestions.cachingOpportunities.push({
          collection: data.collection,
          reason: 'High document read count - consider caching'
        });
      }
    }

    return suggestions;
  }

  private async logSlowQuery(metrics: any): Promise<void> {
    await this.db.collection('_performance_logs').add({
      type: 'slow_query',
      ...metrics
    });

    // Alert if critical
    if (metrics.executionTime > 5000) {
      await this.sendAlert({
        severity: 'high',
        message: `Critical: Query taking ${metrics.executionTime}ms`,
        metadata: metrics
      });
    }
  }

  private async logFailedQuery(metrics: any): Promise<void> {
    await this.db.collection('_performance_logs').add({
      type: 'failed_query',
      ...metrics
    });
  }

  private async sendAlert(alert: any): Promise<void> {
    // Send to monitoring service
    console.error('PERFORMANCE ALERT:', alert);
    // Could integrate with PagerDuty, Slack, etc.
  }
}

// Cloud Function to analyze performance
export const analyzePerformance = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const monitor = new FirestoreMonitor();
    const suggestions = await monitor.analyzeQueryPatterns();

    // Store suggestions
    await admin.firestore().collection('_optimization_suggestions').add({
      suggestions,
      timestamp: admin.firestore.Timestamp.now(),
      reviewed: false
    });

    return null;
  });
```

### Phase 3: Cloud Functions Performance

#### Function Monitoring
```typescript
// backend/functions/src/monitoring/function_monitor.ts

import * as functions from 'firebase-functions';

interface FunctionMetrics {
  name: string;
  executionTime: number;
  memoryUsed: number;
  coldStart: boolean;
  success: boolean;
  error?: string;
}

export function monitoredFunction<T>(
  handler: (data: any, context: functions.EventContext) => Promise<T>
) {
  return async (data: any, context: functions.EventContext): Promise<T> => {
    const startTime = Date.now();
    const startMemory = process.memoryUsage().heapUsed;
    const isColdStart = !global._functionInitialized;
    global._functionInitialized = true;

    const metrics: FunctionMetrics = {
      name: context.eventType || 'unknown',
      executionTime: 0,
      memoryUsed: 0,
      coldStart: isColdStart,
      success: false
    };

    try {
      const result = await handler(data, context);

      metrics.success = true;
      metrics.executionTime = Date.now() - startTime;
      metrics.memoryUsed = process.memoryUsage().heapUsed - startMemory;

      await logMetrics(metrics);

      // Alert on performance issues
      if (metrics.executionTime > 30000) { // 30 seconds
        await alertSlowFunction(metrics);
      }

      return result;
    } catch (error) {
      metrics.success = false;
      metrics.executionTime = Date.now() - startTime;
      metrics.error = error.message;

      await logMetrics(metrics);
      await alertFunctionError(metrics);

      throw error;
    }
  };
}

async function logMetrics(metrics: FunctionMetrics): Promise<void> {
  await admin.firestore().collection('_function_metrics').add({
    ...metrics,
    timestamp: admin.firestore.Timestamp.now()
  });
}

async function alertSlowFunction(metrics: FunctionMetrics): Promise<void> {
  console.error('SLOW FUNCTION:', metrics);
  // Send alert
}

async function alertFunctionError(metrics: FunctionMetrics): Promise<void> {
  console.error('FUNCTION ERROR:', metrics);
  // Send alert
}

// Usage
export const processVoiceQuery = functions.https.onCall(
  monitoredFunction(async (data, context) => {
    // Function logic
    return result;
  })
);
```

### Phase 4: Firestore Index Optimization

#### Index Analyzer
```bash
#!/bin/bash
# File: analyze_firestore_indexes.sh

echo "Firestore Index Analysis"
echo "========================"

# Get current indexes
firebase firestore:indexes > current_indexes.json

# Analyze query patterns from logs
echo ""
echo "Analyzing query patterns..."

# Export performance logs
firebase firestore:export gs://temp-exports/performance-logs \
  --collection-ids=_performance_logs

# Check for missing indexes
echo ""
echo "Checking for missing indexes..."
gsutil cat "gs://temp-exports/performance-logs/**" | \
  grep "index" | \
  sort | uniq -c | sort -rn | head -20

# Suggest optimizations
echo ""
echo "Index Optimization Suggestions:"
echo "1. Review frequently used query patterns"
echo "2. Create composite indexes for multi-field queries"
echo "3. Remove unused indexes to reduce costs"

# Cleanup
gsutil -m rm -r gs://temp-exports/performance-logs
```

## 📊 Performance Metrics & Dashboards

### Key Performance Indicators

#### Firestore KPIs
```typescript
interface FirestoreKPIs {
  // Read Performance
  avgReadLatency: number;        // Target: < 100ms
  p95ReadLatency: number;        // Target: < 500ms
  p99ReadLatency: number;        // Target: < 1000ms

  // Write Performance
  avgWriteLatency: number;       // Target: < 200ms
  p95WriteLatency: number;       // Target: < 1000ms

  // Query Performance
  slowQueryCount: number;        // Target: < 10/day
  missedIndexCount: number;      // Target: 0

  // Cost Metrics
  dailyReads: number;            // Monitor trend
  dailyWrites: number;           // Monitor trend
  estimatedCost: number;         // Budget alert

  // Efficiency
  cachedReadRatio: number;       // Target: > 60%
  avgDocumentsPerQuery: number;  // Target: < 50
}
```

#### Cloud Functions KPIs
```typescript
interface FunctionsKPIs {
  // Execution Performance
  avgExecutionTime: number;      // Target: < 2000ms
  p95ExecutionTime: number;      // Target: < 5000ms
  coldStartRate: number;         // Target: < 10%

  // Reliability
  successRate: number;           // Target: > 99%
  errorRate: number;             // Target: < 1%
  timeoutRate: number;           // Target: < 0.1%

  // Resource Usage
  avgMemoryUsage: number;        // Monitor trend
  maxMemoryUsage: number;        // Target: < 512MB
  cpuUtilization: number;        // Monitor trend

  // Cost
  dailyInvocations: number;      // Monitor trend
  estimatedCost: number;         // Budget alert
}
```

### Performance Dashboard
```typescript
// backend/functions/src/monitoring/performance_dashboard.ts

export const generatePerformanceDashboard = functions.https.onRequest(
  async (req, res) => {
    const timeRange = req.query.range || '24h';

    const firestoreMetrics = await getFirestoreMetrics(timeRange);
    const functionMetrics = await getFunctionMetrics(timeRange);
    const costMetrics = await getCostMetrics(timeRange);

    const dashboard = {
      generated: new Date().toISOString(),
      timeRange,
      firestore: {
        performance: firestoreMetrics,
        health: calculateHealth(firestoreMetrics),
        alerts: getActiveAlerts('firestore')
      },
      functions: {
        performance: functionMetrics,
        health: calculateHealth(functionMetrics),
        alerts: getActiveAlerts('functions')
      },
      costs: {
        current: costMetrics,
        projected: projectMonthlyCost(costMetrics),
        budgetStatus: checkBudget(costMetrics)
      },
      recommendations: generateRecommendations(
        firestoreMetrics,
        functionMetrics,
        costMetrics
      )
    };

    res.json(dashboard);
  }
);
```

## 🔧 Optimization Strategies

### Strategy 1: Query Optimization
```dart
// ❌ BAD: Reading all documents then filtering in memory
Future<List<LifeSituation>> getBadSituations(String category) async {
  final all = await FirebaseFirestore.instance
      .collection('life_situations')
      .get();

  return all.docs
      .where((doc) => doc.data()['category'] == category)
      .map((doc) => LifeSituation.fromFirestore(doc))
      .toList();
}

// ✅ GOOD: Filter at query level
Future<List<LifeSituation>> getGoodSituations(String category) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('life_situations')
      .where('category', isEqualTo: category)
      .limit(20)  // Always limit results
      .get();

  return snapshot.docs
      .map((doc) => LifeSituation.fromFirestore(doc))
      .toList();
}

// ✅ BETTER: With caching
class OptimizedRepository {
  final _cache = <String, List<LifeSituation>>{};
  final _cacheDuration = Duration(minutes: 15);
  final _cacheTimestamps = <String, DateTime>{};

  Future<List<LifeSituation>> getSituations(String category) async {
    final cacheKey = 'situations_$category';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final cacheAge = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
      if (cacheAge < _cacheDuration) {
        return _cache[cacheKey]!;
      }
    }

    // Fetch from Firestore
    final result = await getGoodSituations(category);

    // Update cache
    _cache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return result;
  }
}
```

### Strategy 2: Real-time Listener Optimization
```dart
// ❌ BAD: Listening to entire collection
StreamSubscription? _badListener;

void startBadListener() {
  _badListener = FirebaseFirestore.instance
      .collection('life_situations')
      .snapshots()
      .listen((snapshot) {
        // Process all documents on every change
      });
}

// ✅ GOOD: Filtered, limited listener
StreamSubscription? _goodListener;

void startGoodListener(String userId) {
  _goodListener = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .limit(50)  // Limit listener scope
      .snapshots()
      .listen((snapshot) {
        // Only affected documents received
      });
}

// Don't forget to cancel!
void dispose() {
  _goodListener?.cancel();
}
```

### Strategy 3: Batch Operations
```dart
// ❌ BAD: Individual writes
Future<void> badUpdateMultiple(List<LifeSituation> situations) async {
  for (final situation in situations) {
    await FirebaseFirestore.instance
        .collection('life_situations')
        .doc(situation.id)
        .update(situation.toJson());
  }
}

// ✅ GOOD: Batched writes
Future<void> goodUpdateMultiple(List<LifeSituation> situations) async {
  final batch = FirebaseFirestore.instance.batch();

  for (final situation in situations) {
    final ref = FirebaseFirestore.instance
        .collection('life_situations')
        .doc(situation.id);

    batch.update(ref, situation.toJson());
  }

  await batch.commit();  // Single network call
}
```

### Strategy 4: Cloud Function Optimization
```typescript
// ❌ BAD: Cold start penalty
export const badFunction = functions.https.onCall(async (data, context) => {
  const admin = require('firebase-admin');  // Imported inside function!
  const db = admin.firestore();
  // ...
});

// ✅ GOOD: Initialize outside handler
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export const goodFunction = functions.https.onCall(async (data, context) => {
  // Reuse initialized instances
  const result = await db.collection('test').get();
  // ...
});

// ✅ BETTER: With appropriate memory allocation
export const optimizedFunction = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '256MB',  // Right-sized memory
    minInstances: 1   // Avoid cold starts for critical functions
  })
  .https.onCall(async (data, context) => {
    // ...
  });
```

## 📋 Performance Checklist

### Daily Checks
- [ ] Review slow query alerts
- [ ] Check function execution times
- [ ] Monitor error rates
- [ ] Review cost trends

### Weekly Reviews
- [ ] Analyze query patterns
- [ ] Review index usage
- [ ] Check cache hit rates
- [ ] Optimize slow functions
- [ ] Review budget vs actual

### Monthly Optimization
- [ ] Deep dive performance analysis
- [ ] Identify optimization opportunities
- [ ] Implement caching strategies
- [ ] Review and remove unused indexes
- [ ] Capacity planning review

## 🚀 Quick Commands

```bash
# Monitor Firestore performance
firebase firestore:stats

# Analyze function performance
firebase functions:log --only processVoiceQuery --limit 100

# Check current costs
firebase billing:get

# Export performance logs
./export_performance_logs.sh

# Generate optimization report
npm run performance:analyze
```

## 🎯 Performance Targets

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| Firestore Read Latency (p95) | < 500ms | 500-1000ms | > 1000ms |
| Function Execution (p95) | < 5s | 5-10s | > 10s |
| Cache Hit Rate | > 60% | 40-60% | < 40% |
| Error Rate | < 0.5% | 0.5-1% | > 1% |
| Daily Cost | < $5 | $5-10 | > $10 |

## 📚 Resources
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Cloud Functions Optimization](https://firebase.google.com/docs/functions/tips)
- [Firebase Pricing Calculator](https://firebase.google.com/pricing)

---

**Note**: Monitor performance continuously. Small optimizations compound over time. Always measure before and after optimization changes.
