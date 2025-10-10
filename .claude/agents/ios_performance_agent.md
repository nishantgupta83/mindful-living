# iOS Performance Testing Agent

## 🎯 Purpose
Comprehensive performance testing and benchmarking for Mindful Living iOS app. This agent identifies bottlenecks, measures key metrics, ensures App Store compliance, and provides actionable optimization recommendations.

## 🔍 Responsibilities

### 1. Performance Benchmarking
- App launch time (cold/warm/resume)
- ScrollView and UITableView performance
- Memory usage and leak detection
- Battery and energy impact analysis
- Network request performance
- Core Data / SQLite query optimization
- IPA size and download impact

### 2. Device Testing Matrix
- **Budget/Older**: iPhone SE (2nd gen), iPhone 11
- **Mid-Range**: iPhone 12, iPhone 13
- **Current**: iPhone 14, iPhone 15
- **Pro Models**: iPhone 14 Pro, iPhone 15 Pro Max
- **iPad**: iPad Air, iPad Pro 11"
- **Watch**: Apple Watch Series 6+, Ultra

### 3. iOS Version Coverage
- **Minimum**: iOS 13.0 (deployment target)
- **Primary**: iOS 16.0+ (80% of users)
- **Latest**: iOS 18.0 (beta testing)

### 4. Key Metrics to Track
- **Launch Time**: Target < 400ms (warm), < 800ms (cold)
- **Frame Rate**: Target 60 FPS (120 FPS on ProMotion)
- **Memory**: < 150MB baseline, < 250MB active use
- **Energy**: Low energy impact rating
- **IPA Size**: < 40MB (after App Store thinning)
- **Network**: < 2 seconds for API calls

## 📋 Testing Checklist

### Phase 1: Pre-Testing Setup
```bash
# Ensure development environment is ready
flutter pub get

# Build iOS release build
flutter build ios --release

# Build for profiling
flutter build ios --profile

# Open in Xcode for Instruments
open ios/Runner.xcworkspace
```

### Phase 2: Xcode Instruments Profiling

#### Launch Time Analysis
```bash
# Use Xcode's App Launch instrument
# Product > Profile (⌘I) > App Launch

# Or via command line:
xcrun xctrace record --template 'App Launch' \
  --device '<DEVICE_ID>' \
  --launch com.hub4apps.mindfulliving \
  --output launch_time.trace
```

#### Memory Leaks Detection
```bash
# Use Leaks instrument
xcrun xctrace record --template 'Leaks' \
  --device '<DEVICE_ID>' \
  --attach com.hub4apps.mindfulliving \
  --time-limit 30m \
  --output memory_leaks.trace
```

#### Energy Impact Analysis
```bash
# Use Energy Log instrument
xcrun xctrace record --template 'Energy Log' \
  --device '<DEVICE_ID>' \
  --attach com.hub4apps.mindfulliving \
  --time-limit 1h \
  --output energy_impact.trace
```

### Phase 3: Metal Performance Analysis
```bash
# GPU performance profiling
xcrun xctrace record --template 'GPU' \
  --device '<DEVICE_ID>' \
  --attach com.hub4apps.mindfulliving \
  --time-limit 10m \
  --output gpu_performance.trace
```

### Phase 4: Network Performance
```bash
# HTTP Traffic instrument
xcrun xctrace record --template 'Network' \
  --device '<DEVICE_ID>' \
  --attach com.hub4apps.mindfulliving \
  --time-limit 15m \
  --output network_traffic.trace
```

### Phase 5: Time Profiler (CPU Usage)
```bash
# CPU profiling
xcrun xctrace record --template 'Time Profiler' \
  --device '<DEVICE_ID>' \
  --attach com.hub4apps.mindfulliving \
  --time-limit 10m \
  --output cpu_profile.trace
```

### Phase 6: SwiftUI View Body Profiling
```swift
// Add to ContentView or main screens
import os.signpost

let log = OSLog(subsystem: "com.hub4apps.mindfulliving", category: "Performance")

struct DashboardView: View {
    var body: some View {
        os_signpost(.begin, log: log, name: "Dashboard Render")
        defer { os_signpost(.end, log: log, name: "Dashboard Render") }

        // View code...
    }
}
```

### Phase 7: MetricKit Integration
```swift
// Add to AppDelegate or main app file
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricsManager()

    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Log launch time
            if let launchMetrics = payload.applicationLaunchMetrics {
                print("App Launch Time: \(launchMetrics.histogrammedTimeToFirstDrawKey)")
            }

            // Log hang rate
            if let hangMetrics = payload.applicationResponsivenessMetrics {
                print("Hang Rate: \(hangMetrics.histogrammedApplicationHangTime)")
            }

            // Log memory usage
            if let memoryMetrics = payload.memoryMetrics {
                print("Peak Memory: \(memoryMetrics.peakMemoryUsage)")
            }

            // Upload to analytics
            uploadMetrics(payload)
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        // Handle crash and hang diagnostics
        for payload in payloads {
            if let crashPayload = payload.crashDiagnostics {
                print("Crash detected: \(crashPayload)")
            }
        }
    }
}
```

