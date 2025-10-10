# Android Performance Testing Agent

## 🎯 Purpose
Comprehensive performance testing and benchmarking for Mindful Living Android app. This agent identifies bottlenecks, measures key metrics, and provides actionable optimization recommendations.

## 🔍 Responsibilities

### 1. Performance Benchmarking
- App startup time (cold/warm/hot)
- Screen rendering performance (jank detection)
- Memory usage and leak detection
- Battery consumption analysis
- Network request performance
- Database query optimization
- APK size analysis

### 2. Device Testing Matrix
- **Budget Devices**: Redmi 9A, Samsung A12, Realme C11
- **Mid-Range**: Samsung A52, OnePlus Nord, Pixel 6a
- **Flagship**: Samsung S23, OnePlus 11, Pixel 8

### 3. Key Metrics to Track
- **Startup Time**: Target < 2 seconds (cold), < 1 second (warm)
- **FPS**: Target 60 FPS, minimum 50 FPS
- **Memory**: < 100MB baseline, < 200MB active use
- **Battery**: < 5% per hour active use
- **APK Size**: < 50MB
- **Network**: < 3 seconds for API calls

## 📋 Testing Checklist

### Phase 1: Pre-Testing Setup
```bash
# Ensure dependencies are installed
flutter pub get

# Build release APK
flutter build apk --release --target-platform android-arm64

# Build debug APK with profiling enabled
flutter build apk --debug --profile
```

### Phase 2: Startup Performance
```bash
# Test cold startup time (5 iterations)
for i in {1..5}; do
  adb shell am force-stop com.hub4apps.mindfulliving
  adb shell "am start -W -n com.hub4apps.mindfulliving/.MainActivity" 2>&1 | grep "TotalTime"
  sleep 10
done

# Measure app size
adb shell pm path com.hub4apps.mindfulliving | awk '{print $1}' | cut -d ':' -f 2 | xargs adb shell ls -lh
```

### Phase 3: Runtime Performance
```bash
# Enable GPU rendering profiler
adb shell setprop debug.hwui.profile visual_bars

# Monitor FPS using dumpsys gfxinfo
adb shell dumpsys gfxinfo com.hub4apps.mindfulliving framestats

# Memory profiling
adb shell dumpsys meminfo com.hub4apps.mindfulliving

# CPU profiling
adb shell top -n 1 | grep com.hub4apps.mindfulliving
```

### Phase 4: Flutter Performance Overlay
```dart
// Add to main.dart for performance testing
MaterialApp(
  showPerformanceOverlay: true,  // Enable FPS overlay
  checkerboardRasterCacheImages: true,  // Identify caching issues
  checkerboardOffscreenLayers: true,  // Identify layer issues
  // ... rest of app
)
```

### Phase 5: Battery Testing
```bash
# Reset battery stats
adb shell dumpsys batterystats --reset

# Use app for 30 minutes, then check
adb shell dumpsys batterystats com.hub4apps.mindfulliving

# Check wake locks
adb shell dumpsys batterystats | grep -A 10 "Wake lock"
```

### Phase 6: Network Performance
```bash
# Monitor network requests
adb shell tcpdump -i any -s 0 -w /sdcard/capture.pcap

# Analyze with Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Phase 7: APK Analysis
```bash
# Analyze APK size
flutter build apk --analyze-size --target-platform android-arm64

# Check method count (should be < 64K per DEX)
apkanalyzer dex packages --proguard-mappings app/build/outputs/mapping/release/mapping.txt build/app/outputs/flutter-apk/app-release.apk
```

## 🔬 Detailed Testing Procedures

### Test 1: Startup Time Benchmark
```bash
#!/bin/bash
# File: test_startup_time.sh

echo "Testing Mindful Living Android Startup Performance"
echo "=================================================="

# Variables
PACKAGE="com.hub4apps.mindfulliving"
ACTIVITY="$PACKAGE/.MainActivity"
ITERATIONS=10
TOTAL_TIME=0

echo "Running $ITERATIONS iterations..."

for i in $(seq 1 $ITERATIONS); do
  # Force stop the app
  adb shell am force-stop $PACKAGE

  # Clear app data for true cold start
  if [ $((i % 2)) -eq 0 ]; then
    adb shell pm clear $PACKAGE
  fi

  # Wait for system to settle
  sleep 5

  # Launch and measure
  OUTPUT=$(adb shell "am start -W -n $ACTIVITY" 2>&1)
  TIME=$(echo "$OUTPUT" | grep "TotalTime" | awk '{print $2}')

  echo "Iteration $i: ${TIME}ms"
  TOTAL_TIME=$((TOTAL_TIME + TIME))

  # Wait before next iteration
  sleep 3
done

AVG_TIME=$((TOTAL_TIME / ITERATIONS))
echo ""
echo "Average startup time: ${AVG_TIME}ms"
echo "Target: < 2000ms (cold), < 1000ms (warm)"

if [ $AVG_TIME -lt 1000 ]; then
  echo "✅ EXCELLENT: Startup time is excellent"
