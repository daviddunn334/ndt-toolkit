import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../widgets/reference_widgets.dart';

class ReferenceAWSScreen extends StatelessWidget {
  const ReferenceAWSScreen({super.key});

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _accentColor = Color(0xFF00E5A8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('AWS Acceptance Workflow'),
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
              ...ReferenceData.awsWorkflowSteps.asMap().entries.map((entry) {
                return WorkflowStepCard(
                  step: entry.value,
                  stepNumber: entry.key + 1,
                  accentColor: _accentColor,
                );
              }),
              
              // Disclaimer
              const DisclaimerFooter(
                message: 'Workflow guide only. Do NOT rely on memorized acceptance values. Always refer to the AWS governing table in your approved procedure.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
