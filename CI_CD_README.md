# CI/CD Documentation

## Overview

This project uses GitHub Actions for Continuous Integration and Continuous Deployment.

## Workflows

### 1. CI (`.github/workflows/ci.yml`)

**Triggers:** Push to `main`, `develop` branches and Pull Requests

**Jobs:**
- **Test:** Runs unit tests, widget tests, integration tests with coverage
- **Build:** Builds Android APK and iOS simulator builds
- **Security:** Checks for outdated dependencies and security issues
- **Lint:** Custom linting rules (TODO comments, print statements)

### 2. CD (`.github/workflows/cd.yml`)

**Triggers:** Push to `main` branch and releases

**Jobs:**
- **Deploy Android:** Builds release APK and App Bundle
- **Deploy iOS:** Builds iOS release version
- **Notify:** Sends deployment status notifications

### 3. PR Check (`.github/workflows/pr-check.yml`)

**Triggers:** Pull Requests to `main`, `develop`

**Features:**
- Analyzes PR changes
- Comments on PR with analysis results
- Checks for breaking changes

## Local Development

### Pre-commit Checks

Run these commands before committing:

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test test_driver/

# With coverage
flutter test --coverage
```

## Configuration

### Flutter Version
Currently using Flutter 3.24.0 stable

### Java Version
Using Java 17 (Zulu distribution)

### Dependencies
- All dependencies are managed through `pubspec.yaml`
- CI automatically checks for outdated packages

## Artifacts

### CI Artifacts
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Debug iOS build: `build/ios/`
- Coverage report: `coverage/lcov.info`

### CD Artifacts
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- iOS build: `build/ios/`

## Troubleshooting

### Common Issues

1. **Build fails on CI but works locally**
   - Check Flutter version compatibility
   - Verify all dependencies are in `pubspec.yaml`

2. **Tests failing**
   - Run `flutter clean` and `flutter pub get`
   - Check test dependencies in `pubspec.yaml`

3. **Analysis errors**
   - Run `flutter analyze` locally
   - Fix linting issues before pushing

### Performance Optimization

- CI jobs run in parallel where possible
- Caching is used for dependencies
- Only necessary files are uploaded as artifacts

## Security

- No secrets are exposed in logs
- Dependencies are regularly checked for vulnerabilities
- Custom linting rules prevent common security issues

## Monitoring

- All workflow runs are logged in GitHub Actions
- Coverage reports are uploaded to Codecov
- Deployment status is notified to the team 