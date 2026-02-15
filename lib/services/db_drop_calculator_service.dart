import 'dart:math';

/// dB Drop Calculator Service
/// Handles conversions between dB changes, amplitude ratios, and percent drops
/// 
/// Commonly used in UT/NDT to understand signal attenuation and amplitude loss.
class DbDropCalculatorService {
  /// Converts dB change to amplitude ratio
  /// 
  /// Formula: ratio = 10^(ΔdB / 20)
  /// 
  /// Parameters:
  /// - [db]: dB change (can be negative for drop)
  /// 
  /// Returns a map containing:
  /// - 'ratio': The amplitude ratio (A2/A1)
  /// - 'remainingPercent': Remaining amplitude as percentage
  /// - 'dropPercent': Drop percentage
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Examples:
  /// - -6 dB → 0.501 ratio (50.1% remaining, 49.9% drop)
  /// - -12 dB → 0.251 ratio (25.1% remaining, 74.9% drop)
  /// - -20 dB → 0.100 ratio (10.0% remaining, 90.0% drop)
  static Map<String, dynamic> calculateRatioFromDb({
    required double db,
  }) {
    // Calculate amplitude ratio from dB (amplitude relationship: 20*log10)
    // ratio = 10^(dB / 20)
    final double ratio = pow(10, db / 20).toDouble();

    // Calculate percentages
    final double remainingPercent = ratio * 100;
    final double dropPercent = 100 - remainingPercent;

    return {
      'ratio': ratio,
      'remainingPercent': remainingPercent,
      'dropPercent': dropPercent,
      'error': null,
    };
  }

  /// Converts amplitude ratio to dB change
  /// 
  /// Formula: ΔdB = 20 × log₁₀(ratio)
  /// 
  /// Parameters:
  /// - [ratio]: Amplitude ratio (A2/A1) (must be > 0)
  /// 
  /// Returns a map containing:
  /// - 'db': The dB change
  /// - 'remainingPercent': Remaining amplitude as percentage
  /// - 'dropPercent': Drop percentage
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Examples:
  /// - 0.5 ratio → -6.02 dB (50% remaining, 50% drop)
  /// - 0.25 ratio → -12.04 dB (25% remaining, 75% drop)
  /// - 0.1 ratio → -20.00 dB (10% remaining, 90% drop)
  static Map<String, dynamic> calculateDbFromRatio({
    required double ratio,
  }) {
    // Validate input
    if (ratio <= 0) {
      return {
        'db': null,
        'remainingPercent': null,
        'dropPercent': null,
        'error': 'Amplitude ratio must be greater than 0',
      };
    }

    // Calculate dB from ratio (amplitude relationship: 20*log10)
    // dB = 20 * log10(ratio)
    final double db = 20 * log10(ratio);

    // Calculate percentages
    final double remainingPercent = ratio * 100;
    final double dropPercent = 100 - remainingPercent;

    return {
      'db': db,
      'remainingPercent': remainingPercent,
      'dropPercent': dropPercent,
      'error': null,
    };
  }

  /// Converts percent drop or remaining to dB and ratio
  /// 
  /// Parameters:
  /// - [remainingPercent]: Remaining amplitude percentage (0-100)
  /// 
  /// Returns a map containing:
  /// - 'db': The dB change
  /// - 'ratio': The amplitude ratio
  /// - 'remainingPercent': Remaining amplitude as percentage
  /// - 'dropPercent': Drop percentage
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateFromRemainingPercent({
    required double remainingPercent,
  }) {
    // Validate input
    if (remainingPercent < 0 || remainingPercent > 100) {
      return {
        'db': null,
        'ratio': null,
        'remainingPercent': null,
        'dropPercent': null,
        'error': 'Remaining percent must be between 0 and 100',
      };
    }

    if (remainingPercent == 0) {
      return {
        'db': null,
        'ratio': null,
        'remainingPercent': null,
        'dropPercent': null,
        'error': 'Remaining percent cannot be 0 (would result in -∞ dB)',
      };
    }

    // Calculate ratio from remaining percent
    final double ratio = remainingPercent / 100;

    // Calculate dB
    final double db = 20 * log10(ratio);

    // Calculate drop percent
    final double dropPercent = 100 - remainingPercent;

    return {
      'db': db,
      'ratio': ratio,
      'remainingPercent': remainingPercent,
      'dropPercent': dropPercent,
      'error': null,
    };
  }

  /// Converts drop percent to dB and ratio
  /// 
  /// Parameters:
  /// - [dropPercent]: Drop percentage (0-100)
  /// 
  /// Returns a map containing:
  /// - 'db': The dB change
  /// - 'ratio': The amplitude ratio
  /// - 'remainingPercent': Remaining amplitude as percentage
  /// - 'dropPercent': Drop percentage
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateFromDropPercent({
    required double dropPercent,
  }) {
    // Validate input
    if (dropPercent < 0 || dropPercent > 100) {
      return {
        'db': null,
        'ratio': null,
        'remainingPercent': null,
        'dropPercent': null,
        'error': 'Drop percent must be between 0 and 100',
      };
    }

    if (dropPercent == 100) {
      return {
        'db': null,
        'ratio': null,
        'remainingPercent': null,
        'dropPercent': null,
        'error': 'Drop percent cannot be 100 (would result in -∞ dB)',
      };
    }

    // Calculate remaining percent
    final double remainingPercent = 100 - dropPercent;

    // Use existing method
    return calculateFromRemainingPercent(remainingPercent: remainingPercent);
  }

  /// Gets quick reference values for common dB drops
  /// 
  /// Returns a list of maps containing:
  /// - 'db': The dB change
  /// - 'ratio': The amplitude ratio
  /// - 'remainingPercent': Remaining amplitude as percentage
  /// - 'dropPercent': Drop percentage
  static List<Map<String, dynamic>> getQuickReferenceValues() {
    final commonDbValues = [-1.0, -3.0, -6.0, -10.0, -12.0, -20.0];
    
    return commonDbValues.map((db) {
      final result = calculateRatioFromDb(db: db);
      return {
        'db': db,
        'ratio': result['ratio'],
        'remainingPercent': result['remainingPercent'],
        'dropPercent': result['dropPercent'],
      };
    }).toList();
  }

  /// Helper function to calculate log base 10
  static double log10(double x) {
    return log(x) / ln10;
  }

  /// Validates ratio input
  static String? validateRatio({required double ratio}) {
    if (ratio <= 0) {
      return 'Amplitude ratio must be greater than 0';
    }
    return null;
  }

  /// Validates percent input (0-100)
  static String? validatePercent({required double percent, required String fieldName}) {
    if (percent < 0 || percent > 100) {
      return '$fieldName must be between 0 and 100';
    }
    return null;
  }
}
