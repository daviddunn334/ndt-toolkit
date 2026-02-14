import 'package:flutter/material.dart';
import '../data/paut_formulas_data.dart';
import '../widgets/reference_widgets.dart';

class ReferencePAUTCheatScreen extends StatefulWidget {
  const ReferencePAUTCheatScreen({super.key});

  @override
  State<ReferencePAUTCheatScreen> createState() => _ReferencePAUTCheatScreenState();
}

class _ReferencePAUTCheatScreenState extends State<ReferencePAUTCheatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _accentColor = Color(0xFF00E5A8);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredSections {
    if (_searchQuery.isEmpty) {
      return PAUTFormulasData.sections;
    }

    final query = _searchQuery.toLowerCase();
    return PAUTFormulasData.sections.where((section) {
      final titleMatch = section.title.toLowerCase().contains(query);
      final descMatch = section.description?.toLowerCase().contains(query) ?? false;
      final itemsMatch = section.items.any((item) =>
          item.label.toLowerCase().contains(query) ||
          item.value.toLowerCase().contains(query) ||
          (item.note?.toLowerCase().contains(query) ?? false));
      
      return titleMatch || descMatch || itemsMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('PAUT Cheat Sheet'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ReferenceSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                hintText: 'Search PAUT formulas...',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _filteredSections.map((section) {
                  return CheatSheetSectionCard(
                    section: section,
                    accentColor: _accentColor,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
