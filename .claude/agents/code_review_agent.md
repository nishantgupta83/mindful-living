# Code Review Agent

## 🎯 Purpose
Automated code quality analysis and review for Mindful Living app. This agent performs comprehensive static analysis, identifies code smells, ensures best practices, and maintains code quality standards.

## 🔍 Responsibilities

### 1. Code Quality Analysis
- Dart/Flutter best practices compliance
- Code complexity analysis
- Code smell detection
- Dead code identification
- Unused imports and variables
- Security vulnerability scanning
- Performance anti-patterns

### 2. Architecture Review
- SOLID principles compliance
- Design pattern usage
- Separation of concerns
- Dependency injection patterns
- State management best practices
- File organization and structure

### 3. Flutter-Specific Checks
- Widget composition quality
- Build method optimization
- State management patterns
- Navigation implementation
- Platform channel usage
- Plugin integration quality

### 4. Testing Coverage
- Unit test coverage
- Widget test coverage
- Integration test coverage
- Test quality assessment
- Mock usage patterns

## 📋 Automated Checks

### Phase 1: Static Analysis
```bash
# Run Flutter analyzer with strict mode
flutter analyze --fatal-infos --fatal-warnings

# Custom analysis options
flutter analyze --no-congratulate --no-preamble
```

### Phase 2: Dart Code Metrics
```bash
# Install dart code metrics
flutter pub global activate dart_code_metrics

# Run metrics analysis
flutter pub global run dart_code_metrics:metrics analyze lib

# Check for specific thresholds
flutter pub global run dart_code_metrics:metrics check-unused-files lib
flutter pub global run dart_code_metrics:metrics check-unused-code lib
```

### Phase 3: Linting Rules
```yaml
# Add to analysis_options.yaml

include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

  errors:
    # Treat all warnings as errors
    missing_required_param: error
    missing_return: error
    dead_code: error
    unused_element: error
    unused_import: error
    unused_local_variable: error

  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/generated/**"
    - "test/**/*.mocks.dart"

linter:
  rules:
    # Style rules
    - always_declare_return_types
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_catches_without_on_clauses
    - avoid_catching_errors
    - avoid_double_and_int_checks
    - avoid_empty_else
    - avoid_equals_and_hash_code_on_mutable_classes
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_print
    - avoid_redundant_argument_values
    - avoid_relative_lib_imports
    - avoid_renaming_method_parameters
    - avoid_return_types_on_setters
    - avoid_returning_null_for_void
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_unnecessary_containers
    - avoid_unused_constructor_parameters
    - avoid_void_async
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cancel_subscriptions
    - cascade_invocations
    - constant_identifier_names
    - control_flow_in_finally
    - curly_braces_in_flow_control_structures
    - depend_on_referenced_packages
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - exhaustive_cases
    - file_names
    - hash_and_equals
    - implementation_imports
    - iterable_contains_unrelated_type
    - leading_newlines_in_multiline_strings
    - library_names
    - library_prefixes
    - list_remove_unrelated_type
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - no_logic_in_create_state
    - null_closures
    - omit_local_variable_types
    - one_member_abstracts
    - only_throw_errors
    - overridden_fields
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - parameter_assignments
    - prefer_adjacent_string_concatenation
    - prefer_asserts_in_initializer_lists
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_function_declarations_over_variables
    - prefer_generic_function_type_aliases
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_iterable_whereType
    - prefer_null_aware_operators
    - prefer_relative_imports
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - prefer_void_to_null
    - provide_deprecation_message
    - recursive_getters
    - sized_box_for_whitespace
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - sort_unnamed_constructors_first
    - test_types_in_equals
    - throw_in_finally
    - type_annotate_public_apis
    - type_init_formals
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_statements
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_key_in_widget_constructors
    - use_late_for_private_fields_and_variables
    - use_rethrow_when_possible
    - use_setters_to_change_properties
    - use_string_buffers
    - use_to_and_as_if_applicable
    - valid_regexps
    - void_checks
```