## 🔬 Detailed Testing Procedures

### Test 1: Launch Time Benchmark
```swift
// Add to test/integration/ios_performance_test.dart

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('iOS Launch Performance', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver?.close();
    });

    test('Measure cold launch time', () async {
      final timeline = await driver!.traceAction(() async {
        // App should already be launched
        await Future.delayed(Duration(seconds: 2));
      });

      final summary = TimelineSummary.summarize(timeline);

      // Check frame build times
      expect(summary.computeMissedFramesPercentage(), lessThan(1.0));

      // Save timeline
      await summary.writeSummaryToFile('ios_launch_timeline', pretty: true);
      await summary.writeTimelineToFile('ios_launch_timeline', pretty: true);
    });
  });
}
```

### Test 2: ScrollView Performance
```swift
// Add to iOS performance test suite

import XCTest
import Flutter

class PerformanceTests: XCTestCase {

    func testListScrollPerformance() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to list view
        app.buttons["Life Situations"].tap()

        // Measure scrolling performance
        let scrollView = app.scrollViews.firstMatch
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }

    func testAnimationPerformance() throws {
        let app = XCUIApplication()
        app.launch()

        // Measure animation frame rate
        measure(metrics: [XCTOSSignpostMetric.animationMetric]) {
            // Trigger animations
            app.buttons["Dashboard"].tap()
            app.buttons["Journal"].tap()
            app.buttons["Practices"].tap()
        }
    }
}
```

### Test 3: Memory Usage Analysis
```bash
#!/bin/bash
# File: test_ios_memory.sh

BUNDLE_ID="com.hub4apps.mindfulliving"
DEVICE_ID="<YOUR_DEVICE_ID>"

echo "iOS Memory Usage Test"
echo "===================="

# Get initial memory
echo "Launching app..."
xcrun simctl launch $DEVICE_ID $BUNDLE_ID

sleep 5

# Monitor memory for 30 minutes
for i in {1..30}; do
    MEMORY=$(xcrun simctl status_bar $DEVICE_ID list | grep -A 3 $BUNDLE_ID | grep "memory" | awk '{print $2}')
    echo "Time: ${i}min | Memory: ${MEMORY}MB"
    sleep 60
done

echo "Test complete. Check for memory growth patterns."
```

### Test 4: Energy Impact Assessment
```bash
#!/bin/bash
# File: test_ios_energy.sh

BUNDLE_ID="com.hub4apps.mindfulliving"

echo "iOS Energy Impact Test"
echo "====================="

# Start energy logging
xcrun xctrace record --template 'Energy Log' \
  --device '<DEVICE_ID>' \
  --attach $BUNDLE_ID \
  --time-limit 1h \
  --output energy_test.trace

# After test completes, analyze
echo ""
echo "Analyzing energy usage..."
xcrun xctrace export --input energy_test.trace --output energy_report.xml

# Parse key metrics
echo "Energy Impact Summary:"
# Would need custom parsing here based on XML structure
```

### Test 5: Network Efficiency
```swift
// Add to app for network monitoring

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isExpensive = false
    var isConstrained = false

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained

            // Adjust behavior based on network conditions
            if path.isExpensive || path.isConstrained {
                // Reduce image quality, defer non-critical downloads
                print("⚠️ Limited network - reducing data usage")
            }

            // Log network type
            if path.usesInterfaceType(.wifi) {
                print("📶 Using WiFi")
            } else if path.usesInterfaceType(.cellular) {
                print("📱 Using Cellular")
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
```

### Test 6: ProMotion Display Testing (120Hz)
```swift
// Test for ProMotion devices

import UIKit

extension UIScreen {
    var isProMotionCapable: Bool {
        return maximumFramesPerSecond == 120
    }
}

// In performance test
func testProMotionPerformance() {
    if UIScreen.main.isProMotionCapable {
        // Verify animations run at 120fps
        measure(metrics: [XCTOSSignpostMetric.animationMetric]) {
            // Trigger smooth animations
            // Target: 120 FPS
        }
    }
}
```

