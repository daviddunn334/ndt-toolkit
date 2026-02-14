import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../widgets/reference_widgets.dart';

class ReferenceB31Screen extends StatelessWidget {
  const ReferenceB31Screen({super.key});

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _accentColor = Color(0xFFFE637E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('B31.3 / B31.8 Field Guide'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cheat sheet sections
              ...ReferenceData.b31Sections.map((section) {
                return CheatSheetSectionCard(
                  section: section,
                  accentColor: _accentColor,
                );
              }),
              
              // Disclaimer
              const DisclaimerFooter(
                message: 'Field guide with section pointers only. Always refer to the complete B31.3/B31.8 code and your project specifications for design and acceptance criteria.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