### Phase 4: Security Scanning
```bash
# Check for hardcoded secrets
grep -r "api_key\|apiKey\|API_KEY" lib/ --exclude-dir=generated
grep -r "password\|secret\|token" lib/ --exclude-dir=generated

# Check for debugging code left in
grep -r "print(" lib/
grep -r "debugPrint" lib/
grep -r "// TODO" lib/
grep -r "// FIXME" lib/
```

### Phase 5: Import Analysis
```bash
# Check for circular dependencies
flutter pub run dependency_validator

# Find unused dependencies
flutter pub run dependency_validator --ignore=dev
```

## 🔬 Review Procedures

### Procedure 1: Pre-Commit Review
```bash
#!/bin/bash
# File: .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Format check
echo "Checking code formatting..."
if ! flutter format --set-exit-if-changed lib/ test/; then
    echo "❌ Code is not formatted. Run: flutter format ."
    exit 1
fi

# Analysis
echo "Running static analysis..."
if ! flutter analyze --no-fatal-infos; then
    echo "❌ Static analysis failed"
    exit 1
fi

# Unit tests
echo "Running unit tests..."
if ! flutter test; then
    echo "❌ Unit tests failed"
    exit 1
fi

echo "✅ All pre-commit checks passed"
exit 0
```

### Procedure 2: Pull Request Review Checklist
```markdown
## Code Review Checklist

### General Code Quality
- [ ] Code follows Dart style guide
- [ ] No commented-out code
- [ ] No debug print statements
- [ ] Proper error handling
- [ ] No hardcoded strings (use l10n)
- [ ] No magic numbers (use constants)
- [ ] Clear and descriptive naming
- [ ] Appropriate comments for complex logic

### Flutter Specific
- [ ] Widgets are properly composed (not too deep)
- [ ] BuildContext is not used across async gaps
- [ ] Keys are used where necessary
- [ ] const constructors used where possible
- [ ] No unnecessary rebuilds
- [ ] Proper state management
- [ ] Platform-specific code is abstracted
- [ ] Responsive design considerations

### Performance
- [ ] No expensive operations in build()
- [ ] Lists use proper builders (ListView.builder)
- [ ] Images are properly cached
- [ ] No memory leaks (dispose controllers)
- [ ] Async operations are properly handled
- [ ] No blocking operations on main thread

### Testing
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Test coverage > 80%
- [ ] Edge cases are tested
- [ ] Mocks are used appropriately

### Security
- [ ] No sensitive data in logs
- [ ] User input is validated
- [ ] API keys are in environment variables
- [ ] Proper authentication checks
- [ ] No SQL injection vulnerabilities
- [ ] Secure network communication (HTTPS)

### Documentation
- [ ] Public APIs are documented
- [ ] Complex algorithms explained
- [ ] README updated if needed
- [ ] CHANGELOG updated
- [ ] Breaking changes noted

### Git
- [ ] Commit messages are clear
- [ ] No large binary files
- [ ] No sensitive data committed
- [ ] Proper branch naming
```

### Procedure 3: Complexity Analysis
```dart
// Run cyclomatic complexity check

// Tool: dart_code_metrics
// High complexity (>10) indicates need for refactoring

class ComplexityExample {
  // Cyclomatic Complexity: 8
  // This method should be refactored
  int calculateRisk(User user, Transaction transaction) {
    if (user.age < 18) {
      if (transaction.amount > 1000) {
        if (transaction.isInternational) {
          return 10;
        }
        return 8;
      }
      return 5;
    } else if (user.age > 65) {
      if (transaction.amount > 5000) {
        return 7;
      }
      return 4;
    } else {
      if (transaction.isInternational && transaction.amount > 10000) {
        return 9;
      }
      return 3;
    }
  }

  // Better: Refactored with lower complexity
  int calculateRiskRefactored(User user, Transaction transaction) {
    final ageRisk = _calculateAgeRisk(user.age);
    final amountRisk = _calculateAmountRisk(transaction.amount);
    final internationalRisk = transaction.isInternational ? 2 : 0;

    return ageRisk + amountRisk + internationalRisk;
  }
}
```

