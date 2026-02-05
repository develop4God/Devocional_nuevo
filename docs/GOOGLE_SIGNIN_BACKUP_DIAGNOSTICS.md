# Google Sign-In Backup Diagnostics for Devocional App

**Created:** February 5, 2026  
**Purpose:** Diagnose and resolve Google Drive backup authentication failures  
**Status:** Active Investigation

---

## Current Situation Analysis

Based on the codebase review, the Devocional app has a fully implemented Google Drive backup system with comprehensive error logging. However, users are experiencing authentication failures when attempting to backup their spiritual data (devotionals, prayers, thanksgivings, and spiritual statistics).

### What We Know

**✅ Code Implementation Status:**
- GoogleDriveAuthService is properly implemented with singleton pattern
- Extensive debug logging at every authentication step
- Error handling covers multiple failure scenarios
- Backup service ready to handle data compression and restore
- Android manifest properly configured for Google Sign-In activities

**⚠️ Configuration Gaps Identified:**
- Essential platform configuration files missing from repository (correctly excluded via .gitignore)
- iOS platform lacks required URL scheme handlers  
- SHA certificate fingerprints may need verification

---

## Diagnostic Steps for This Specific App

### Step 1: Verify Debug Logs Show Detailed Error Information

The GoogleDriveAuthService in this app outputs extensive diagnostic information. When a user reports backup failure, collect these specific log messages:

**Key Log Prefixes to Search:**
- Lines starting with `🔑 [DEBUG]` - Sign-in flow tracking
- Lines starting with `❌ [DEBUG]` - Error details with context
- Lines starting with `🔐 [DEBUG]` - Auth client creation issues
- Lines starting with `📁 [DEBUG]` - Drive API initialization problems

**Critical Error Codes This App Checks:**
- `ApiException: 10` indicates DEVELOPER_ERROR (configuration mismatch)
- `OAuth not configured` means missing OAuth client in platform config
- `CONFIGURATION_NOT_FOUND` suggests platform setup incomplete

### Step 2: Validate Platform-Specific Requirements

**For Android (Devocional Package: com.develop4god.devocional_nuevo):**

The app expects these elements to be properly configured:
1. Platform configuration file in `android/app/src/main/` directory
2. SHA-1 certificate fingerprint registered for the exact package name
3. OAuth 2.0 Client IDs created for Android platform
4. Proper signing configuration matching registered certificates

**For iOS:**

The app currently lacks these required elements in Info.plist:
1. URL scheme handlers for OAuth callback
2. Reversed client ID configuration  
3. Client ID specification

### Step 3: Examine App-Specific Authentication Flow

This Devocional app uses a unique authentication pattern:

1. **Singleton Pattern:** Only one GoogleDriveAuthService instance exists
2. **Silent Re-authentication:** App attempts automatic re-auth when client expires
3. **Extension Method:** Uses `authenticatedClient()` extension on GoogleSignIn
4. **State Persistence:** Saves sign-in status to SharedPreferences

**Potential Failure Points Unique to This Implementation:**
- Race condition if multiple backups triggered simultaneously
- Auth client recreation might fail if credentials expired
- State inconsistency between SharedPreferences and actual Google account status

### Step 4: Test Using Debug Page Feature

This app has a special debug page (accessible in debug builds or with developer mode) that provides direct access to backup settings. Use this to:

1. Enable detailed console logging during authentication attempts
2. Test sign-in flow in isolation from automatic backup triggers
3. Verify error messages match expected patterns in the code
4. Check if manual backup succeeds vs automatic scheduled backup

### Step 5: Verify Google Console Configuration Matches App Requirements

**Critical Matching Points:**

The app's AndroidManifest.xml declares:
- Package namespace (check build.gradle.kts for exact value)
- Required Google Play Services activities
- Necessary permissions already declared

**What Must Match in Google Console:**
- Application package name exactly as declared in gradle configuration
- SHA-1 fingerprint from the keystore actually used for signing
- OAuth consent screen configuration includes Drive API scopes
- Both scopes this app requires are authorized

---

## Troubleshooting Decision Tree

**Issue: "Backup Failed" Message**

→ **Check 1:** Are debug logs showing sign-in initiation?  
  - NO: Backup trigger logic issue, not authentication problem  
  - YES: Proceed to Check 2

→ **Check 2:** Does log show "GoogleSignIn es null: true"?  
  - YES: Service initialization failed - platform config missing  
  - NO: Proceed to Check 3

→ **Check 3:** Does log show "No authenticated client"?  
  - YES: OAuth configuration incomplete on platform  
  - NO: Proceed to Check 4

→ **Check 4:** Does log show "ApiException: 10"?  
  - YES: SHA-1 fingerprint mismatch or package name incorrect  
  - NO: Check for other specific error messages

→ **Check 5:** Does log show sign-in succeeded but backup still fails?  
  - YES: Drive API permissions issue or folder creation problem  
  - NO: Review complete log sequence for unexpected errors

---

## App-Specific Backup Data Structure

When backup succeeds, this app creates:

**Folder Structure:**
- Creates or finds folder named "Devocional Backup"
- Stores single file named "devocional_backup.json"
- Optional compression based on user preference

**Data Included (configurable by user):**
- Spiritual statistics (reading streaks, prayer counts)
- Favorite devotional content references
- Saved personal prayers
- Saved thanksgivings
- Metadata: timestamp, app version, compression status

**Important:** First backup attempt creates folder, subsequent backups update existing file. The update operation specifically does NOT include parents field to avoid API errors.

---

## Resolution Verification Checklist

After applying configuration fixes, verify:

- [ ] App successfully calls `_googleSignIn.signIn()` without exceptions
- [ ] Log shows "Google Drive sign-in successful" with user email
- [ ] Log shows "AuthClient creado exitosamente usando extension"
- [ ] SharedPreferences correctly stores signed-in state
- [ ] Manual backup from debug page completes successfully
- [ ] Automatic backup respects frequency settings (daily/manual)
- [ ] Backup file appears in user's Google Drive folder
- [ ] Restore functionality can read the created backup file
- [ ] Sign-out properly clears authentication state

---

## Understanding This App's Error Messages

The GoogleDriveAuthService provides Spanish language debug output mixed with English. Key translations:

- "Verificando si usuario está signed in" = Checking if user is signed in
- "Llamando a _googleSignIn.signIn()" = Calling sign-in method
- "Usuario obtenido" = User obtained successfully  
- "Limpiando estado" = Clearing state
- "Recreación falló" = Recreation failed

These messages help trace exactly where in the authentication flow the failure occurs.

---

## Next Steps for Resolution

Based on where the diagnostic flow indicates failure, the solution will involve updating platform configuration files that are intentionally excluded from version control for security. The specific files and values needed depend on the exact error messages observed in the app logs.

**Important:** Never commit sensitive configuration files or certificates to the repository. The .gitignore is correctly configured to protect these.

---

## Support Resources Specific to This Implementation

- Review `lib/services/google_drive_auth_service.dart` lines 57-147 for complete error handling
- Check `lib/services/google_drive_backup_service.dart` lines 249-339 for backup creation logic
- Examine `lib/blocs/backup_bloc.dart` for event handling and state management
- Test files: `test/unit/services/google_drive_backup_service_working_test.dart`
- Test flows: `test/unit/blocs/backup_bloc_user_flows_test.dart`

