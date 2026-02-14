import 'dart:math';
import 'package:flutter/material.dart';
import '../models/reference_models.dart';

/// Main reference modules for the hub
class ReferenceData {
  static const List<ReferenceModule> modules = [
    ReferenceModule(
      id: 'asme',
      title: 'ASME Quick Reference',
      subtitle: 'Workflow summary and checklists (no code values)',
      icon: Icons.checklist_outlined,
      route: '/reference/asme',
      color: Color(0xFF6C5BFF),
      tags: ['ASME', 'Workflow', 'Checklist'],
    ),
    ReferenceModule(
      id: 'aws',
      title: 'AWS Acceptance Workflow',
      subtitle: 'Step-by-step evaluation guide (no acceptance values)',
      icon: Icons.account_tree_outlined,
      route: '/reference/aws',
      color: Color(0xFF00E5A8),
      tags: ['AWS', 'Acceptance', 'Workflow'],
    ),
    ReferenceModule(
      id: 'api1104',
      title: 'API 1104 Workflow',
      subtitle: 'Decision flow and documentation (no criteria values)',
      icon: Icons.schema_outlined,
      route: '/reference/api1104',
      color: Color(0xFFF8B800),
      tags: ['API', '1104', 'Pipeline', 'Workflow'],
    ),
    ReferenceModule(
      id: 'b31',
      title: 'B31.3 / B31.8 Field Guide',
      subtitle: 'Section pointers and concept summaries',
      icon: Icons.book_outlined,
      route: '/reference/b31',
      color: Color(0xFFFE637E),
      tags: ['B31.3', 'B31.8', 'Pipeline', 'Code'],
    ),
    ReferenceModule(
      id: 'ut_formulas',
      title: 'UT Level II Formula Sheet',
      subtitle: 'Complete physics formulas and calculations',
      icon: Icons.functions_outlined,
      route: '/reference/ut_formulas',
      color: Color(0xFF6C5BFF),
      tags: ['UT', 'Formulas', 'Physics', 'Level II'],
    ),
    ReferenceModule(
      id: 'paut_cheat',
      title: 'PAUT Cheat Sheet',
      subtitle: 'Phased array formulas and practical reminders',
      icon: Icons.view_array_outlined,
      route: '/reference/paut_cheat',
      color: Color(0xFF00E5A8),
      tags: ['PAUT', 'Phased Array', 'Formulas'],
    ),
    ReferenceModule(
      id: 'critical_angles',
      title: 'Critical Angles Calculator',
      subtitle: 'Calculate critical angles for material pairs',
      icon: Icons.analytics_outlined,
      route: '/reference/critical_angles',
      color: Color(0xFFF8B800),
      tags: ['Critical Angles', 'Refraction', 'Calculator'],
    ),
    ReferenceModule(
      id: 'material_velocities',
      title: 'Material Velocities Table',
      subtitle: 'Comprehensive material property reference',
      icon: Icons.storage_outlined,
      route: '/reference/material_velocities',
      color: Color(0xFFFE637E),
      tags: ['Materials', 'Velocities', 'Properties'],
    ),
  ];

  /// ASME workflow steps (COMPLIANT - NO CODE VALUES)
  static final List<WorkflowStep> asmeWorkflowSteps = [
    WorkflowStep(
      title: 'Before Inspection',
      description: 'Verify documentation and equipment before starting',
      icon: Icons.assignment_outlined,
      subSteps: [
        'Confirm procedure revision is current',
        'Verify calibration dates on all equipment',
        'Check equipment ID matches procedure requirements',
        'Review acceptance criteria in governing code',
        'Ensure environmental conditions are suitable',
      ],
    ),
    WorkflowStep(
      title: 'Common UT Workflow',
      description: 'Standard steps for ultrasonic inspection',
      icon: Icons.waves_outlined,
      subSteps: [
        'Identify method type (straight beam, angle beam, etc.)',
        'Establish reference level per procedure',
        'Perform system calibration',
        'Execute scanning pattern as defined',
        'Document all findings with location and amplitude',
        'Compare to acceptance criteria in procedure',
      ],
    ),
    WorkflowStep(
      title: 'Documentation Checklist',
      description: 'Essential items to record',
      icon: Icons.description_outlined,
      subSteps: [
        'Equipment identification and calibration dates',
        'Material identification and thickness',
        'Scanning parameters and sensitivity levels',
        'Indication locations and characteristics',
        'Acceptance/rejection decisions with rationale',
        'Inspector signature and certification level',
      ],
    ),
  ];