### Procedure 4: Architecture Review
```dart
// Check for proper layering and separation of concerns

// ✅ GOOD: Clear separation
lib/
  features/
    dashboard/
      data/
        models/
        repositories/
        data_sources/
      domain/
        entities/
        use_cases/
      presentation/
        pages/
        widgets/
        providers/

// ❌ BAD: Mixed responsibilities
lib/
  screens/
    dashboard.dart  // Contains business logic, UI, and data access
```

### Procedure 5: Performance Anti-Pattern Detection
```dart
// Common Flutter performance issues

// ❌ BAD: Expensive operation in build()
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = expensiveCalculation(); // Called on every rebuild!
    return Text(data);
  }
}

// ✅ GOOD: Cache expensive operations
class GoodWidget extends StatefulWidget {
  @override
  _GoodWidgetState createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  late String _data;

  @override
  void initState() {
    super.initState();
    _data = expensiveCalculation(); // Called once
  }

  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}

// ❌ BAD: Not using const constructors
Widget badList() {
  return ListView(
    children: [
      ListTile(title: Text('Item 1')),
      ListTile(title: Text('Item 2')),
    ],
  );
}

// ✅ GOOD: Using const constructors
Widget goodList() {
  return ListView(
    children: const [
      ListTile(title: Text('Item 1')),
      ListTile(title: Text('Item 2')),
    ],
  );
}

// ❌ BAD: Creating new instances in build
class BadWidgetWithCallback extends StatelessWidget {
  final Function(String) onTap;

  const BadWidgetWithCallback({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap('value'), // New closure created on every build
      child: Text('Tap me'),
    );
  }
}

// ✅ GOOD: Reusing callbacks
class GoodWidgetWithCallback extends StatelessWidget {
  final VoidCallback onTap;

  const GoodWidgetWithCallback({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Reuses the same callback
      child: const Text('Tap me'),
    );
  }
}
```

## 📊 Code Quality Report Template

```markdown
# Code Review Report
**Date**: [DATE]
**Reviewer**: [Automated/Manual]
**Commit/PR**: [COMMIT_HASH or PR_NUMBER]
**Files Changed**: [COUNT]
**Lines Added**: [COUNT]
**Lines Removed**: [COUNT]

## Summary
- ✅/⚠️/❌ Overall Code Quality Rating
- Critical Issues: [COUNT]
- Warnings: [COUNT]
- Suggestions: [COUNT]

## Static Analysis Results

### Analyzer Warnings
```
Total Issues: [COUNT]
Errors: [COUNT]
Warnings: [COUNT]
Infos: [COUNT]
```

#### Critical Issues 🔴
1. **[FILE_PATH:LINE]**: [ISSUE_DESCRIPTION]
   - Type: Error
   - Severity: Critical
   - Action Required: [FIX_DESCRIPTION]

#### Warnings 🟡
1. **[FILE_PATH:LINE]**: [ISSUE_DESCRIPTION]
   - Type: Warning
   - Severity: Medium
   - Suggestion: [IMPROVEMENT]

### Code Metrics

#### Complexity Analysis
| File | Cyclomatic Complexity | Lines of Code | Maintainability Index |
|------|----------------------|---------------|----------------------|
| [FILE] | [VALUE] | [VALUE] | [VALUE]/100 |

Files with High Complexity (>10):
- [FILE_PATH]: Complexity [VALUE] - **Needs Refactoring**

#### Code Duplication
| Location | Duplicated Lines | Recommendation |
|----------|-----------------|----------------|
| [FILES] | [COUNT] | Extract to shared utility |

#### Test Coverage
```
Overall Coverage: [PERCENTAGE]%
Line Coverage: [PERCENTAGE]%
Branch Coverage: [PERCENTAGE]%
```

Files with Low Coverage (<80%):
- [FILE_PATH]: [PERCENTAGE]% - **Add More Tests**

### Security Scan Results

#### Potential Security Issues
- [ ] No hardcoded API keys found
- [ ] No passwords in source code
- [ ] No print statements with sensitive data
- [ ] Proper input validation
- [ ] HTTPS used for all network calls

Issues Found:
1. **[FILE_PATH:LINE]**: [SECURITY_ISSUE]
   - Risk Level: High/Medium/Low
   - Action: [REMEDIATION_STEPS]

### Flutter-Specific Analysis

#### Widget Quality
- [ ] Proper const constructor usage
- [ ] No unnecessary StatefulWidgets
- [ ] BuildContext not used across async gaps
- [ ] Keys used where needed
- [ ] Proper disposal of controllers

Issues:
1. **[FILE_PATH]**: [ISSUE]

#### Performance Anti-Patterns
- [ ] No expensive operations in build()
- [ ] ListView.builder used for long lists
- [ ] Images properly cached
- [ ] No memory leaks

Issues:
1. **[FILE_PATH]**: [ANTI_PATTERN]

### Architecture Review

#### Code Organization
- ✅/❌ Proper feature-based structure
- ✅/❌ Clear separation of concerns
- ✅/❌ Consistent naming conventions
- ✅/❌ Appropriate abstraction levels

#### Design Patterns
- State Management: [PATTERN] - ✅/⚠️
- Dependency Injection: [PATTERN] - ✅/⚠️
- Repository Pattern: ✅/❌
- SOLID Principles: ✅/⚠️/❌

### Dependencies

#### Outdated Packages
| Package | Current | Latest | Update Recommended |
|---------|---------|--------|-------------------|
| [NAME] | [VERSION] | [VERSION] | Yes/No |

#### Unused Dependencies
- [PACKAGE_NAME] - **Remove from pubspec.yaml**

## Recommendations

### High Priority
1. **[RECOMMENDATION]**
   - Impact: [DESCRIPTION]
   - Effort: Low/Medium/High
   - Files Affected: [COUNT]

### Medium Priority
[...]

### Low Priority (Code Quality Improvements)
[...]

## Files Reviewed

### New Files
- [FILE_PATH] - [STATUS: ✅/⚠️/❌]

### Modified Files
- [FILE_PATH] - [STATUS: ✅/⚠️/❌]
  - Changes: [DESCRIPTION]
  - Issues: [COUNT]

### Deleted Files
- [FILE_PATH] - [REASON]

## Test Results
```
Tests Run: [COUNT]
Passed: [COUNT]
Failed: [COUNT]
Skipped: [COUNT]

