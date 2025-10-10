# Mindful Living - Coding Agents

## 📚 Overview
This directory contains specialized AI agents for automating various aspects of Mindful Living app development. Each agent is an expert in its domain and can be invoked independently or in parallel for maximum efficiency.

## 🤖 Available Agents

### 1. Performance Testing Agents

#### [`android_performance_agent.md`](./android_performance_agent.md)
**Purpose**: Android performance testing and optimization
- Startup time analysis
- Memory leak detection
- Battery impact testing
- Frame rate monitoring
- APK size optimization
- Device-specific testing (budget to flagship)

**When to Use**:
- Before each release
- After major feature additions
- When performance issues reported
- Monthly optimization reviews

**Quick Start**:
```bash
# Full performance test suite
./test_android_performance.sh

# Individual tests
./test_startup_time.sh
./test_memory_leaks.sh
```

---

#### [`ios_performance_agent.md`](./ios_performance_agent.md)
**Purpose**: iOS performance testing and App Store compliance
- Launch time benchmarking
- Xcode Instruments profiling
- Energy impact analysis
- ProMotion display testing
- IPA size analysis
- MetricKit integration

**When to Use**:
- Before App Store submission
- After iOS updates
- When targeting new devices
- Performance regression checks

**Quick Start**:
```bash
# Run iOS performance suite
./test_ios_performance.sh

# Xcode Instruments profiling
xcrun xctrace record --template 'App Launch' --device '<DEVICE_ID>'
```

---

### 2. Code Quality Agent

#### [`code_review_agent.md`](./code_review_agent.md)
**Purpose**: Automated code quality checks and reviews
- Static analysis with flutter analyze
- Code complexity metrics
- Security vulnerability scanning
- Performance anti-pattern detection
- Architecture review
- Test coverage analysis

**When to Use**:
- On every commit (pre-commit hook)
- Pull request reviews
- Weekly code quality audits
- Before major releases

**Quick Start**:
```bash
# Full code review
flutter analyze && flutter test

# Run all quality checks
./scripts/code_review.sh

# Check code metrics
dart_code_metrics analyze lib
```

---

### 3. Firebase Management Agents

#### [`firebase_migration_agent.md`](./firebase_migration_agent.md)
**Purpose**: Firestore schema migrations and data transformations
- Schema evolution management
- Zero-downtime migrations
- Data transformation pipelines
- Rollback capability
- Migration testing framework

**When to Use**:
- Database schema changes
- Adding/removing fields
- Data restructuring
- Moving from Supabase to Firebase

**Quick Start**:
```bash
# Create new migration
npm run migration:create add_new_field

# Test migration
npm run migration:test migration_20250101

# Deploy migration
./deploy_migration.sh migration_20250101 production
```

---

#### [`firebase_performance_agent.md`](./firebase_performance_agent.md)
**Purpose**: Firebase services performance optimization
- Firestore query optimization
- Cloud Functions monitoring
- Index management
- Cost optimization
- Real-time performance tracking

**When to Use**:
- Daily performance monitoring
- When costs increase
- Slow query detection
- Monthly optimization reviews

**Quick Start**:
```bash
# Monitor Firestore performance
firebase firestore:stats

# Analyze function performance
firebase functions:log --only processVoiceQuery

# Generate performance report
npm run performance:analyze
```

---

#### [`firebase_security_agent.md`](./firebase_security_agent.md)
**Purpose**: Firebase security auditing and hardening
- Security rules validation
- Authentication security
- Data protection compliance
- Rate limiting implementation
- Threat detection
- GDPR/CCPA compliance

**When to Use**:
- Before production deployment
- After security rules changes
- Monthly security audits
- Compliance reviews

**Quick Start**:
```bash
# Test security rules
npm test -- firestore.spec.ts

# Deploy rules
firebase deploy --only firestore:rules

# Security audit
./scripts/security_audit.sh
```

---

### 4. Content Generation Agent

