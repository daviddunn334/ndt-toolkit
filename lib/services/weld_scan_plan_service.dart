/// Weld Scan Plan Service
/// Handles calculations for scan planning, coverage estimation, and time estimation
/// for UT/PAUT weld scanning operations
class WeldScanPlanService {
  /// Converts length value to consistent unit (inches for internal calculations)
  static double _convertToInches(double value, String unit) {
    switch (unit) {
      case 'ft':
        return value * 12;
      case 'in':
        return value;
      case 'mm':
        return value / 25.4;
      case 'm':
        return value * 39.3701;
      default:
        return value;
    }
  }

  /// Converts scan speed to consistent unit (inches per second)
  static double _convertSpeedToInchesPerSec(double value, String unit) {
    switch (unit) {
      case 'in/sec':
        return value;
      case 'in/min':
        return value / 60;
      case 'mm/sec':
        return value / 25.4;
      case 'mm/min':
        return value / 25.4 / 60;
      default:
        return value;
    }
  }

  /// Converts inches back to desired unit for display
  static double _convertFromInches(double inches, String unit) {
    switch (unit) {
      case 'ft':
        return inches / 12;
      case 'in':
        return inches;
      case 'mm':
        return inches * 25.4;
      case 'm':
        return inches / 39.3701;
      default:
        return inches;
    }
  }

  /// Calculates scan plan metrics
  /// 
  /// Parameters:
  /// - [weldLength]: Length of weld to scan
  /// - [weldLengthUnit]: Unit for weld length (ft, in, mm, m)
  /// - [scanWidth]: Width of scan coverage
  /// - [scanWidthUnit]: Unit for scan width (in, mm)
  /// - [indexStep]: Distance between scan passes
  /// - [indexStepUnit]: Unit for index step (in, mm)
  /// - [scanSpeed]: Speed of scan
  /// - [scanSpeedUnit]: Unit for scan speed (in/sec, in/min, mm/sec, mm/min)
  /// 
  /// Returns a map containing:
  /// - 'passes': Number of scan passes (index lines)
  /// - 'totalDistance': Total scan distance in weld length units
  /// - 'scanTimeSeconds': Estimated scan time in seconds
  /// - 'coverageQuality': Quality indicator (Good, Caution, Poor)
  /// - 'overlapPercent': Overlap percentage between passes
  /// - 'error': Error message if validation fails
  static Map<String, dynamic> calculateScanPlan({
    required double weldLength,
    required String weldLengthUnit,
    required double scanWidth,
    required String scanWidthUnit,
    required double indexStep,
    required String indexStepUnit,
    required double scanSpeed,
    required String scanSpeedUnit,
  }) {
    // Validate inputs
    if (weldLength <= 0) {
      return {'error': 'Weld length must be greater than 0'};
    }
    if (scanWidth <= 0) {
      return {'error': 'Scan width must be greater than 0'};
    }
    if (indexStep <= 0) {
      return {'error': 'Index step must be greater than 0'};
    }
    if (scanSpeed <= 0) {
      return {'error': 'Scan speed must be greater than 0'};
    }

    // Convert all to consistent units (inches)
    final double weldLengthInches = _convertToInches(weldLength, weldLengthUnit);
    final double scanWidthInches = _convertToInches(scanWidth, scanWidthUnit);
    final double indexStepInches = _convertToInches(indexStep, indexStepUnit);
    final double scanSpeedInchesPerSec = _convertSpeedToInchesPerSec(scanSpeed, scanSpeedUnit);

    // Check if index step is larger than scan width
    if (indexStepInches > scanWidthInches) {
      return {
        'error': 'Index step cannot be larger than scan width. This would result in gaps in coverage.'
      };
    }

    // A) Calculate number of passes
    // passes = ceil(scan_width / index_step)
    final int passes = (scanWidthInches / indexStepInches).ceil();

    // B) Calculate total scan distance
    // total_distance = weld_length * passes
    final double totalDistanceInches = weldLengthInches * passes;
    final double totalDistance = _convertFromInches(totalDistanceInches, weldLengthUnit);

    // C) Calculate estimated scan time
    // time = total_distance / scan_speed
    final double scanTimeSeconds = totalDistanceInches / scanSpeedInchesPerSec;

    // D) Calculate overlap and coverage quality
    // Overlap percent = ((scan_width - index_step) / scan_width) * 100
    final double overlapPercent = ((scanWidthInches - indexStepInches) / scanWidthInches) * 100;

    // Coverage quality assessment
    // Good: 25-75% overlap (industry standard)
    // Caution: 10-25% or 75-90% overlap
    // Poor: <10% or >90% overlap
    String coverageQuality;
    if (overlapPercent >= 25 && overlapPercent <= 75) {
      coverageQuality = 'Good';
    } else if ((overlapPercent >= 10 && overlapPercent < 25) || 
               (overlapPercent > 75 && overlapPercent <= 90)) {
      coverageQuality = 'Caution';
    } else {
      coverageQuality = 'Poor';
    }

    return {
      'passes': passes,
      'totalDistance': totalDistance,
      'totalDistanceUnit': weldLengthUnit,
      'scanTimeSeconds': scanTimeSeconds,
      'coverageQuality': coverageQuality,
      'overlapPercent': overlapPercent,
      'error': null,
    };
  }

  /// Formats time in seconds to a friendly string
  static String formatTime(double seconds) {
    final int hours = (seconds / 3600).floor();
    final int minutes = ((seconds % 3600) / 60).floor();
    final int secs = (seconds % 60).floor();

    if (hours > 0) {
      return '$hours hr $minutes min';
    } else if (minutes > 0) {
      return '$minutes min $secs sec';
    } else {
      return '$secs sec';
    }
  }

  /// Generates pre-scan checklist items
  static List<String> getChecklistItems() {
    return [
      'Confirm weld datum and start/end points',
      'Verify scan width matches probe/wedge specifications',
      'Confirm index step provides adequate coverage',
      'Check encoder calibration and operation',
      'Verify couplant availability and suitability',
      'Confirm scan direction and overlap strategy',
      'Set up data acquisition parameters',
      'Mark reference points on the weld',
      'Test equipment on calibration block',
      'Document scan plan parameters',
    ];
  }

  /// Gets recommended overlap range message
  static String getOverlapRecommendation(double overlapPercent) {
    if (overlapPercent < 10) {
      return '⚠️ Very low overlap - high risk of missing defects. Recommended: 25-75%';
    } else if (overlapPercent < 25) {
      return '⚠️ Low overlap - consider reducing index step. Recommended: 25-75%';
    } else if (overlapPercent <= 75) {
      return '✓ Good overlap - meets industry standards (25-75%)';
    } else if (overlapPercent <= 90) {
      return '⚠️ High overlap - may be inefficient. Consider increasing index step.';
    } else {
      return '⚠️ Very high overlap - significantly inefficient scanning. Increase index step.';
    }
  }
}
