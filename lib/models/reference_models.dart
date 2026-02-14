import 'package:flutter/material.dart';

/// Represents a reference module in the hub
class ReferenceModule {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;
  final List<String> tags;

  const ReferenceModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
    this.tags = const [],
  });
}

/// Represents a row in a reference table
class ReferenceRow {
  final String label;
  final Map<String, String> columns; // columnName -> value
  final List<String> tags; // for filtering/search
  final String? note;

  const ReferenceRow({
    required this.label,
    required this.columns,
    this.tags = const [],
    this.note,
  });
}

/// Represents a section in a cheat sheet
class CheatSheetSection {
  final String title;
  final List<CheatItem> items;
  final String? description;

  const CheatSheetSection({
    required this.title,
    required this.items,
    this.description,
  });
}

/// Represents an item in a cheat sheet
class CheatItem {
  final String label;
  final String value; // include formulas as text
  final String? note;
  final String? unit;

  const CheatItem({
    required this.label,
    required this.value,
    this.note,
    this.unit,
  });
}

/// Represents a workflow step
class WorkflowStep {
  final String title;
  final String description;
  final IconData icon;
  final List<String>? subSteps;

  const WorkflowStep({
    required this.title,
    required this.description,
    required this.icon,
    this.subSteps,
  });
}

/// Represents a material with its properties
class MaterialVelocity {
  final String material;
  final double longitudinalVelocity; // m/s
  final double shearVelocity; // m/s
  final double? density; // kg/m³
  final String? notes;
  final List<String> tags;

  const MaterialVelocity({
    required this.material,
    required this.longitudinalVelocity,
    required this.shearVelocity,
    this.density,
    this.notes,
    this.tags = const [],
  });

  Map<String, String> toColumns() {
    return {
      'VL (m/s)': longitudinalVelocity.toStringAsFixed(0),
      'VS (m/s)': shearVelocity.toStringAsFixed(0),
      if (density != null) 'Density (kg/m³)': density!.toStringAsFixed(0),
    };
  }
}

/// Represents a preset material pair for critical angle calculations
class MaterialPair {
  final String name;
  final String medium1;
  final String medium2;
  final double v1; // m/s
  final double vL2; // m/s
  final double vS2; // m/s

  const MaterialPair({
    required this.name,
    required this.medium1,
    required this.medium2,
    required this.v1,
    required this.vL2,
    required this.vS2,
  });

  double? get criticalAngleL {
    if (vL2 <= v1) return null;
    final ratio = v1 / vL2;
    if (ratio > 1.0) return null;
    return asinDegrees(ratio);
  }

  double? get criticalAngleS {
    if (vS2 <= v1) return null;
    final ratio = v1 / vS2;
    if (ratio > 1.0) return null;
    return asinDegrees(ratio);
  }

  static double asinDegrees(double value) {
    return (asin(value) * 180.0 / 3.14159265359);
  }

  static double asin(double x) {
    // Simple asin implementation
    if (x < -1.0 || x > 1.0) return double.nan;
    if (x == 1.0) return 3.14159265359 / 2;
    if (x == -1.0) return -3.14159265359 / 2;
    
    // Taylor series approximation for small values
    double result = x;
    double term = x;
    for (int n = 1; n < 20; n++) {
      term *= x * x * (2 * n - 1) * (2 * n - 1) / (2 * n * (2 * n + 1));
      result += term;
    }
    return result;
  }
}
