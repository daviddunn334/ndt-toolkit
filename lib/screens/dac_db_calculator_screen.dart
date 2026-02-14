import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/dac_db_calculator_service.dart';

class DacDbCalculatorScreen extends StatefulWidget {
  const DacDbCalculatorScreen({super.key});

  @override
  State<DacDbCalculatorScreen> createState() => _DacDbCalculatorScreenState();
}

class _DacDbCalculatorScreenState extends State<DacDbCalculatorScreen> {
  // Controllers
  final TextEditingController _percentDacController = TextEditingController();
  final TextEditingController _dbController = TextEditingController();

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

  // Mode: true = Mode A (%DAC → dB), false = Mode B (dB → %DAC)
  bool _isPercentDacToDbMode = true;

  // Results
  double? _resultDb;
  double? _resultPercentDac;
  double? _amplitudeRatio;
  String? _errorMessage;

  @override
  void dispose() {
    _percentDacController.dispose();
    _dbController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultDb = null;
      _resultPercentDac = null;
      _amplitudeRatio = null;
    });

    try {
      if (_isPercentDacToDbMode) {
        // Mode A: %DAC → dB
        if (_percentDacController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter percent DAC';
          });
          return;
        }

        final percentDac = double.parse(_percentDacController.text);

        final result = DacDbCalculatorService.calculateDbFromPercentDac(
          percentDac: percentDac,
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultDb = result['dB'];
          _amplitudeRatio = result['amplitudeRatio'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'DAC-dB Calculator - %DAC to dB',
          inputValues: {
            'mode': 'percent_dac_to_db',
            'percent_dac': percentDac,
            'dB': result['dB'],
            'amplitude_ratio': result['amplitudeRatio'],
          },
        );
      } else {
        // Mode B: dB → %DAC
        if (_dbController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter dB change';
          });
          return;
        }

        final db = double.parse(_dbController.text);

        final result = DacDbCalculatorService.calculatePercentDacFromDb(
          db: db,
        );

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultPercentDac = result['percentDac'];
          _amplitudeRatio = result['amplitudeRatio'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'DAC-dB Calculator - dB to %DAC',
          inputValues: {
            'mode': 'db_to_percent_dac',
            'dB': db,
            'percent_dac': result['percentDac'],
            'amplitude_ratio': result['amplitudeRatio'],
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
      _resultDb = null;
      _resultPercentDac = null;
      _amplitudeRatio = null;
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
                          '📐 %DAC ↔ dB Conversion',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Convert between %DAC and decibel difference',
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
                            'Conversion Mode',
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
                            '%DAC → dB',
                            _isPercentDacToDbMode,
                            () {
                              setState(() {
                                _isPercentDacToDbMode = true;
                                _clearResults();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeButton(
                            'dB → %DAC',
                            !_isPercentDacToDbMode,
                            () {
                              setState(() {
                                _isPercentDacToDbMode = false;
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
                      'Input',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Mode-specific inputs
                    if (_isPercentDacToDbMode) ...[
                      _buildInputField(
                        controller: _percentDacController,
                        label: 'Percent DAC (%DAC)',
                        hint: 'Enter % DAC (e.g., 50, 100, 200)',
                        suffix: '% DAC',
                        icon: Icons.percent,
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
                                '%DAC is the signal amplitude as a percentage of the DAC reference curve',
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
                        controller: _dbController,
                        label: 'dB Change',
                        hint: 'Enter dB (+ or -)',
                        suffix: 'dB',
                        icon: Icons.graphic_eq,
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
                                'dB is the decibel difference relative to the DAC reference (0 dB = 100% DAC)',
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
                        _isPercentDacToDbMode ? 'Convert to dB' : 'Convert to %DAC',
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

              // Results
              if (_amplitudeRatio != null) ...[
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

                      if (_isPercentDacToDbMode) ...[
                        _buildResultRow(
                          'dB Difference',
                          '${_resultDb!.toStringAsFixed(2)} dB',
                          isLarge: true,
                        ),
                        const SizedBox(height: 12),
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
                                  _resultDb! >= 0
                                      ? 'Adjust gain by +${_resultDb!.toStringAsFixed(2)} dB to reach ${_percentDacController.text}% DAC from 100% DAC'
                                      : 'Adjust gain by ${_resultDb!.toStringAsFixed(2)} dB to reach ${_percentDacController.text}% DAC from 100% DAC',
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
                      ] else ...[
                        _buildResultRow(
                          'Percent DAC',
                          '${_resultPercentDac!.toStringAsFixed(2)}% DAC',
                          isLarge: true,
                        ),
                        const SizedBox(height: 12),
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
                                  'A ${_dbController.text} dB change results in ${_resultPercentDac!.toStringAsFixed(1)}% DAC',
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
                      
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      
                      _buildResultRow(
                        'Amplitude Ratio (R)',
                        _amplitudeRatio!.toStringAsFixed(4),
                      ),
                      
                      const SizedBox(height: 16),
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
                              Icons.help_outline,
                              color: Colors.blue.shade300,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'R is the amplitude ratio relative to the DAC reference (R = %DAC / 100)',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
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

              // Example values
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.purple.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Common Reference Values',
                          style: TextStyle(
                            color: Colors.purple.shade100,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 100% DAC = 0 dB (reference)\n'
                      '• 50% DAC ≈ -6.02 dB\n'
                      '• 80% DAC ≈ -1.94 dB\n'
                      '• 200% DAC ≈ +6.02 dB\n'
                      '• 25% DAC ≈ -12.04 dB',
                      style: TextStyle(
                        color: Colors.purple.shade100,
                        fontSize: 13,
                        height: 1.6,
                        fontFamily: 'monospace',
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
                          'About %DAC ↔ dB Conversion',
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
                      'Percent DAC (%DAC) represents signal amplitude as a percentage of the Distance Amplitude Correction (DAC) reference curve. This is a common UT field calculation when adjusting gain to reach a desired %DAC level.',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Formulas:',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Amplitude ratio: R = %DAC / 100\n'
                      '%DAC → dB: dB = 20 × log₁₀(R)\n'
                      'dB → %DAC: %DAC = 100 × 10^(dB/20)',
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
            fontSize: 14,
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