elif [ $AVG_TIME -lt 2000 ]; then
  echo "✅ GOOD: Startup time meets target"
elif [ $AVG_TIME -lt 3000 ]; then
  echo "⚠️ WARNING: Startup time needs improvement"
else
  echo "❌ CRITICAL: Startup time is too slow"
fi
```

### Test 2: Memory Leak Detection
```bash
#!/bin/bash
# File: test_memory_leaks.sh

PACKAGE="com.hub4apps.mindfulliving"
DURATION=1800  # 30 minutes
INTERVAL=60    # Check every minute

echo "Memory Leak Detection Test"
echo "Testing for $DURATION seconds..."

START_MEM=$(adb shell dumpsys meminfo $PACKAGE | grep "TOTAL" | awk '{print $2}')
echo "Initial memory: ${START_MEM}KB"

for i in $(seq 1 $((DURATION / INTERVAL))); do
  sleep $INTERVAL

  CURRENT_MEM=$(adb shell dumpsys meminfo $PACKAGE | grep "TOTAL" | awk '{print $2}')
  INCREASE=$((CURRENT_MEM - START_MEM))
  PERCENT=$((INCREASE * 100 / START_MEM))

  echo "Time: ${i}min | Memory: ${CURRENT_MEM}KB | Increase: +${INCREASE}KB (+${PERCENT}%)"

  # Alert if memory increased by more than 50%
  if [ $PERCENT -gt 50 ]; then
    echo "⚠️ WARNING: Potential memory leak detected!"
  fi
done

END_MEM=$(adb shell dumpsys meminfo $PACKAGE | grep "TOTAL" | awk '{print $2}')
TOTAL_INCREASE=$((END_MEM - START_MEM))
TOTAL_PERCENT=$((TOTAL_INCREASE * 100 / START_MEM))

echo ""
echo "Final memory: ${END_MEM}KB"
echo "Total increase: +${TOTAL_INCREASE}KB (+${TOTAL_PERCENT}%)"

if [ $TOTAL_PERCENT -lt 20 ]; then
  echo "✅ GOOD: No significant memory increase"
elif [ $TOTAL_PERCENT -lt 50 ]; then
  echo "⚠️ WARNING: Moderate memory increase detected"
else
  echo "❌ CRITICAL: Potential memory leak - investigate immediately"
fi
```

### Test 3: Frame Rate Analysis
```dart
// Add to test/integration/performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindful_living/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Android Performance Tests', () {
    testWidgets('Dashboard rendering performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Record timeline
      await binding.traceAction(() async {
        // Navigate through all screens
        await tester.tap(find.text('Journal'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        await tester.tap(find.text('Practices'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Scroll test
        await tester.drag(find.byType(ListView).first, Offset(0, -500));
        await tester.pumpAndSettle();
      }, reportKey: 'dashboard_performance');

      // Analyze results
      final timeline = await binding.reportData;
      expect(timeline, isNotNull);

      // Check for jank (frames taking > 16ms)
      // This would be analyzed in CI/CD
    });

    testWidgets('List scrolling performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to dilemma list
      await tester.tap(find.text('Life Situations'));
      await tester.pumpAndSettle();

      await binding.traceAction(() async {
        // Perform fast scrolling
        for (var i = 0; i < 10; i++) {
          await tester.drag(
            find.byType(ListView).first,
            Offset(0, -300),
          );
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }, reportKey: 'list_scrolling_performance');
    });
  });
}
```

### Test 4: Network Performance
```bash
#!/bin/bash
# File: test_network_performance.sh

PACKAGE="com.hub4apps.mindfulliving"

echo "Network Performance Analysis"
echo "============================"

# Start network capture
adb shell "tcpdump -i any -s 0 -w /sdcard/network_capture.pcap" &
TCPDUMP_PID=$!

echo "Starting app and monitoring network..."
adb shell am start -n $PACKAGE/.MainActivity

# Wait for app to load and make requests
sleep 30

# Stop capture
kill $TCPDUMP_PID
adb pull /sdcard/network_capture.pcap ./network_capture.pcap

echo "Network capture saved. Analyzing..."

# Analyze Firebase requests
echo ""
echo "Firebase Request Analysis:"
adb shell "dumpsys netstats detail" | grep -A 5 $PACKAGE

# Check data usage
RX_BYTES=$(adb shell "dumpsys netstats detail" | grep $PACKAGE | awk '{print $2}')
TX_BYTES=$(adb shell "dumpsys netstats detail" | grep $PACKAGE | awk '{print $3}')

echo "Data received: ${RX_BYTES} bytes"
echo "Data transmitted: ${TX_BYTES} bytes"
```

### Test 5: Battery Impact
```bash
#!/bin/bash
# File: test_battery_impact.sh

PACKAGE="com.hub4apps.mindfulliving"

echo "Battery Impact Test"
echo "==================="

# Reset battery stats
adb shell dumpsys batterystats --reset
echo "Battery stats reset. Use app for 30-60 minutes..."
echo "Press Enter when done..."
read