### Test 7: App Size Analysis
```bash
#!/bin/bash
# File: analyze_ipa_size.sh

IPA_PATH="build/ios/iphoneos/Runner.ipa"

echo "iOS App Size Analysis"
echo "===================="

# Unzip IPA
unzip -q $IPA_PATH -d ipa_contents

cd ipa_contents/Payload/Runner.app

# Analyze components
echo ""
echo "App Bundle Size:"
du -sh .

echo ""
echo "Framework Sizes:"
du -sh Frameworks/*

echo ""
echo "Asset Catalog Size:"
du -sh Assets.car

echo ""
echo "Flutter Engine Size:"
du -sh Frameworks/Flutter.framework

echo ""
echo "Largest Files:"
find . -type f -exec du -h {} + | sort -rh | head -20

# Check for optimization opportunities
echo ""
echo "Optimization Recommendations:"
echo "- Compressed assets: $(find . -name '*.png' -o -name '*.jpg' | wc -l) images found"
echo "- Unused resources: Check for unused image assets"
echo "- Code stripping: Ensure bitcode and unused code is removed"

cd ../../..
rm -rf ipa_contents
```

## 📊 Performance Report Template

```markdown
# iOS Performance Test Report
**Date**: [DATE]
**Build**: [VERSION] (Build [BUILD_NUMBER])
**Device**: [DEVICE_MODEL]
**iOS Version**: [OS_VERSION]
**Screen**: [RESOLUTION] @ [REFRESH_RATE]

## Executive Summary
- ✅/⚠️/❌ Overall Performance Rating
- App Store Ready: Yes/No
- Critical Issues: [COUNT]
- Warnings: [COUNT]
- Recommendations: [COUNT]

## Metrics

### Launch Performance
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Cold Launch | < 800ms | [VALUE]ms | ✅/⚠️/❌ |
| Warm Launch | < 400ms | [VALUE]ms | ✅/⚠️/❌ |
| Resume | < 200ms | [VALUE]ms | ✅/⚠️/❌ |
| Time to Interactive | < 1200ms | [VALUE]ms | ✅/⚠️/❌ |

### Frame Rate Performance
| Screen | Target | Actual | Dropped Frames | Status |
|--------|--------|--------|----------------|--------|
| Dashboard | 60 FPS | [VALUE] | [COUNT] | ✅/⚠️/❌ |
| List View | 60 FPS | [VALUE] | [COUNT] | ✅/⚠️/❌ |
| Animations | 60 FPS | [VALUE] | [COUNT] | ✅/⚠️/❌ |
| ProMotion (if available) | 120 FPS | [VALUE] | [COUNT] | ✅/⚠️/❌ |

### Memory Performance
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Baseline | < 150MB | [VALUE]MB | ✅/⚠️/❌ |
| Active Use | < 250MB | [VALUE]MB | ✅/⚠️/❌ |
| Peak | < 400MB | [VALUE]MB | ✅/⚠️/❌ |
| Memory Leaks | 0 | [COUNT] | ✅/⚠️/❌ |
| Abandoned Memory | < 5MB | [VALUE]MB | ✅/⚠️/❌ |

### Energy Impact
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Overall Rating | Low | [RATING] | ✅/⚠️/❌ |
| CPU Usage | < 20% avg | [VALUE]% | ✅/⚠️/❌ |
| Network | Efficient | [RATING] | ✅/⚠️/❌ |
| Location | N/A or Efficient | [RATING] | ✅/⚠️/❌ |
| Display | Efficient | [RATING] | ✅/⚠️/❌ |

### Network Performance
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| API Response | < 2s | [VALUE]s | ✅/⚠️/❌ |
| Image Loading | < 1s | [VALUE]s | ✅/⚠️/❌ |
| Concurrent Requests | < 4 | [COUNT] | ✅/⚠️/❌ |
| Data Usage (1hr) | < 10MB | [VALUE]MB | ✅/⚠️/❌ |

### App Size (App Store)
| Component | Size | % of Total |
|-----------|------|------------|
| IPA Size (pre-thinning) | [VALUE]MB | 100% |
| App Thinning Size (iPhone) | [VALUE]MB | [%] |
| Universal Size | [VALUE]MB | [%] |
| Executable | [VALUE]MB | [%] |
| Frameworks | [VALUE]MB | [%] |
| Resources | [VALUE]MB | [%] |

### MetricKit Summary (7-day aggregated data)
| Metric | P50 | P90 | P99 |
|--------|-----|-----|-----|
| Launch Time | [VALUE]ms | [VALUE]ms | [VALUE]ms |
| Hang Rate | [VALUE]% | [VALUE]% | [VALUE]% |
| Crash Rate | [VALUE]% | [VALUE]% | [VALUE]% |

## Issues Found

### Critical 🔴
1. [ISSUE_DESCRIPTION]
   - Device: [AFFECTED_DEVICES]
   - iOS Version: [AFFECTED_VERSIONS]
   - Impact: [IMPACT]
   - Recommendation: [ACTION]
   - Xcode Instrument: [INSTRUMENT_NAME]

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
   - Expected Impact: [IMPROVEMENT]
   - Instruments to verify: [INSTRUMENTS]

### Medium Priority
[...]

### Low Priority
[...]

## App Store Compliance

### Technical Requirements
- [x] Launch time < 20 seconds
- [x] No crashes on launch
- [x] No excessive memory usage warnings
- [x] No private API usage detected
- [x] Bitcode enabled (if required)
- [x] All architectures supported

### Performance Guidelines
- [x] Smooth scrolling (60 FPS)
- [x] Responsive UI (< 100ms touch response)
- [x] Efficient network usage
- [x] Battery-friendly
- [x] Proper memory management

## Device-Specific Notes

### iPhone SE (2nd gen) - Budget
- Performance: [OBSERVATIONS]
- Recommendations: [DEVICE_SPECIFIC_OPTIMIZATIONS]

### iPhone 13 - Mid-Range
- Performance: [OBSERVATIONS]
- ProMotion: N/A

### iPhone 15 Pro - Flagship
- Performance: [OBSERVATIONS]
- ProMotion: [120Hz OBSERVATIONS]
- A17 Pro optimizations: [NOTES]

### iPad Air
- Performance: [OBSERVATIONS]
- Layout optimizations: [NOTES]

### Apple Watch
- Performance: [OBSERVATIONS]
- Complications: [NOTES]
- Battery impact: [NOTES]

## Comparison with Previous Build
| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
| Launch Time | [VALUE]ms | [VALUE]ms | [+/-VALUE]ms |
| Memory Usage | [VALUE]MB | [VALUE]MB | [+/-VALUE]MB |
| IPA Size | [VALUE]MB | [VALUE]MB | [+/-VALUE]MB |

## Next Steps
1. [ ] Address critical issues
2. [ ] Fix performance regressions
3. [ ] Implement high-priority optimizations
4. [ ] Re-test on affected devices
5. [ ] Update MetricKit monitoring
6. [ ] Submit to TestFlight

## Xcode Instruments Files
- Launch Time: `launch_time.trace`
- Memory Leaks: `memory_leaks.trace`
- Energy Impact: `energy_impact.trace`
- Time Profiler: `cpu_profile.trace`
```