  /// AWS workflow steps (COMPLIANT - NO CODE VALUES)
  static final List<WorkflowStep> awsWorkflowSteps = [
    WorkflowStep(
      title: 'Classify Indication Type',
      description: 'Determine the nature of the discontinuity',
      icon: Icons.category_outlined,
      subSteps: [
        'Linear (crack-like) or Rounded (porosity-like)',
        'Surface, subsurface, or internal',
        'Single or multiple indications',
      ],
    ),
    WorkflowStep(
      title: 'Measure and Record',
      description: 'Document indication characteristics',
      icon: Icons.straighten_outlined,
      subSteps: [
        'Measure length (for linear indications)',
        'Record amplitude or signal response',
        'Determine through-wall extent if applicable',
        'Note location relative to weld features',
      ],
    ),
    WorkflowStep(
      title: 'Determine Thickness Range',
      description: 'Identify applicable acceptance table',
      icon: Icons.height_outlined,
      subSteps: [
        'Measure base material thickness',
        'Identify applicable thickness range in procedure',
        'Note any special acceptance criteria',
      ],
    ),
    WorkflowStep(
      title: 'Compare to Governing Table',
      description: 'Evaluate against acceptance criteria',
      icon: Icons.table_chart_outlined,
      subSteps: [
        'Refer to AWS governing table in your procedure',
        'Compare measured values to acceptance limits',
        'Document accept/reject decision',
        'NOTE: Do not rely on memorized values',
      ],
    ),
  ];

  /// API 1104 workflow steps (COMPLIANT - NO CODE VALUES)
  static final List<WorkflowStep> api1104WorkflowSteps = [
    WorkflowStep(
      title: 'Classify Discontinuity',
      description: 'Identify the type of imperfection',
      icon: Icons.troubleshoot_outlined,
      subSteps: [
        'Crack, lack of fusion, incomplete penetration',
        'Porosity (isolated, clustered, linear)',
        'Slag inclusions',
        'Undercut or other geometric imperfection',
      ],
    ),
    WorkflowStep(
      title: 'Measure and Document',
      description: 'Record all relevant dimensions',
      icon: Icons.architecture_outlined,
      subSteps: [
        'Length of indication',
        'Through-wall depth (if measurable)',
        'Location in weld (root, fill, cap)',
        'Distance from weld edge',
        'Photographic documentation if required',
      ],
    ),
    WorkflowStep(
      title: 'Compare to API 1104 Criteria',
      description: 'Evaluate per governing standard',
      icon: Icons.rule_outlined,
      subSteps: [
        'Refer to API 1104 acceptance criteria in procedure',
        'Consider applicable annex (radiographic/UT)',
        'Evaluate for workmanship vs. fitness-for-service',
        'Document decision with supporting rationale',
      ],
    ),
  ];

  /// B31.3/B31.8 reference sections (COMPLIANT - POINTERS ONLY)
  static final List<CheatSheetSection> b31Sections = [
    CheatSheetSection(
      title: 'Key Concepts',
      description: 'Important definitions and principles',
      items: [
        CheatItem(
          label: 'MAOP',
          value: 'Maximum Allowable Operating Pressure',
          note: 'The maximum pressure at which a piping system may be operated per design basis',
        ),
        CheatItem(
          label: 'Design Factor',
          value: 'Safety factor applied in design calculations',
          note: 'Accounts for material variability, loading conditions, and service type',
        ),
        CheatItem(
          label: 'Allowable Stress',
          value: 'Material-specific stress limits',
          note: 'See code tables for values based on material and temperature',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Where to Look - B31.3',
      description: 'Quick section reference guide',
      items: [
        CheatItem(
          label: 'Design Pressure/Temperature',
          value: 'Section 302',
          note: 'Basis for pressure design and temperature limits',
        ),
        CheatItem(
          label: 'Pipe Wall Thickness',
          value: 'Section 304',
          note: 'Calculation methods and minimum requirements',
        ),
        CheatItem(
          label: 'Allowable Stresses',
          value: 'Appendix A',
          note: 'Material allowable stress tables',
        ),
        CheatItem(
          label: 'Examination Requirements',
          value: 'Chapter VI',
          note: 'Inspection and testing requirements',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Where to Look - B31.8',
      description: 'Pipeline section reference',
      items: [
        CheatItem(
          label: 'Design Requirements',
          value: 'Section 841',
          note: 'Design pressure, temperature, and factors',
        ),
        CheatItem(
          label: 'Pressure Testing',
          value: 'Section 847',
          note: 'Hydrostatic and pneumatic test requirements',
        ),
        CheatItem(
          label: 'Operation & Maintenance',
          value: 'Chapter VII',
          note: 'In-service inspection and integrity management',
        ),
        CheatItem(
          label: 'Defect Assessment',
          value: 'Section 865',
          note: 'Evaluation of anomalies and fitness-for-service',
        ),
      ],
    ),
  ];
}
