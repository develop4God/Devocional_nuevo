# Smoke Test Documentation

## Overview

The smoke test (`test/smoke_onboarding_drawer_test.dart`) is a comprehensive integration test that validates the complete user journey through the app, from first launch through main functionality.

## What It Tests

### 1. Initial App Launch
- Firebase initialization (Core, Auth, Messaging, Remote Config)
- Localization service initialization
- Splash screen display and transitions
- Provider setup (DevocionalProvider, LocalizationProvider, ThemeBloc, etc.)

### 2. Onboarding Flow
- **Welcome Page**: Display and "Siguiente" button interaction
- **Theme Selection**: Theme chooser display and selection
- **Backup Configuration**: Google Drive setup or skip option
- **Completion Page**: Final screen and app entry

### 3. Main App
- Main app initialization
- DevocionalesPage loading
- Menu icon (hamburger) availability

### 4. Drawer Interaction
- Drawer opening via menu icon
- Drawer content verification ("Tu Biblia, tu estilo")
- Navigation menu functionality

## Mocked Services

The test includes comprehensive mocks for:

### Firebase Services
- `FirebaseCore`: App initialization
- `FirebaseAuth`: Anonymous authentication
- `FirebaseMessaging`: Push notifications
- `FirebaseRemoteConfig`: Feature flags (onboarding_enabled)

### Platform Channels
- `flutter_tts`: Text-to-speech functionality
- `path_provider`: File system access
- `google_sign_in`: Google authentication
- `url_launcher`: External URL handling
- `shared_preferences`: Local data persistence
- `local_auth`: Biometric authentication

### Configuration
- `SharedPreferences`: Onboarding state (not completed)
- `GoogleFonts`: Disabled runtime fetching for test environment

## Test Flow

```
1. App Start (main())
   ↓
2. Wait for initialization (1s + 10x200ms pumps)
   ↓
3. Wait for Onboarding Welcome (up to 20x500ms cycles)
   ↓
4. Tap "Siguiente" → Wait for Theme Selection
   ↓
5. Select theme → Tap "Siguiente"
   ↓
6. Wait for Backup Config → Tap "Configurar luego"
   ↓
7. Wait for Completion → Tap "Comenzar mi espacio con Dios"
   ↓
8. Wait for Main App (up to 20x500ms cycles)
   ↓
9. Tap Menu Icon
   ↓
10. Wait for Drawer → Verify content
```

## Running the Test

```bash
# Run the smoke test
flutter test test/smoke_onboarding_drawer_test.dart

# Run with verbose output
flutter test test/smoke_onboarding_drawer_test.dart --reporter=expanded
```

## Current Limitation

⚠️ **Google Fonts Asset Requirement**

The test currently cannot execute because `lib/splash_screen.dart` uses Google Fonts (specifically DancingScript-Bold) which throws an exception in the test environment when the font files are not available in assets.

### Error
```
Exception: GoogleFonts.config.allowRuntimeFetching is false but font DancingScript-Bold 
was not found in the application assets.
```

### Solutions

1. **Add Font to Assets** (Recommended)
   ```yaml
   # pubspec.yaml
   flutter:
     fonts:
       - family: DancingScript
         fonts:
           - asset: fonts/DancingScript-Bold.ttf
   ```

2. **Modify Splash Screen**
   Add error handling in `lib/splash_screen.dart` to fallback to default fonts when Google Fonts fail to load.

3. **Test-Specific Entry Point**
   Create a test-specific main() that bypasses the splash screen (violates minimal-change principle).

## Success Criteria

When the Google Fonts issue is resolved, the test validates:

✅ No application hangs or freezes
✅ No black screens or rendering issues  
✅ All onboarding steps load correctly
✅ Proper transitions between screens
✅ Main app loads without errors
✅ Drawer opens and displays content
✅ All services initialize properly
✅ No uncaught exceptions (except expected ones)

## Debugging

The test includes extensive debug output:

- `🟢` App start
- `⏳` Waiting for UI elements
- `✅` Successful steps
- `⚠️` Warnings or suppressed errors
- `👉` User actions (taps)
- `📊` Summary at completion

All print statements use emoji prefixes for easy filtering.

## Integration with CI/CD

Once the Google Fonts issue is resolved, this test can be integrated into CI/CD pipelines to:

- Validate PR changes don't break core flows
- Catch regressions in onboarding or navigation
- Ensure app boots correctly on different configurations
- Monitor for performance regressions (timeout tracking)

## Maintenance

Update this test when:

- Onboarding flow changes (new steps, different UI)
- Main app entry point changes
- Drawer content is modified
- New services are added that need mocking
- Firebase configuration changes

## Related Documentation

- [TEST_COVERAGE_REPORT.md](./TEST_COVERAGE_REPORT.md) - Overall test coverage
- [README.md](./README.md) - App features and functionality
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

---

**Last Updated**: 2024
**Status**: ⚠️  Blocked on Google Fonts asset dependency
**Mock Coverage**: 100% of required services