## 🚀 Quick Start Commands

```bash
# Full iOS performance test suite
./test_ios_performance.sh

# Individual Xcode Instruments tests
./test_launch_time.sh
./test_memory_leaks.sh
./test_energy_impact.sh
./test_network_performance.sh

# App size analysis
./analyze_ipa_size.sh

# Run integration tests with performance metrics
flutter drive \
  --target=test_driver/ios_performance.dart \
  --driver=test_driver/ios_performance_test.dart \
  --profile
```

## 🎯 Success Criteria

### Must Pass (Critical - App Store Requirements)
- [ ] Launch time < 20 seconds (App Store maximum)
- [ ] No crash on launch
- [ ] No excessive memory usage
- [ ] Responds to user input within 100ms
- [ ] No private API usage

### Should Pass (Important - User Experience)
- [ ] Cold launch < 800ms
- [ ] Warm launch < 400ms
- [ ] 60 FPS during scrolling
- [ ] Memory < 250MB during active use
- [ ] Energy impact rating: Low
- [ ] No memory leaks
- [ ] IPA size < 40MB (thinned)

### Nice to Have (Optimal - Premium Experience)
- [ ] Cold launch < 500ms
- [ ] 120 FPS on ProMotion displays
- [ ] Memory < 200MB during active use
- [ ] Energy impact: Very Low
- [ ] IPA size < 30MB (thinned)
- [ ] Perfect MetricKit scores (P99)

## 📚 Resources
- [Xcode Instruments Documentation](https://developer.apple.com/documentation/xcode/instruments)
- [MetricKit Framework](https://developer.apple.com/documentation/metrickit)
- [App Store Review Guidelines - Performance](https://developer.apple.com/app-store/review/guidelines/#performance)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [iOS Performance Optimization](https://developer.apple.com/videos/play/wwdc2023/10181/)

## 🔄 Continuous Monitoring

### MetricKit Integration (Production)
```swift
// Automatically collects performance data from real users
// Data is aggregated and delivered daily
// No PII is collected

class ProductionMetrics {
    static func setup() {
        MetricsManager.shared // Activates collection
    }

    static func exportMetrics() -> [String: Any] {
        // Export to your analytics platform
        return [
            "launch_time_p50": ...,
            "launch_time_p90": ...,
            "crash_rate": ...,
            "hang_rate": ...
        ]
    }
}
```

### TestFlight Beta Testing
- Distribute to 100 beta testers
- Monitor crash logs
- Track performance metrics
- Collect user feedback
- Iterate based on data

---

**Note**: Always test on physical devices. Simulators don't accurately represent CPU, GPU, or memory performance. Test across multiple iOS versions and device generations.
