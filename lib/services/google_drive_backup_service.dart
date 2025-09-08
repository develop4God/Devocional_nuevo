import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/spiritual_stats_model.dart';
import '../providers/devocional_provider.dart';
import 'spiritual_stats_service.dart';

/// Service for handling Google Drive backup functionality
class GoogleDriveBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  static const String _appFolderName = 'Devocionales Cristianos';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  final SpiritualStatsService _statsService = SpiritualStatsService();
  
  drive.DriveApi? _driveApi;
  bool _isInitialized = false;

  /// Check if user is signed in to Google Drive
  Future<bool> isSignedIn() async {
    try {
      final account = await _googleSignIn.isSignedIn();
      return account;
    } catch (e) {
      debugPrint('Error checking sign-in status: $e');
      return false;
    }
  }

  /// Get current user account info
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Sign in to Google Drive
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        await _initializeDriveApi(account);
      }
      return account;
    } catch (e) {
      debugPrint('Error signing in to Google Drive: $e');
      rethrow;
    }
  }

  /// Sign out from Google Drive
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _driveApi = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error signing out from Google Drive: $e');
      rethrow;
    }
  }

  /// Initialize Drive API with authenticated account
  Future<void> _initializeDriveApi(GoogleSignInAccount account) async {
    try {
      final headers = await account.authHeaders;
      final client = GoogleAuthClient(headers);
      _driveApi = drive.DriveApi(client);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Drive API: $e');
      rethrow;
    }
  }

  /// Ensure Drive API is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        throw Exception('No authenticated Google account found');
      }
      await _initializeDriveApi(account);
    }
  }

  /// Create backup data from selected options
  Future<Map<String, dynamic>> _createBackupData({
    required bool includeStats,
    required bool includeFavorites,
    required bool includePrayers,
    DevocionalProvider? devocionalProvider,
  }) async {
    final backupData = <String, dynamic>{
      'version': '2.0.0',
      'backup_type': 'google_drive',
      'created_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.44',
    };

    if (includeStats) {
      try {
        final stats = await _statsService.getStats();
        final readDates = await _getReadDatesAsStrings();
        backupData['spiritual_stats'] = {
          'stats': stats.toJson(),
          'read_dates': readDates,
        };
      } catch (e) {
        debugPrint('Error getting stats for backup: $e');
      }
    }

    if (includeFavorites && devocionalProvider != null) {
      try {
        final favorites = devocionalProvider.favoriteDevocionales;
        backupData['favorites'] = favorites.map((d) => d.toJson()).toList();
      } catch (e) {
        debugPrint('Error getting favorites for backup: $e');
      }
    }

    if (includePrayers) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final prayersJson = prefs.getString('saved_prayers');
        if (prayersJson != null) {
          backupData['prayers'] = json.decode(prayersJson);
        }
      } catch (e) {
        debugPrint('Error getting prayers for backup: $e');
      }
    }

    return backupData;
  }

  /// Get read dates as strings (helper method)
  Future<List<String>> _getReadDatesAsStrings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readDatesJson = prefs.getString('read_dates');
      if (readDatesJson != null) {
        final readDates = (json.decode(readDatesJson) as List)
            .map((dateStr) => DateTime.parse(dateStr))
            .toList();
        return readDates
            .map((date) => date.toIso8601String().split('T').first)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting read dates: $e');
      return [];
    }
  }

  /// Create and upload backup to Google Drive
  Future<String> createBackup({
    required bool includeStats,
    required bool includeFavorites,
    required bool includePrayers,
    DevocionalProvider? devocionalProvider,
  }) async {
    await _ensureInitialized();
    
    if (_driveApi == null) {
      throw Exception('Google Drive API not initialized');
    }

    try {
      // Create backup data
      final backupData = await _createBackupData(
        includeStats: includeStats,
        includeFavorites: includeFavorites,
        includePrayers: includePrayers,
        devocionalProvider: devocionalProvider,
      );

      // Create JSON content
      final jsonContent = const JsonEncoder.withIndent('  ').convert(backupData);
      final contentBytes = utf8.encode(jsonContent);

      // Generate filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final filename = 'devocionales_backup_$timestamp.json';

      // Create file metadata
      final driveFile = drive.File()
        ..name = filename
        ..parents = [await _getOrCreateAppFolder()];

      // Upload file
      final media = drive.Media(Stream.value(contentBytes), contentBytes.length);
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile.id ?? 'unknown';
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  /// Get or create app folder in Google Drive
  Future<String> _getOrCreateAppFolder() async {
    if (_driveApi == null) {
      throw Exception('Google Drive API not initialized');
    }

    try {
      // Search for existing folder
      const query = "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await _driveApi!.files.list(q: query);
      
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id!;
      }

      // Create new folder
      final folder = drive.File()
        ..name = _appFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id!;
    } catch (e) {
      debugPrint('Error getting/creating app folder: $e');
      rethrow;
    }
  }

  /// List available backups from Google Drive
  Future<List<drive.File>> listBackups() async {
    await _ensureInitialized();
    
    if (_driveApi == null) {
      throw Exception('Google Drive API not initialized');
    }

    try {
      final folderId = await _getOrCreateAppFolder();
      final query = "name contains 'devocionales_backup_' and parents in '$folderId' and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        pageSize: 20,
      );

      return fileList.files ?? [];
    } catch (e) {
      debugPrint('Error listing backups: $e');
      rethrow;
    }
  }
}

/// HTTP client for Google API authentication
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}