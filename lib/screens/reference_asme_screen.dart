import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../widgets/reference_widgets.dart';

class ReferenceASMEScreen extends StatelessWidget {
  const ReferenceASMEScreen({super.key});

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _accentColor = Color(0xFF6C5BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('ASME Quick Reference'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workflow steps
              ...ReferenceData.asmeWorkflowSteps.asMap().entries.map((entry) {
                return WorkflowStepCard(
                  step: entry.value,
                  stepNumber: entry.key + 1,
                  accentColor: _accentColor,
                );
              }),
              
              // Disclaimer
              const DisclaimerFooter(
                message: 'Summary only. Refer to the latest ASME code and project procedure for governing requirements.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
