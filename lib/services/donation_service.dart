// lib/services/donation_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling Google Play Billing donations and badge management
class DonationService {
  static const String _unlockedBadgesKey = 'unlocked_badges';
  static const String _donationHistoryKey = 'donation_history';

  // Consumable product IDs for Google Play
  static const List<String> _productIds = [
    'donation_1_usd',
    'donation_5_usd',
    'donation_10_usd',
    'donation_20_usd',
  ];

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Private constructor for singleton
  DonationService._privateConstructor();
  static final DonationService _instance =
      DonationService._privateConstructor();
  factory DonationService() => _instance;

  /// Initialize the donation service
  Future<void> initialize() async {
    debugPrint('🔄 Initializing DonationService...');

    // Check if in-app purchases are available
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('❌ In-app purchases not available on this device');
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('❌ Purchase stream error: $error');
      },
    );

    debugPrint('✅ DonationService initialized successfully');
  }

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
    debugPrint('🗑️ DonationService disposed');
  }

  /// Get available donation products
  Future<List<ProductDetails>> getAvailableProducts() async {
    try {
      debugPrint('🔍 Fetching available donation products...');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        debugPrint('❌ Error fetching products: ${response.error}');
        return [];
      }

      debugPrint(
          '✅ Found ${response.productDetails.length} available products');
      return response.productDetails;
    } catch (e) {
      debugPrint('❌ Exception fetching products: $e');
      return [];
    }
  }

  /// Purchase a donation product
  Future<bool> purchaseProduct(String productId,
      {String? selectedBadge}) async {
    try {
      debugPrint('🛒 Initiating purchase for product: $productId');

      final products = await getAvailableProducts();
      final ProductDetails? product =
          products.cast<ProductDetails?>().firstWhere(
                (p) => p?.id == productId,
                orElse: () => null,
              );

      if (product == null) {
        debugPrint('❌ Product not found: $productId');
        return false;
      }

      // Store selected badge for when purchase completes
      if (selectedBadge != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_badge_$productId', selectedBadge);
        debugPrint(
            '💾 Stored pending badge: $selectedBadge for product: $productId');
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('📝 Purchase initiated: $success');
      return success;
    } catch (e) {
      debugPrint('❌ Exception during purchase: $e');
      return false;
    }
  }

  /// Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint(
          '📦 Processing purchase: ${purchaseDetails.productID}, status: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchaseDetails.error}');
          await _cleanupPendingBadge(purchaseDetails.productID);
          break;
        case PurchaseStatus.canceled:
          debugPrint('⏹️ Purchase canceled: ${purchaseDetails.productID}');
          await _cleanupPendingBadge(purchaseDetails.productID);
          break;
        case PurchaseStatus.pending:
          debugPrint('⏳ Purchase pending: ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.restored:
          // Not applicable for consumable products
          break;
      }

      // Complete the purchase (important for consumable products)
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        debugPrint('✅ Purchase completed: ${purchaseDetails.productID}');
      }
    }
  }

  /// Handle successful purchase completion
  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchaseDetails) async {
    try {
      debugPrint(
          '🎉 Processing successful purchase: ${purchaseDetails.productID}');

      // Record donation in history
      await _recordDonation(purchaseDetails);

      // Unlock the selected badge
      final prefs = await SharedPreferences.getInstance();
      final String? pendingBadge =
          prefs.getString('pending_badge_${purchaseDetails.productID}');

      if (pendingBadge != null) {
        await unlockBadge(pendingBadge);
        await prefs.remove('pending_badge_${purchaseDetails.productID}');
        debugPrint('🏅 Badge unlocked: $pendingBadge');
      } else {
        debugPrint(
            '⚠️ No pending badge found for purchase: ${purchaseDetails.productID}');
      }
    } catch (e) {
      debugPrint('❌ Error handling successful purchase: $e');
    }
  }

  /// Clean up pending badge on failed/canceled purchase
  Future<void> _cleanupPendingBadge(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_badge_$productId');
      debugPrint('🧹 Cleaned up pending badge for product: $productId');
    } catch (e) {
      debugPrint('❌ Error cleaning up pending badge: $e');
    }
  }

  /// Record donation in history
  Future<void> _recordDonation(PurchaseDetails purchaseDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_donationHistoryKey);

      List<Map<String, dynamic>> history = [];
      if (historyJson != null) {
        history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      }

      history.add({
        'product_id': purchaseDetails.productID,
        'transaction_date': DateTime.now().toIso8601String(),
        'purchase_id': purchaseDetails.purchaseID,
      });

      await prefs.setString(_donationHistoryKey, json.encode(history));
      debugPrint('📊 Donation recorded in history');
    } catch (e) {
      debugPrint('❌ Error recording donation: $e');
    }
  }

  /// Get available badge images from assets
  Future<List<String>> getAvailableBadges() async {
    try {
      // For now, return a list of known badge assets
      // This could be enhanced to dynamically scan the assets directory
      const List<String> badges = [
        'assets/badges/badge_1.png',
        'assets/badges/badge_2.png',
        'assets/badges/badge_3.png',
        'assets/badges/badge_4.png',
        'assets/badges/badge_5.png',
      ];

      debugPrint('🏅 Available badges: ${badges.length}');
      return badges;
    } catch (e) {
      debugPrint('❌ Error getting available badges: $e');
      return [];
    }
  }

  /// Unlock a badge for the user
  Future<void> unlockBadge(String badgePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? unlockedJson = prefs.getString(_unlockedBadgesKey);

      List<String> unlockedBadges = [];
      if (unlockedJson != null) {
        unlockedBadges = List<String>.from(json.decode(unlockedJson));
      }

      if (!unlockedBadges.contains(badgePath)) {
        unlockedBadges.add(badgePath);
        await prefs.setString(_unlockedBadgesKey, json.encode(unlockedBadges));
        debugPrint('🏅 Badge unlocked and saved: $badgePath');
      } else {
        debugPrint('⚠️ Badge already unlocked: $badgePath');
      }
    } catch (e) {
      debugPrint('❌ Error unlocking badge: $e');
    }
  }

  /// Get user's unlocked badges
  Future<List<String>> getUnlockedBadges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? unlockedJson = prefs.getString(_unlockedBadgesKey);

      if (unlockedJson != null) {
        final List<String> badges =
            List<String>.from(json.decode(unlockedJson));
        debugPrint('🏅 User has ${badges.length} unlocked badges');
        return badges;
      }

      debugPrint('📭 No unlocked badges found');
      return [];
    } catch (e) {
      debugPrint('❌ Error getting unlocked badges: $e');
      return [];
    }
  }

  /// Check if a specific badge is unlocked
  Future<bool> isBadgeUnlocked(String badgePath) async {
    try {
      final unlockedBadges = await getUnlockedBadges();
      return unlockedBadges.contains(badgePath);
    } catch (e) {
      debugPrint('❌ Error checking badge unlock status: $e');
      return false;
    }
  }

  /// Get donation history
  Future<List<Map<String, dynamic>>> getDonationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_donationHistoryKey);

      if (historyJson != null) {
        final List<Map<String, dynamic>> history =
            List<Map<String, dynamic>>.from(json.decode(historyJson));
        debugPrint('📊 Found ${history.length} donations in history');
        return history;
      }

      debugPrint('📭 No donation history found');
      return [];
    } catch (e) {
      debugPrint('❌ Error getting donation history: $e');
      return [];
    }
  }

  /// Get total number of donations made
  Future<int> getTotalDonations() async {
    try {
      final history = await getDonationHistory();
      return history.length;
    } catch (e) {
      debugPrint('❌ Error getting total donations: $e');
      return 0;
    }
  }
}
