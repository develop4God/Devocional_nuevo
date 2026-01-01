/// Configuration constants for devotional content management
///
/// This file centralizes year-related constants for devotional loading strategy.
/// The BASE_YEAR approach ensures users always have access to foundational content
/// regardless of when they install the app.
class DevotionalConfig {
  /// Base year for devotional content (foundational year always loaded)
  ///
  /// This is the year that will ALWAYS be loaded first, regardless of the current date.
  /// - New users installing in 2026+ will still get 2025 content
  /// - Ensures access to complete 365-day devotional cycle
  /// - On-demand loading adds subsequent years as needed
  // ignore: constant_identifier_names
  static const int BASE_YEAR = 2025;

  /// Threshold for triggering on-demand loading of next year
  ///
  /// When user approaches devotional #350 of current year, next year loads automatically
  // ignore: constant_identifier_names
  static const int ON_DEMAND_THRESHOLD = 350;
}
