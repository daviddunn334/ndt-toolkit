import 'dart:math';
import 'package:flutter/material.dart';
import '../data/material_velocities_data.dart';
import '../models/reference_models.dart';

class ReferenceCriticalAnglesScreen extends StatefulWidget {
  const ReferenceCriticalAnglesScreen({super.key});

  @override
  State<ReferenceCriticalAnglesScreen> createState() => _ReferenceCriticalAnglesScreenState();
}

class _ReferenceCriticalAnglesScreenState extends State<ReferenceCriticalAnglesScreen> {
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _vL2Controller = TextEditingController();
  final TextEditingController _vS2Controller = TextEditingController();

  double? _criticalAngleL;
  double? _criticalAngleS;

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentColor = Color(0xFFF8B800);

  @override
  void dispose() {
    _v1Controller.dispose();
    _vL2Controller.dispose();
    _vS2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final v1 = double.parse(_v1Controller.text);
      final vL2 = double.parse(_vL2Controller.text);
      final vS2 = double.parse(_vS2Controller.text);

      setState(() {
        // Calculate critical angle for longitudinal wave
        if (vL2 > v1) {
          final ratio = v1 / vL2;
          if (ratio <= 1.0) {
            _criticalAngleL = asin(ratio) * 180.0 / pi;
          } else {
            _criticalAngleL = null;
          }
        } else {
          _criticalAngleL = null;
        }

        // Calculate critical angle for shear wave
        if (vS2 > v1) {
          final ratio = v1 / vS2;
          if (ratio <= 1.0) {
            _criticalAngleS = asin(ratio) * 180.0 / pi;
          } else {
            _criticalAngleS = null;
          }
        } else {
          _criticalAngleS = null;
        }
      });
    } catch (e) {
      setState(() {
        _criticalAngleL = null;
        _criticalAngleS = null;
      });
    }
  }

  void _loadPreset(MaterialPair pair) {
    setState(() {
      _v1Controller.text = pair.v1.toStringAsFixed(0);
      _vL2Controller.text = pair.vL2.toStringAsFixed(0);
      _vS2Controller.text = pair.vS2.toStringAsFixed(0);
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('Critical Angles Calculator'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calculator card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Velocities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _v1Controller,
                      label: 'Medium 1 Velocity (V₁) [m/s]',
                      hint: 'e.g., 2337 (Rexolite)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _vL2Controller,
                      label: 'Medium 2 Longitudinal (VL₂) [m/s]',
                      hint: 'e.g., 5900 (Steel)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _vS2Controller,
                      label: 'Medium 2 Shear (VS₂) [m/s]',
                      hint: 'e.g., 3230 (Steel)',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Calculate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Results card
              if (_criticalAngleL != null || _criticalAngleS != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Critical Angles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_criticalAngleL != null)
                        _buildResult(
                          'Longitudinal Wave',
                          '${_criticalAngleL!.toStringAsFixed(2)}°',
                        ),
                      if (_criticalAngleL == null)
                        _buildResult(
                          'Longitudinal Wave',
                          'N/A (V₁ >= VL₂)',
                        ),
                      const SizedBox(height: 12),
                      if (_criticalAngleS != null)
                        _buildResult(
                          'Shear Wave',
                          '${_criticalAngleS!.toStringAsFixed(2)}°',
                        ),
                      if (_criticalAngleS == null)
                        _buildResult(
                          'Shear Wave',
                          'N/A (V₁ >= VS₂)',
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Preset pairs
              const Text(
                'Common Material Pairs (Typical Values)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...MaterialVelocitiesData.presetPairs.map((pair) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _loadPreset(pair),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pair.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'θcrit(L): ${pair.criticalAngleL?.toStringAsFixed(1) ?? 'N/A'}° | θcrit(S): ${pair.criticalAngleS?.toStringAsFixed(1) ?? 'N/A'}°',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: _accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textMuted),
            filled: true,
            fillColor: _bgElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _accentColor,
          ),
        ),
      ],
    );
  }
}
