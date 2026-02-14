import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/db_calculator_service.dart';

class GainChangeEstimatorScreen extends StatefulWidget {
  const GainChangeEstimatorScreen({super.key});

  @override
  State<GainChangeEstimatorScreen> createState() => _GainChangeEstimatorScreenState();
}

class _GainChangeEstimatorScreenState extends State<GainChangeEstimatorScreen> {
  // Controllers
  final TextEditingController _a1Controller = TextEditingController();
  final TextEditingController _gainDbController = TextEditingController();
  final TextEditingController _a2Controller = TextEditingController();
  final TextEditingController _maxDisplayController = TextEditingController(text: '100');

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
  static const Color _accentWarning = Color(0xFFFFA940);

  // Mode: true = Mode A (Apply gain), false = Mode B (Required gain)
  bool _isApplyGainMode = true;

  // Results
  double? _resultAmplitude;
  double? _resultDb;
  double? _ratio;
  double? _percentChange;
  String? _errorMessage;
  String? _warningMessage;

  @override
  void dispose() {
    _a1Controller.dispose();
    _gainDbController.dispose();
    _a2Controller.dispose();
    _maxDisplayController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _warningMessage = null;
      _resultAmplitude = null;
      _resultDb = null;
      _ratio = null;
      _percentChange = null;
    });

    // Validate A1 (required in both modes)
    if (_a1Controller.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter starting amplitude (A1)';
      });
      return;
    }

    try {
      final a1 = double.parse(_a1Controller.text);

      if (a1 <= 0) {
        setState(() {
          _errorMessage = 'Starting amplitude must be greater than 0';
        });
        return;
      }

      if (_isApplyGainMode) {
        // Mode A: Apply gain (dB → new amplitude)
        if (_gainDbController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter gain change (ΔdB)';
          });
          return;
        }

        final gainDb = double.parse(_gainDbController.text);

        // Use the existing db_calculator_service (amplitude mode)
        final result = DbCalculatorService.calculateRatioFromDb(
          a1: a1,
          db: gainDb,
          isPowerMode: false, // Use amplitude/voltage mode (20*log10)
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        final a2 = result['a2'];
        final ratio = result['ratio'];
        final percentChange = result['percentChange'];

        // Check if A2 exceeds max display (optional warning)
        String? warning;
        if (_maxDisplayController.text.isNotEmpty) {
          try {
            final maxDisplay = double.parse(_maxDisplayController.text);
            if (a2 > maxDisplay) {
              warning = 'Target amplitude (${a2.toStringAsFixed(2)}) exceeds ${maxDisplay.toStringAsFixed(0)}% FSH (will clip)';
            }
          } catch (e) {
            // Ignore invalid max display value
          }
        }

        setState(() {
          _resultAmplitude = a2;
          _ratio = ratio;
          _percentChange = percentChange;
          _warningMessage = warning;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Gain Change Estimator - Apply Gain',
          inputValues: {
            'mode': 'apply_gain',
            'a1': a1,
            'gain_db': gainDb,
            'a2': a2,
            'ratio': ratio,
            'percent_change': percentChange,
          },
        );
      } else {
        // Mode B: Required gain (amplitude → dB)
        if (_a2Controller.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter target amplitude (A2)';
          });
          return;
        }

        final a2 = double.parse(_a2Controller.text);

        if (a2 <= 0) {
          setState(() {
            _errorMessage = 'Target amplitude must be greater than 0';
          });
          return;
        }

        // Use the existing db_calculator_service (amplitude mode)
        final result = DbCalculatorService.calculateDbFromRatio(
          a1: a1,
          a2: a2,
          isPowerMode: false, // Use amplitude/voltage mode (20*log10)
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        final db = result['dB'];
        final ratio = result['ratio'];
        final percentChange = result['percentChange'];

        setState(() {
          _resultDb = db;
          _ratio = ratio;
          _percentChange = percentChange;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Gain Change Estimator - Required Gain',
          inputValues: {
            'mode': 'required_gain',
            'a1': a1,
            'a2': a2,
            'db': db,
            'ratio': ratio,
            'percent_change': percentChange,
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _resultAmplitude = null;
      _resultDb = null;
      _ratio = null;
      _percentChange = null;
      _errorMessage = null;
      _warningMessage = null;
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
                          '📊 Gain Change Estimator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calculate amplitude changes from gain adjustments',
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

              // Mode Toggle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _accentPrimary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: _accentPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Calculation Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _accentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModeButton(
                            'Apply gain\n(dB → amplitude)',
                            _isApplyGainMode,
                            () {
                              setState(() {
                                _isApplyGainMode = true;
                                _clearResults();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeButton(
                            'Required gain\n(amplitude → dB)',
                            !_isApplyGainMode,
                            () {
                              setState(() {
                                _isApplyGainMode = false;
                                _clearResults();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                    Text(
                      'Input Parameters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // A1 (always shown)
                    _buildInputField(
                      controller: _a1Controller,
                      label: 'Starting Amplitude (A1)',
                      hint: 'Enter starting amplitude',
                      suffix: '%FSH or units',
                      icon: Icons.show_chart,
                    ),
                    const SizedBox(height: 16),

                    // Mode-specific inputs
                    if (_isApplyGainMode) ...[
                      _buildInputField(
                        controller: _gainDbController,
                        label: 'Gain Change (ΔdB)',
                        hint: 'Enter gain change (+ or -)',
                        suffix: 'dB',
                        icon: Icons.tune,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _maxDisplayController,
                        label: 'Max Display (optional)',
                        hint: 'Enter max display value',
                        suffix: '%FSH',
                        icon: Icons.vertical_align_top,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade300,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Positive dB increases amplitude, negative dB decreases it',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      _buildInputField(
                        controller: _a2Controller,
                        label: 'Target Amplitude (A2)',
                        hint: 'Enter target amplitude',
                        suffix: '%FSH or units',
                        icon: Icons.flag,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade300,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Calculates the dB change needed to reach the target amplitude',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, size: 20),
                      label: Text(
                        _isApplyGainMode ? 'Calculate New Amplitude' : 'Calculate Required Gain',
                        style: const TextStyle(
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

              // Warning message
              if (_warningMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentWarning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentWarning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: _accentWarning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _warningMessage!,
                          style: TextStyle(
                            color: _accentWarning,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Results
              if (_ratio != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.3),
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
                            'Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_isApplyGainMode) ...[
                        _buildResultRow(
                          'New Amplitude (A2)',
                          '${_resultAmplitude!.toStringAsFixed(2)} units',
                          isLarge: true,
                        ),
                      ] else ...[
                        _buildResultRow(
                          'Required Gain (ΔdB)',
                          '${_resultDb!.toStringAsFixed(2)} dB',
                          isLarge: true,
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      
                      _buildResultRow(
                        'Amplitude Ratio (R)',
                        _ratio!.toStringAsFixed(4),
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'Percent Change',
                        '${_percentChange!.toStringAsFixed(2)}%',
                      ),
                      
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _accentSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _accentSuccess.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _accentSuccess,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isApplyGainMode
                                    ? 'The amplitude ${_percentChange! >= 0 ? 'increases' : 'decreases'} by ${_percentChange!.abs().toStringAsFixed(1)}%'
                                    : 'Adjust gain by ${_resultDb!.toStringAsFixed(2)} dB to reach target amplitude',
                                style: TextStyle(
                                  color: _accentSuccess,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
                          'About Gain Changes',
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
                      'This tool helps you understand how gain adjustments affect signal amplitude in NDT testing. Use Mode A to predict the new amplitude after a gain change, or Mode B to determine what gain change is needed to reach a specific amplitude.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Key Formulas (Amplitude/Voltage):',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Amplitude ratio: R = 10^(ΔdB / 20)\n'
                      'Apply gain: A2 = A1 × R\n'
                      'Required gain: ΔdB = 20 × log₁₀(A2 / A1)\n'
                      'Percent change: % = (R - 1) × 100',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'monospace',
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

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _accentPrimary : _bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _accentPrimary : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
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
        TextField(
          controller: controller,
          style: TextStyle(color: _textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted),
            suffixText: suffix,
            suffixStyle: TextStyle(color: _textSecondary),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          onChanged: (_) => _clearResults(),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 15 : 14,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLarge ? _accentPrimary : _textPrimary,
            fontSize: isLarge ? 20 : 16,
          ),
        ),
      ],
    );
  }
}
