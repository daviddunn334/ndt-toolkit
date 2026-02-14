import 'dart:math';

/// DAC-dB Calculator Service
/// Handles conversions between percent DAC and decibel difference
/// 
/// Percent DAC represents signal amplitude as a percentage of the DAC reference curve.
/// This is commonly used in UT to adjust gain to reach a desired %DAC level.
class DacDbCalculatorService {
  /// Converts percent DAC to dB
  /// 
  /// Formula: dB = 20 * log10(%DAC / 100)
  /// 
  /// Parameters:
  /// - [percentDac]: Percent DAC value (must be > 0)
  /// 
  /// Returns a map containing:
  /// - 'dB': The decibel difference relative to DAC reference
  /// - 'amplitudeRatio': The amplitude ratio (R = %DAC / 100)
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Examples:
  /// - 100% DAC = 0 dB (R = 1.0)
  /// - 50% DAC ≈ -6.02 dB (R = 0.5)
  /// - 200% DAC ≈ +6.02 dB (R = 2.0)
  static Map<String, dynamic> calculateDbFromPercentDac({
    required double percentDac,
  }) {
    // Validate input
    if (percentDac <= 0) {
      return {
        'dB': null,
        'amplitudeRatio': null,
        'error': 'Percent DAC must be greater than 0',
      };
    }

    // Calculate amplitude ratio (R = %DAC / 100)
    final double amplitudeRatio = percentDac / 100;

    // Calculate dB (amplitude relationship: 20*log10)
    // dB = 20 * log10(R) = 20 * log10(%DAC / 100)
    final double db = 20 * log10(amplitudeRatio);

    return {
      'dB': db,
      'amplitudeRatio': amplitudeRatio,
      'error': null,
    };
  }

  /// Converts dB to percent DAC
  /// 
  /// Formula: %DAC = 100 * 10^(dB / 20)
  /// 
  /// Parameters:
  /// - [db]: Decibel change (can be negative or positive)
  /// 
  /// Returns a map containing:
  /// - 'percentDac': The percent DAC value
  /// - 'amplitudeRatio': The amplitude ratio (R = 10^(dB/20))
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Examples:
  /// - 0 dB = 100% DAC (R = 1.0)
  /// - -6.02 dB ≈ 50% DAC (R = 0.5)
  /// - +6.02 dB ≈ 200% DAC (R = 2.0)
  static Map<String, dynamic> calculatePercentDacFromDb({
    required double db,
  }) {
    // Calculate amplitude ratio from dB (amplitude relationship: 20*log10)
    // R = 10^(dB / 20)
    final double amplitudeRatio = pow(10, db / 20).toDouble();

    // Calculate percent DAC (%DAC = 100 * R)
    final double percentDac = 100 * amplitudeRatio;

    return {
      'percentDac': percentDac,
      'amplitudeRatio': amplitudeRatio,
      'error': null,
    };
  }

  /// Helper function to calculate log base 10
  static double log10(double x) {
    return log(x) / ln10;
  }

  /// Validates percent DAC input
  static String? validatePercentDac({required double percentDac}) {
    if (percentDac <= 0) {
      return 'Percent DAC must be greater than 0';
    }
    return null;
  }
}
