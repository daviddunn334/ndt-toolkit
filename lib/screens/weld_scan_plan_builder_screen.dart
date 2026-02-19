import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/weld_scan_plan_service.dart';

class WeldScanPlanBuilderScreen extends StatefulWidget {
  const WeldScanPlanBuilderScreen({super.key});

  @override
  State<WeldScanPlanBuilderScreen> createState() => _WeldScanPlanBuilderScreenState();
}

class _WeldScanPlanBuilderScreenState extends State<WeldScanPlanBuilderScreen> {
  // Controllers
  final TextEditingController _weldLengthController = TextEditingController();
  final TextEditingController _scanWidthController = TextEditingController();
  final TextEditingController _indexStepController = TextEditingController();
  final TextEditingController _scanSpeedController = TextEditingController();

  // New Dark Color System
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentPrimary = Color(0xFF6C5BFF);
  static const Color _accentSuccess = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);

  // Unit selections
  String _weldLengthUnit = 'ft';
  String _scanWidthUnit = 'in';
  String _indexStepUnit = 'in';
  String _scanSpeedUnit = 'in/min';

  // Results
  int? _passes;
  double? _totalDistance;
  String? _totalDistanceUnit;
  double? _scanTimeSeconds;
  String? _coverageQuality;
  double? _overlapPercent;
  String? _errorMessage;

  @override
  void dispose() {
    _weldLengthController.dispose();
    _scanWidthController.dispose();
    _indexStepController.dispose();
    _scanSpeedController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _passes = null;
      _totalDistance = null;
      _totalDistanceUnit = null;
      _scanTimeSeconds = null;
      _coverageQuality = null;
      _overlapPercent = null;
    });

    try {
      // Validate inputs
      if (_weldLengthController.text.isEmpty ||
          _scanWidthController.text.isEmpty ||
          _indexStepController.text.isEmpty ||
          _scanSpeedController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter all required values';
        });
        return;
      }

      final weldLength = double.parse(_weldLengthController.text);
      final scanWidth = double.parse(_scanWidthController.text);
      final indexStep = double.parse(_indexStepController.text);
      final scanSpeed = double.parse(_scanSpeedController.text);

      final result = WeldScanPlanService.calculateScanPlan(
        weldLength: weldLength,
        weldLengthUnit: _weldLengthUnit,
        scanWidth: scanWidth,
        scanWidthUnit: _scanWidthUnit,
        indexStep: indexStep,
        indexStepUnit: _indexStepUnit,
        scanSpeed: scanSpeed,
        scanSpeedUnit: _scanSpeedUnit,
      );

      if (result['error'] != null) {
        setState(() {
          _errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        _passes = result['passes'];
        _totalDistance = result['totalDistance'];
        _totalDistanceUnit = result['totalDistanceUnit'];
        _scanTimeSeconds = result['scanTimeSeconds'];
        _coverageQuality = result['coverageQuality'];
        _overlapPercent = result['overlapPercent'];
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Weld Scan Plan Builder',
        inputValues: {
          'weld_length': weldLength,
          'weld_length_unit': _weldLengthUnit,
          'scan_width': scanWidth,
          'scan_width_unit': _scanWidthUnit,
          'index_step': indexStep,
          'index_step_unit': _indexStepUnit,
          'scan_speed': scanSpeed,
          'scan_speed_unit': _scanSpeedUnit,
          'passes': _passes,
          'coverage_quality': _coverageQuality,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _passes = null;
      _totalDistance = null;
      _totalDistanceUnit = null;
      _scanTimeSeconds = null;
      _coverageQuality = null;
      _overlapPercent = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📐 Weld Scan Plan Builder',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimate scan time and coverage for UT/PAUT weld scans',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Input Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: _accentPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Input Parameters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Weld Length
                    _buildInputFieldWithUnit(
                      controller: _weldLengthController,
                      label: 'Weld Length',
                      hint: 'Total weld length to scan',
                      icon: Icons.straighten,
                      unitValue: _weldLengthUnit,
                      unitOptions: ['ft', 'in', 'mm', 'm'],
                      onUnitChanged: (value) {
                        setState(() {
                          _weldLengthUnit = value!;
                          _clearResults();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Scan Width
                    _buildInputFieldWithUnit(
                      controller: _scanWidthController,
                      label: 'Scan Width (Coverage Width)',
                      hint: 'Width of area to cover',
                      icon: Icons.width_normal,
                      unitValue: _scanWidthUnit,
                      unitOptions: ['in', 'mm'],
                      onUnitChanged: (value) {
                        setState(() {
                          _scanWidthUnit = value!;
                          _clearResults();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Index Step
                    _buildInputFieldWithUnit(
                      controller: _indexStepController,
                      label: 'Index Step',
                      hint: 'Distance between passes',
                      icon: Icons.border_vertical,
                      unitValue: _indexStepUnit,
                      unitOptions: ['in', 'mm'],
                      onUnitChanged: (value) {
                        setState(() {
                          _indexStepUnit = value!;
                          _clearResults();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Scan Speed
                    _buildInputFieldWithUnit(
                      controller: _scanSpeedController,
                      label: 'Scan Speed',
                      hint: 'Scanning velocity',
                      icon: Icons.speed,
                      unitValue: _scanSpeedUnit,
                      unitOptions: ['in/sec', 'in/min', 'mm/sec', 'mm/min'],
                      onUnitChanged: (value) {
                        setState(() {
                          _scanSpeedUnit = value!;
                          _clearResults();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, size: 20),
                      label: const Text(
                        'Calculate Scan Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentAlert.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentAlert.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: _accentAlert, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: _accentAlert,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Results Section
              if (_passes != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentSuccess.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: _accentSuccess, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Scan Plan Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Metric tiles
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              'Passes',
                              _passes.toString(),
                              'Index Lines',
                              Icons.view_week,
                              _accentPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              'Total Distance',
                              '${_totalDistance!.toStringAsFixed(1)} $_totalDistanceUnit',
                              'Scan Distance',
                              Icons.straighten,
                              _accentSuccess,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              'Est. Time',
                              WeldScanPlanService.formatTime(_scanTimeSeconds!),
                              'Scan Duration',
                              Icons.timer,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              'Coverage',
                              _coverageQuality!,
                              '${_overlapPercent!.toStringAsFixed(1)}% overlap',
                              Icons.grid_on,
                              _getCoverageColor(_coverageQuality!),
                            ),
                          ),
                        ],
                      ),

                      // Coverage recommendation
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getCoverageColor(_coverageQuality!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCoverageColor(_coverageQuality!).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _getCoverageIcon(_coverageQuality!),
                              color: _getCoverageColor(_coverageQuality!),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                WeldScanPlanService.getOverlapRecommendation(_overlapPercent!),
                                style: TextStyle(
                                  color: _getCoverageColor(_coverageQuality!),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Coverage Summary Table
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 20),
                      Text(
                        'Coverage Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Number of Passes:', '$_passes'),
                      _buildSummaryRow('Overlap Percentage:', '${_overlapPercent!.toStringAsFixed(1)}%'),
                      _buildSummaryRow('Total Scan Distance:', '${_totalDistance!.toStringAsFixed(2)} $_totalDistanceUnit'),
                      _buildSummaryRow('Estimated Time:', WeldScanPlanService.formatTime(_scanTimeSeconds!)),
                      _buildSummaryRow('Time per Pass:', WeldScanPlanService.formatTime(_scanTimeSeconds! / _passes!)),
                    ],
                  ),
                ),

                // Checklist Section
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.checklist,
                                color: _accentSuccess,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pre-Scan Checklist',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _copyChecklist,
                            icon: Icon(Icons.copy, size: 16, color: _accentPrimary),
                            label: Text(
                              'Copy',
                              style: TextStyle(color: _accentPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...WeldScanPlanService.getChecklistItems().map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _accentSuccess,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Info section
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Scan Planning',
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This tool helps estimate scan time and verify coverage for UT/PAUT weld inspections. '
                      'Index step should be chosen to provide adequate overlap (typically 25-75%) while maintaining '
                      'reasonable scan time. Always verify actual scan parameters with procedure requirements.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Formula: Number of Passes = ceil(Scan Width / Index Step)',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldWithUnit({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String unitValue,
    required List<String> unitOptions,
    required void Function(String?) onUnitChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                style: TextStyle(color: _textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: _textMuted, fontSize: 14),
                  prefixIcon: Icon(icon, color: _textSecondary, size: 20),
                  filled: true,
                  fillColor: _bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _accentPrimary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (_) => _clearResults(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _bgElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: unitValue,
                  items: unitOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: _textPrimary, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: onUnitChanged,
                  dropdownColor: _bgCard,
                  icon: Icon(Icons.arrow_drop_down, color: _textSecondary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCoverageColor(String quality) {
    switch (quality) {
      case 'Good':
        return _accentSuccess;
      case 'Caution':
        return Colors.orange;
      case 'Poor':
        return _accentAlert;
      default:
        return _textSecondary;
    }
  }

  IconData _getCoverageIcon(String quality) {
    switch (quality) {
      case 'Good':
        return Icons.check_circle;
      case 'Caution':
        return Icons.warning;
      case 'Poor':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  void _copyChecklist() {
    final checklist = WeldScanPlanService.getChecklistItems().join('\n✓ ');
    Clipboard.setData(ClipboardData(text: '✓ $checklist'));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checklist copied to clipboard'),
        backgroundColor: _accentSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