#### [`content_generation_agent.md`](./content_generation_agent.md)
**Purpose**: Automated content creation and transformation
- GitaWisdom → Mindful Living transformation
- Remove religious references
- Generate voice-optimized content
- Documentation generation
- Multi-language localization

**When to Use**:
- Initial content migration
- Adding new life situations
- Documentation updates
- Localization generation

**Quick Start**:
```bash
# Transform GitaWisdom content
npm run content:transform

# Generate new situations
npm run content:generate --topic "work-stress"

# Validate content
npm run content:validate
```

---

## 🚀 Usage Patterns

### Pattern 1: Pre-Release Testing
Run before each release to ensure quality:

```bash
# Step 1: Code review
./agents/code_review_agent.sh

# Step 2: Android performance (parallel)
./agents/android_performance_agent.sh &

# Step 3: iOS performance (parallel)
./agents/ios_performance_agent.sh &

# Step 4: Firebase security audit
./agents/firebase_security_agent.sh

# Step 5: Wait for parallel tasks
wait

# Step 6: Generate release report
./generate_release_report.sh
```

### Pattern 2: Content Migration
Migrate content from GitaWisdom to Mindful Living:

```bash
# Step 1: Export GitaWisdom data
./export_gitawisdom_data.sh

# Step 2: Transform to secular content
npm run content:transform

# Step 3: Validate quality
npm run content:validate

# Step 4: Create Firebase migration
npm run migration:create import_content

# Step 5: Deploy to staging
./deploy_migration.sh import_content staging

# Step 6: Verify and deploy to production
./deploy_migration.sh import_content production
```

### Pattern 3: Performance Optimization
Monthly performance optimization cycle:

```bash
# Monday: Collect metrics
./agents/firebase_performance_agent.sh --collect-metrics

# Tuesday: Analyze Android performance
./agents/android_performance_agent.sh --full-analysis

# Wednesday: Analyze iOS performance
./agents/ios_performance_agent.sh --full-analysis

# Thursday: Implement optimizations
# (Manual development work)

# Friday: Verify improvements
./agents/run_all_performance_tests.sh
```

### Pattern 4: Security Hardening
Quarterly security review:

```bash
# Week 1: Security rules audit
./agents/firebase_security_agent.sh --audit-rules

# Week 2: Code security scan
./agents/code_review_agent.sh --security-focus

# Week 3: Penetration testing
./agents/firebase_security_agent.sh --pen-test

# Week 4: Implement fixes and re-audit
./agents/firebase_security_agent.sh --verify
```

---

## 🔄 Parallel Execution

### Run Multiple Agents Concurrently
```bash
#!/bin/bash
# run_parallel_agents.sh

echo "Starting parallel agent execution..."

# Background tasks
./agents/android_performance_agent.sh > android_report.txt 2>&1 &
ANDROID_PID=$!

./agents/ios_performance_agent.sh > ios_report.txt 2>&1 &
IOS_PID=$!

./agents/firebase_performance_agent.sh > firebase_report.txt 2>&1 &
FIREBASE_PID=$!

# Wait for all to complete
wait $ANDROID_PID
echo "✅ Android performance testing complete"

wait $IOS_PID
echo "✅ iOS performance testing complete"

wait $FIREBASE_PID
echo "✅ Firebase performance analysis complete"

# Aggregate reports
./scripts/aggregate_reports.sh android_report.txt ios_report.txt firebase_report.txt

echo "🎉 All agents completed!"
```

---

## 📊 Agent Coordination

