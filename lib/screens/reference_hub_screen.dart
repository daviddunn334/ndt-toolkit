import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../models/reference_models.dart';

// Import all reference module screens
import 'reference_asme_screen.dart';
import 'reference_aws_screen.dart';
import 'reference_api1104_screen.dart';
import 'reference_b31_screen.dart';
import 'reference_ut_formulas_screen.dart';
import 'reference_paut_cheat_screen.dart';
import 'reference_critical_angles_screen.dart';
import 'reference_material_velocities_screen.dart';

class ReferenceHubScreen extends StatefulWidget {
  const ReferenceHubScreen({super.key});

  @override
  State<ReferenceHubScreen> createState() => _ReferenceHubScreenState();
}

class _ReferenceHubScreenState extends State<ReferenceHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Colors
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReferenceModule> get _filteredModules {
    if (_searchQuery.isEmpty) {
      return ReferenceData.modules;
    }

    final query = _searchQuery.toLowerCase();
    return ReferenceData.modules.where((module) {
      return module.title.toLowerCase().contains(query) ||
          module.subtitle.toLowerCase().contains(query) ||
          module.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  void _navigateToModule(ReferenceModule module) {
    Widget? screen;

    switch (module.id) {
      case 'asme':
        screen = const ReferenceASMEScreen();
        break;
      case 'aws':
        screen = const ReferenceAWSScreen();
        break;
      case 'api1104':
        screen = const ReferenceAPI1104Screen();
        break;
      case 'b31':
        screen = const ReferenceB31Screen();
        break;
      case 'ut_formulas':
        screen = const ReferenceUTFormulasScreen();
        break;
      case 'paut_cheat':
        screen = const ReferencePAUTCheatScreen();
        break;
      case 'critical_angles':
        screen = const ReferenceCriticalAnglesScreen();
        break;
      case 'material_velocities':
        screen = const ReferenceMaterialVelocitiesScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('Code & Standard Reference'),
        backgroundColor: const Color(0xFF6C5BFF),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5BFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        size: 32,
                        color: Color(0xFF6C5BFF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reference Library',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Quick access to standards, formulas, and field guides',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search references...',
                  hintStyle: const TextStyle(color: _textMuted),
                  prefixIcon: const Icon(Icons.search, color: _textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: _textMuted),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF242A33),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Module grid
              Expanded(
                child: _filteredModules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: _textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No references found',
                              style: TextStyle(
                                fontSize: 18,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 900 ? 2 : 1,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredModules.length,
                        itemBuilder: (context, index) {
                          final module = _filteredModules[index];
                          return _buildModuleCard(module);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(ReferenceModule module) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToModule(module),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: module.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    module.icon,
                    size: 28,
                    color: module.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: module.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