# Get battery report
adb shell dumpsys batterystats $PACKAGE > battery_report.txt

# Parse key metrics
echo ""
echo "Battery Usage Summary:"
echo "---------------------"
grep -A 10 "Estimated power use" battery_report.txt
grep -A 5 "Wake lock" battery_report.txt
grep -A 5 "Sensor" battery_report.txt

# Generate battery historian report
echo ""
echo "Generating Battery Historian report..."
adb bugreport bugreport.zip
# Upload to https://bathist.ef.lc/ for analysis
```

## 📊 Performance Report Template

```markdown
# Android Performance Test Report
**Date**: [DATE]
**Build**: [VERSION]
**Device**: [DEVICE_MODEL]
**Android Version**: [OS_VERSION]

## Executive Summary
- ✅/⚠️/❌ Overall Performance Rating
- Critical Issues: [COUNT]
- Warnings: [COUNT]
- Recommendations: [COUNT]

## Metrics

### Startup Performance
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Cold Start | < 2000ms | [VALUE]ms | ✅/⚠️/❌ |
| Warm Start | < 1000ms | [VALUE]ms | ✅/⚠️/❌ |
| Hot Start | < 500ms | [VALUE]ms | ✅/⚠️/❌ |

### Runtime Performance
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Average FPS | 60 | [VALUE] | ✅/⚠️/❌ |
| 99th Percentile | 50+ | [VALUE] | ✅/⚠️/❌ |
| Jank Frames | < 1% | [VALUE]% | ✅/⚠️/❌ |

### Memory Usage
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Baseline | < 100MB | [VALUE]MB | ✅/⚠️/❌ |
| Active Use | < 200MB | [VALUE]MB | ✅/⚠️/❌ |
| Peak | < 300MB | [VALUE]MB | ✅/⚠️/❌ |
| Memory Leaks | 0 | [COUNT] | ✅/⚠️/❌ |

### Battery Impact
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Active Use | < 5%/hr | [VALUE]%/hr | ✅/⚠️/❌ |
| Background | < 1%/hr | [VALUE]%/hr | ✅/⚠️/❌ |
| Wake Locks | < 10 | [COUNT] | ✅/⚠️/❌ |

### App Size
| Component | Size | % of Total |
|-----------|------|------------|
| APK Size | [VALUE]MB | 100% |
| Native Code | [VALUE]MB | [%] |
| Resources | [VALUE]MB | [%] |
| Assets | [VALUE]MB | [%] |

## Issues Found

### Critical 🔴
1. [ISSUE_DESCRIPTION]
   - Impact: [IMPACT]
   - Recommendation: [ACTION]

### Warnings 🟡
1. [ISSUE_DESCRIPTION]
   - Impact: [IMPACT]
   - Recommendation: [ACTION]

## Optimization Recommendations

### High Priority
1. **[RECOMMENDATION_TITLE]**
   - Current: [CURRENT_STATE]
   - Target: [TARGET_STATE]
   - Implementation: [STEPS]
   - Impact: [EXPECTED_IMPROVEMENT]

### Medium Priority
[...]

### Low Priority
[...]

## Device-Specific Notes
- Budget Devices: [OBSERVATIONS]
- Mid-Range Devices: [OBSERVATIONS]
- Flagship Devices: [OBSERVATIONS]

## Next Steps
1. [ ] Fix critical issues
2. [ ] Address warnings
3. [ ] Implement high-priority optimizations
4. [ ] Re-test and validate improvements
```

## 🚀 Quick Start Commands

```bash
# Full performance test suite
./test_android_performance.sh

# Individual tests
./test_startup_time.sh
./test_memory_leaks.sh
./test_battery_impact.sh
./test_network_performance.sh

# Generate report
flutter pub run integration_test --driver test_driver/integration_test.dart --target integration_test/android_performance_test.dart
```

## 🎯 Success Criteria

### Must Pass (Critical)
- [ ] Cold startup < 2 seconds
- [ ] Average FPS > 50
- [ ] No memory leaks detected
- [ ] No ANR (Application Not Responding) events
- [ ] APK size < 50MB

### Should Pass (Important)
- [ ] Warm startup < 1 second
- [ ] Average FPS = 60
- [ ] Memory < 200MB during active use
- [ ] Battery usage < 5% per hour
- [ ] Network requests < 3 seconds

### Nice to Have (Optimal)
- [ ] Hot startup < 500ms
- [ ] 99th percentile FPS > 55
- [ ] Memory < 150MB during active use
- [ ] Battery usage < 3% per hour
- [ ] APK size < 30MB

## 📚 Resources
- [Android Performance Profiling](https://developer.android.com/studio/profile)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [ADB Shell Commands](https://developer.android.com/studio/command-line/adb)
- [Battery Historian](https://github.com/google/battery-historian)

## 🔄 Continuous Monitoring

Set up automated performance tracking:
1. Run tests on every PR
2. Track metrics over time
3. Alert on regression
4. Generate comparison reports

---

**Note**: Always test on real devices, not just emulators. Emulators don't accurately represent real-world performance.
