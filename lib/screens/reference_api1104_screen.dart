import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../widgets/reference_widgets.dart';

class ReferenceAPI1104Screen extends StatelessWidget {
  const ReferenceAPI1104Screen({super.key});

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _accentColor = Color(0xFFF8B800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('API 1104 Workflow'),
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
              ...ReferenceData.api1104WorkflowSteps.asMap().entries.map((entry) {
                return WorkflowStepCard(
                  step: entry.value,
                  stepNumber: entry.key + 1,
                  accentColor: _accentColor,
                );
              }),
              
              // Disclaimer
              const DisclaimerFooter(
                message: 'Workflow guide only. Always refer to the latest API 1104 standard and your approved welding procedure for acceptance criteria.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
