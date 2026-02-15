import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/db_drop_calculator_service.dart';

class DbDropCalculatorScreen extends StatefulWidget {
  const DbDropCalculatorScreen({super.key});

  @override
  State<DbDropCalculatorScreen> createState() => _DbDropCalculatorScreenState();
}

class _DbDropCalculatorScreenState extends State<DbDropCalculatorScreen> {
  // Controllers
  final TextEditingController _dbController = TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final TextEditingController _remainingPercentController = TextEditingController();
  final TextEditingController _dropPercentController = TextEditingController();

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

  // Mode: 0 = dB → Ratio, 1 = Ratio → dB, 2 = Percent ↔ dB
  int _selectedMode = 0;

  // Results
  double? _resultRatio;
  double? _resultDb;
  double? _resultRemainingPercent;
  double? _resultDropPercent;
  String? _errorMessage;

  // About section expanded
  bool _isAboutExpanded = false;

  @override
  void dispose() {
    _dbController.dispose();
    _ratioController.dispose();
    _remainingPercentController.dispose();
    _dropPercentController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultRatio = null;
      _resultDb = null;
      _resultRemainingPercent = null;
      _resultDropPercent = null;
    });

    try {
      if (_selectedMode == 0) {
        // Mode 0: dB → Amplitude Ratio
        if (_dbController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter dB change';
          });
          return;
        }

        final db = double.parse(_dbController.text);

        final result = DbDropCalculatorService.calculateRatioFromDb(db: db);

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultRatio = result['ratio'];
          _resultRemainingPercent = result['remainingPercent'];
          _resultDropPercent = result['dropPercent'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'dB Drop Calculator - dB to Ratio',
          inputValues: {
            'mode': 'db_to_ratio',
            'db': db,
            'ratio': result['ratio'],
            'remaining_percent': result['remainingPercent'],
            'drop_percent': result['dropPercent'],
          },
        );
      } else if (_selectedMode == 1) {
        // Mode 1: Amplitude Ratio → dB
        if (_ratioController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter amplitude ratio';
          });
          return;
        }

        final ratio = double.parse(_ratioController.text);

        final result = DbDropCalculatorService.calculateDbFromRatio(ratio: ratio);

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultDb = result['db'];
          _resultRemainingPercent = result['remainingPercent'];
          _resultDropPercent = result['dropPercent'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'dB Drop Calculator - Ratio to dB',
          inputValues: {
            'mode': 'ratio_to_db',
            'ratio': ratio,
            'db': result['db'],
            'remaining_percent': result['remainingPercent'],
            'drop_percent': result['dropPercent'],
          },
        );
      } else if (_selectedMode == 2) {
        // Mode 2: Percent Drop ↔ dB
        // User can enter either remaining or drop percent
        if (_remainingPercentController.text.isEmpty && _dropPercentController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter either remaining % or drop %';
          });
          return;
        }

        Map<String, dynamic> result;

        if (_remainingPercentController.text.isNotEmpty) {
          final remainingPercent = double.parse(_remainingPercentController.text);
          result = DbDropCalculatorService.calculateFromRemainingPercent(
            remainingPercent: remainingPercent,
          );
        } else {
          final dropPercent = double.parse(_dropPercentController.text);
          result = DbDropCalculatorService.calculateFromDropPercent(
            dropPercent: dropPercent,
          );
        }

        if (result['error'] != null) {
          setState(() {
            _errorMessage = result['error'];
          });
          return;
        }

        setState(() {
          _resultDb = result['db'];
          _resultRatio = result['ratio'];
          _resultRemainingPercent = result['remainingPercent'];
          _resultDropPercent = result['dropPercent'];
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'dB Drop Calculator - Percent to dB',
          inputValues: {
            'mode': 'percent_to_db',
            'remaining_percent': result['remainingPercent'],
            'drop_percent': result['dropPercent'],
            'db': result['db'],
            'ratio': result['ratio'],
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
      _resultRatio = null;
      _resultDb = null;
      _resultRemainingPercent = null;
      _resultDropPercent = null;
      _errorMessage = null;
    });
  }

  void _reset() {
    setState(() {
      _dbController.clear();
      _ratioController.clear();
      _remainingPercentController.clear();
      _dropPercentController.clear();
      _clearResults();
    });
  }

  void _applyQuickReference(Map<String, dynamic> refValue) {
    setState(() {
      _dbController.text = refValue['db'].toStringAsFixed(1);
      _ratioController.clear();
      _remainingPercentController.clear();
      _dropPercentController.clear();
      _selectedMode = 0; // Switch to dB → Ratio mode
      _clearResults();
    });
    // Auto-calculate
    Future.delayed(const Duration(milliseconds: 100), () {
      _calculate();
    });
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: _accentSuccess,
      ),
    );
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
                          '📉 dB Drop Calculator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Convert dB changes to amplitude ratio and percent drop',
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
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildModeButton(
                                'dB → Ratio',
                                _selectedMode == 0,
                                () {
                                  setState(() {
                                    _selectedMode = 0;
                                    _clearResults();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModeButton(
                                'Ratio → dB',
                                _selectedMode == 1,
                                () {
                                  setState(() {
                                    _selectedMode = 1;
                                    _clearResults();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildModeButton(
                          'Percent ↔ dB',
                          _selectedMode == 2,
                          () {
                            setState(() {
                              _selectedMode = 2;
                              _clearResults();
                            });
                          },
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
                    if (_selectedMode == 0) ...[
                      _buildInputField(
                        controller: _dbController,
                        label: 'dB Change (ΔdB)',
                        hint: 'Enter dB (e.g., -6, -12)',
                        suffix: 'dB',
                        icon: Icons.trending_down,
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
                                'Negative dB indicates signal drop/attenuation',
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
                    ] else if (_selectedMode == 1) ...[
                      _buildInputField(
                        controller: _ratioController,
                        label: 'Amplitude Ratio (A2/A1)',
                        hint: 'Enter ratio (e.g., 0.5, 0.25)',
                        suffix: '',
                        icon: Icons.compare_arrows,
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
                                'Ratio must be positive. Values < 1 indicate signal drop',
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
                    ] else if (_selectedMode == 2) ...[
                      _buildInputField(
                        controller: _remainingPercentController,
                        label: 'Remaining Amplitude (%)',
                        hint: 'Enter remaining % (e.g., 50)',
                        suffix: '%',
                        icon: Icons.pie_chart,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _dropPercentController.clear();
                          }
                          _clearResults();
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _dropPercentController,
                        label: 'Drop Percent (%)',
                        hint: 'Enter drop % (e.g., 50)',
                        suffix: '%',
                        icon: Icons.arrow_downward,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _remainingPercentController.clear();
                          }
                          _clearResults();
                        },
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
                                'Enter either remaining % or drop %. Both values must be 0-100',
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

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.calculate, size: 20),
                            label: const Text(
                              'Calculate',
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
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _textSecondary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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
              if (_resultRatio != null || _resultDb != null) ...[
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

                      if (_resultDb != null) ...[
                        _buildResultRow(
                          'ΔdB',
                          '${_resultDb!.toStringAsFixed(2)} dB',
                          onCopy: () => _copyToClipboard(
                            _resultDb!.toStringAsFixed(2),
                            'dB',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_resultRatio != null) ...[
                        _buildResultRow(
                          'Amplitude Ratio (A2/A1)',
                          _resultRatio! < 0.1
                              ? _resultRatio!.toStringAsFixed(4)
                              : _resultRatio!.toStringAsFixed(3),
                          onCopy: () => _copyToClipboard(
                            _resultRatio!.toStringAsFixed(4),
                            'Ratio',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_resultRemainingPercent != null) ...[
                        _buildResultRow(
                          'Remaining Amplitude',
                          '${_resultRemainingPercent!.toStringAsFixed(1)}%',
                          onCopy: () => _copyToClipboard(
                            _resultRemainingPercent!.toStringAsFixed(1),
                            'Remaining %',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_resultDropPercent != null) ...[
                        _buildResultRow(
                          'Amplitude Drop',
                          '${_resultDropPercent!.toStringAsFixed(1)}%',
                          onCopy: () => _copyToClipboard(
                            _resultDropPercent!.toStringAsFixed(1),
                            'Drop %',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Quick Reference
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _accentWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentWarning.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: _accentWarning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Reference',
                          style: TextStyle(
                            color: _accentWarning,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a value to auto-fill',
                      style: TextStyle(
                        color: _accentWarning.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DbDropCalculatorService.getQuickReferenceValues()
                          .map((refValue) => _buildQuickRefChip(refValue))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // About This Tool
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isAboutExpanded = !_isAboutExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'About This Tool',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              _isAboutExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.blue.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isAboutExpanded) ...[
                      Divider(
                        color: Colors.blue.withOpacity(0.3),
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What is dB Drop?',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'In NDT testing, dB drop represents signal attenuation or amplitude loss. This tool helps you convert between decibel changes, amplitude ratios, and percentage drops to better understand signal behavior.',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Formulas Used:',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Amplitude Ratio to dB:\n'
                              '  ΔdB = 20 × log₁₀(ratio)\n\n'
                              'dB to Amplitude Ratio:\n'
                              '  ratio = 10^(ΔdB / 20)\n\n'
                              'Percent Conversions:\n'
                              '  remaining_ratio = remaining% / 100\n'
                              '  drop% = 100 - remaining%',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 12,
                                height: 1.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Common Examples:',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• -6 dB = 50% drop (half signal)\n'
                              '• -12 dB = 75% drop (quarter signal)\n'
                              '• -20 dB = 90% drop (10% remaining)',
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 13,
                                height: 1.6,
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
    Function(String)? onChanged,
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
            suffixText: suffix.isNotEmpty ? suffix : null,
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
          onChanged: onChanged ?? (_) => _clearResults(),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {VoidCallback? onCopy}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontSize: 16,
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy, size: 16, color: _accentPrimary),
                onPressed: onCopy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Copy',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuickRefChip(Map<String, dynamic> refValue) {
    final db = refValue['db'] as double;
    final ratio = refValue['ratio'] as double;
    final remainingPercent = refValue['remainingPercent'] as double;
    final dropPercent = refValue['dropPercent'] as double;

    return InkWell(
      onTap: () => _applyQuickReference(refValue),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _accentWarning.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${db.toStringAsFixed(0)} dB',
              style: TextStyle(
                color: _accentWarning,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ratio: ${ratio.toStringAsFixed(3)}',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              '${remainingPercent.toStringAsFixed(1)}% left',
              style: TextStyle(
                color: _textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              '${dropPercent.toStringAsFixed(1)}% drop',
              style: TextStyle(
                color: _accentAlert.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