### Master Workflow Script
```bash
#!/bin/bash
# master_workflow.sh

TASK=$1

case $TASK in
  "pre-release")
    echo "Running pre-release checks..."
    ./agents/code_review_agent.sh
    ./agents/android_performance_agent.sh &
    ./agents/ios_performance_agent.sh &
    ./agents/firebase_security_agent.sh
    wait
    ;;

  "content-migration")
    echo "Running content migration..."
    ./agents/content_generation_agent.sh --transform
    ./agents/firebase_migration_agent.sh --deploy
    ;;

  "performance-optimization")
    echo "Running performance optimization..."
    ./agents/android_performance_agent.sh &
    ./agents/ios_performance_agent.sh &
    ./agents/firebase_performance_agent.sh &
    wait
    ;;

  "security-audit")
    echo "Running security audit..."
    ./agents/firebase_security_agent.sh --full-audit
    ./agents/code_review_agent.sh --security-scan
    ;;

  *)
    echo "Usage: ./master_workflow.sh [pre-release|content-migration|performance-optimization|security-audit]"
    exit 1
    ;;
esac
```

---

## 🎯 Quick Reference

| Agent | Primary Use | Frequency | Duration |
|-------|-------------|-----------|----------|
| Android Performance | Testing on devices | Weekly | 1-2 hours |
| iOS Performance | App Store compliance | Weekly | 1-2 hours |
| Code Review | Quality assurance | Every commit | 2-5 minutes |
| Firebase Migration | Schema changes | As needed | 30-60 minutes |
| Firebase Performance | Cost & speed optimization | Daily | 10-15 minutes |
| Firebase Security | Security hardening | Monthly | 1-2 hours |
| Content Generation | Content creation | As needed | Variable |

---

## 📝 Best Practices

### 1. Agent Invocation
- Always run code review agent before committing
- Run performance agents in parallel when possible
- Test migrations in staging first
- Schedule security audits regularly

### 2. Report Management
- Save agent reports with timestamps
- Compare reports over time for trends
- Archive reports for compliance
- Share critical findings with team

### 3. Continuous Improvement
- Review agent recommendations weekly
- Implement high-priority optimizations first
- Track metrics over time
- Update agent configurations based on learnings

### 4. Integration with CI/CD
```yaml
# .github/workflows/agents.yml
name: Run Agents

on:
  pull_request:
    branches: [main]

jobs:
  code-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Code Review Agent
        run: ./agents/code_review_agent.sh

  security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Security Agent
        run: ./agents/firebase_security_agent.sh --quick-scan
```

---

## 🔧 Configuration

### Environment Variables
```bash
# .env
FIREBASE_PROJECT_ID=hub4apps-mindfulliving
ANDROID_DEVICE_ID=<device-id>
IOS_DEVICE_ID=<device-id>
PERFORMANCE_REPORT_PATH=./reports
ENABLE_PARALLEL_EXECUTION=true
```

### Agent Configuration
```yaml
# .claude/agents/config.yml
agents:
  code_review:
    enabled: true
    auto_run_on_commit: true
    fail_on_errors: true

  android_performance:
    enabled: true
    test_devices:
      - budget
      - mid_range
      - flagship

  ios_performance:
    enabled: true
    instruments_enabled: true

  firebase_security:
    enabled: true
    auto_audit: true
    alert_on_violations: true
```

---

## 🆘 Troubleshooting

### Agent Fails to Run
1. Check environment variables
2. Verify dependencies installed
3. Check file permissions
4. Review error logs in `./logs/`

### Parallel Execution Issues
1. Check available system resources
2. Reduce number of parallel agents
3. Increase timeout values
4. Check for port conflicts

### Report Generation Failures
1. Verify output directory exists
2. Check disk space
3. Ensure write permissions
4. Review report template

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf)
- [Android Performance Profiling](https://developer.android.com/studio/profile)
- [iOS Performance Optimization](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)

---

## 🤝 Contributing

To add a new agent:

1. Create agent markdown file in `.claude/agents/`
2. Follow existing agent structure
3. Add to this README
4. Create wrapper script if needed
5. Add to CI/CD pipeline
6. Document usage and examples

---

**Last Updated**: 2025-01-08
**Version**: 1.0.0
**Maintained By**: Mindful Living Development Team

---

## 📞 Support

For questions or issues with agents:
- Review agent documentation
- Check troubleshooting section
- Contact development team
- Open GitHub issue

Remember: Agents are tools to assist development, not replace developer judgment. Always review agent recommendations before implementation.