Duration: [TIME]
```

## Approval Status
- [ ] Code quality meets standards
- [ ] All critical issues resolved
- [ ] Security review passed
- [ ] Tests pass and coverage adequate
- [ ] Documentation updated
- [ ] Ready for merge

**Reviewer Decision**: APPROVED / REQUEST CHANGES / REJECTED

**Comments**: [ADDITIONAL_NOTES]
```

## 🚀 Quick Commands

```bash
# Complete code review
./scripts/code_review.sh

# Quick quality check
flutter analyze && flutter test

# Format all code
flutter format .

# Run comprehensive analysis
dart_code_metrics analyze lib --reporter=html
```

## 🎯 Quality Gates

### Pre-Commit Gates (Must Pass)
- [ ] Code is properly formatted
- [ ] No analyzer errors
- [ ] All tests pass
- [ ] No TODO/FIXME in committed code

### Pre-Merge Gates (Must Pass)
- [ ] PR review approved
- [ ] CI/CD pipeline passes
- [ ] Test coverage > 80%
- [ ] No high complexity methods (>10)
- [ ] No security vulnerabilities
- [ ] Documentation updated

### Pre-Release Gates (Must Pass)
- [ ] All features tested
- [ ] Performance benchmarks met
- [ ] Security audit passed
- [ ] App Store guidelines met
- [ ] Crash-free rate > 99.5%

## 📚 Resources
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Dart Code Metrics](https://dartcodemetrics.dev/)
- [SonarQube for Flutter](https://docs.sonarqube.org/latest/analysis/languages/dart/)

## 🔄 Continuous Code Quality

### CI/CD Integration
```yaml
# .github/workflows/code_review.yml
name: Code Review

on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Format check
        run: flutter format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Check coverage
        run: |
          lcov --summary coverage/lcov.info
          # Fail if coverage < 80%

      - name: Code metrics
        run: flutter pub run dart_code_metrics:metrics analyze lib

      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: code-review-report
          path: |
            coverage/
            metrics/
```

---

**Note**: This agent should run automatically on every commit and PR. Manual review still required for architecture decisions and complex logic.
