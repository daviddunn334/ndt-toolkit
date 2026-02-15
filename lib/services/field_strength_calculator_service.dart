import 'dart:math';

/// Field Strength Calculator Service
/// Handles magnetic field strength calculations for MT (Magnetic Particle Testing)
/// 
/// Supports two magnetization methods:
/// 1. Circular magnetization (direct current through part)
/// 2. Longitudinal magnetization (coil around part)
class FieldStrengthCalculatorService {
  /// Calculates magnetic field strength for circular magnetization
  /// 
  /// Uses Ampere's Law approximation for a round conductor:
  /// H = I / (2πr)
  /// 
  /// Parameters:
  /// - [current]: Current in Amperes (must be > 0)
  /// - [radius]: Radial distance from center (same units as output, must be > 0)
  /// 
  /// Returns a map containing:
  /// - 'H': Magnetic field strength (A per unit length)
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Example:
  /// - Current = 1000 A, Radius = 1 inch
  /// - H = 1000 / (2π × 1) ≈ 159.15 A/in
  static Map<String, dynamic> calculateCircularField({
    required double current,
    required double radius,
  }) {
    // Validate inputs
    if (current <= 0) {
      return {
        'H': null,
        'error': 'Current must be greater than 0',
      };
    }

    if (radius <= 0) {
      return {
        'H': null,
        'error': 'Radius must be greater than 0',
      };
    }

    // Calculate field strength: H = I / (2πr)
    final double fieldStrength = current / (2 * pi * radius);

    return {
      'H': fieldStrength,
      'error': null,
    };
  }

  /// Calculates magnetic field strength for longitudinal magnetization
  /// 
  /// Uses solenoid approximation:
  /// H = (N × I) / L
  /// 
  /// Parameters:
  /// - [current]: Current in Amperes (must be > 0)
  /// - [turns]: Number of coil turns (must be >= 1)
  /// - [coilLength]: Length of coil (same units as output, must be > 0)
  /// 
  /// Returns a map containing:
  /// - 'H': Magnetic field strength (A per unit length)
  /// - 'ampTurns': Amp-turns (N × I)
  /// - 'error': Error message if validation fails (null if valid)
  /// 
  /// Example:
  /// - Current = 10 A, Turns = 200, Coil Length = 12 inches
  /// - Amp-Turns = 200 × 10 = 2000 A-turns
  /// - H = 2000 / 12 ≈ 166.67 A/in
  static Map<String, dynamic> calculateLongitudinalField({
    required double current,
    required int turns,
    required double coilLength,
  }) {
    // Validate inputs
    if (current <= 0) {
      return {
        'H': null,
        'ampTurns': null,
        'error': 'Current must be greater than 0',
      };
    }

    if (turns < 1) {
      return {
        'H': null,
        'ampTurns': null,
        'error': 'Number of turns must be at least 1',
      };
    }

    if (coilLength <= 0) {
      return {
        'H': null,
        'ampTurns': null,
        'error': 'Coil length must be greater than 0',
      };
    }

    // Calculate amp-turns
    final int ampTurns = (turns * current).round();

    // Calculate field strength: H = (N × I) / L
    final double fieldStrength = ampTurns / coilLength;

    return {
      'H': fieldStrength,
      'ampTurns': ampTurns,
      'error': null,
    };
  }

  /// Converts diameter to radius
  static double diameterToRadius(double diameter) {
    return diameter / 2;
  }

  /// Validates circular field inputs
  static String? validateCircularInputs({
    required double current,
    required double radius,
  }) {
    if (current <= 0) {
      return 'Current must be greater than 0';
    }
    if (radius <= 0) {
      return 'Radius must be greater than 0';
    }
    return null;
  }

  /// Validates longitudinal field inputs
  static String? validateLongitudinalInputs({
    required double current,
    required int turns,
    required double coilLength,
  }) {
    if (current <= 0) {
      return 'Current must be greater than 0';
    }
    if (turns < 1) {
      return 'Number of turns must be at least 1';
    }
    if (coilLength <= 0) {
      return 'Coil length must be greater than 0';
    }
    return null;
  }
}
