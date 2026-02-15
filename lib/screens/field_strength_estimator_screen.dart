import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/field_strength_calculator_service.dart';

class FieldStrengthEstimatorScreen extends StatefulWidget {
  const FieldStrengthEstimatorScreen({super.key});

  @override
  State<FieldStrengthEstimatorScreen> createState() => _FieldStrengthEstimatorScreenState();
}

class _FieldStrengthEstimatorScreenState extends State<FieldStrengthEstimatorScreen> {
  // Controllers for Circular mode
  final TextEditingController _currentCircularController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  // Controllers for Longitudinal mode
  final TextEditingController _currentLongitudinalController = TextEditingController();
  final TextEditingController _turnsController = TextEditingController();
  final TextEditingController _coilLengthController = TextEditingController();

  // New Dark Color System
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentSuccess = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);

  // Mode: true = Circular, false = Longitudinal
  bool _isCircularMode = true;

  // Results
  double? _resultH;
  int? _ampTurns;
  String? _errorMessage;
  String _unitLabel = 'in'; // Default to inches

  @override
  void dispose() {
    _currentCircularController.dispose();
    _radiusController.dispose();
    _currentLongitudinalController.dispose();
    _turnsController.dispose();
    _coilLengthController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultH = null;
      _ampTurns = null;
    });

    try {
      if (_isCircularMode) {
        // Circular Field Mode
        if (_currentCircularController.text.isEmpty || _radiusController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter all required values';
          });
          return;
        }

        final current = double.parse(_currentCircularController.text);
        final radius = double.parse(_radiusController.text);

        final result = FieldStrengthCalculatorService.calculateCircularField(
          current: current,
          radius: radius,
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultH = result['H'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Field Strength Estimator - Circular',
          inputValues: {
            'mode': 'circular',
            'current': current,
            'radius': radius,
            'field_strength_H': result['H'],
          },
        );
      } else {
        // Longitudinal Field Mode
        if (_currentLongitudinalController.text.isEmpty ||
            _turnsController.text.isEmpty ||
            _coilLengthController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter all required values';
          });
          return;
        }

        final current = double.parse(_currentLongitudinalController.text);
        final turns = int.parse(_turnsController.text);
        final coilLength = double.parse(_coilLengthController.text);

        final result = FieldStrengthCalculatorService.calculateLongitudinalField(
          current: current,
          turns: turns,
          coilLength: coilLength,
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultH = result['H'];
          _ampTurns = result['ampTurns'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Field Strength Estimator - Longitudinal',
          inputValues: {
            'mode': 'longitudinal',
            'current': current,
            'turns': turns,
            'coil_length': coilLength,
            'field_strength_H': result['H'],
            'amp_turns': result['ampTurns'],
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
      _resultH = null;
      _ampTurns = null;
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
                          '🧲 Field Strength Estimator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Circular / Longitudinal magnetization field strength',
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
                    color: _accentAlert.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grain_outlined,
                          color: _accentAlert,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Magnetization Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _accentAlert,
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
                            'Circular\n(Direct Contact)',
                            _isCircularMode,
                            () {
                              setState(() {
                                _isCircularMode = true;
                                _clearResults();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeButton(
                            'Longitudinal\n(Coil)',
                            !_isCircularMode,
                            () {
                              setState(() {
                                _isCircularMode = false;
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
                    
                    // Mode-specific inputs
                    if (_isCircularMode) ...[
                      _buildInputField(
                        controller: _currentCircularController,
                        label: 'Current (I)',
                        hint: 'Enter current in Amps',
                        suffix: 'A',
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _radiusController,
                        label: 'Radius (r)',
                        hint: 'Distance from center of conductor',
                        suffix: _unitLabel,
                        icon: Icons.straighten,
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
                                'Formula: H = I / (2πr)\nValid for long straight conductor assumption',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      _buildInputField(
                        controller: _currentLongitudinalController,
                        label: 'Current (I)',
                        hint: 'Enter current in Amps',
                        suffix: 'A',
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _turnsController,
                        label: 'Number of Turns (N)',
                        hint: 'Enter number of coil turns',
                        suffix: 'turns',
                        icon: Icons.loop,
                        isInteger: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _coilLengthController,
                        label: 'Coil Length (L)',
                        hint: 'Length of coil',
                        suffix: _unitLabel,
                        icon: Icons.straighten,
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
                                'Formula: H = (N × I) / L\nSolenoid approximation',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 11,
                                  height: 1.4,
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
                      label: const Text(
                        'Calculate Field Strength',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentAlert,
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

              // Results
              if (_resultH != null) ...[
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

                      _buildResultRow(
                        'Field Strength (H)',
                        '${_resultH!.toStringAsFixed(2)} A/$_unitLabel',
                        isLarge: true,
                      ),

                      // Longitudinal mode: show amp-turns
                      if (!_isCircularMode && _ampTurns != null) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Amp-Turns (N × I)',
                          '$_ampTurns A-turns',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.purple.shade300,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Typical longitudinal magnetization: 1000–4000 A-turns per foot',
                                  style: TextStyle(
                                    color: Colors.purple.shade100,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Disclaimer
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Idealized equations. Real field strength depends on part geometry, saturation, and permeability. Always verify with a gauss meter.',
                        style: TextStyle(
                          color: Colors.orange.shade100,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                          'About Field Strength Estimation',
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
                      'This tool provides engineering estimates for magnetic field strength in MT testing. '
                      'It is not a replacement for gauss meter measurements in the field.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Circular Magnetization:',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct current is passed through the part (e.g., head shot, prods). '
                      'Creates a circumferential magnetic field around the conductor. '
                      'Best for detecting longitudinal defects.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Longitudinal Magnetization:',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A coil is wrapped around the part to create a magnetic field parallel to the part axis. '
                      'Best for detecting transverse defects. Amp-turns (N × I) is the key parameter.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 12,
                        height: 1.5,
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
          color: isSelected ? _accentAlert : _bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _accentAlert : Colors.white.withOpacity(0.1),
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
    bool isInteger = false,
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
              borderSide: BorderSide(color: _accentAlert, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.numberWithOptions(
            decimal: !isInteger,
            signed: false,
          ),
          inputFormatters: [
            if (isInteger)
              FilteringTextInputFormatter.digitsOnly
            else
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
            color: isLarge ? _accentSuccess : _textPrimary,
            fontSize: isLarge ? 20 : 16,
          ),
        ),
      ],
    );
  }
}
