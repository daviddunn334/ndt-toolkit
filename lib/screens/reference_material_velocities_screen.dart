import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/material_velocities_data.dart';
import '../models/reference_models.dart';

class ReferenceMaterialVelocitiesScreen extends StatefulWidget {
  const ReferenceMaterialVelocitiesScreen({super.key});

  @override
  State<ReferenceMaterialVelocitiesScreen> createState() => _ReferenceMaterialVelocitiesScreenState();
}

class _ReferenceMaterialVelocitiesScreenState extends State<ReferenceMaterialVelocitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentColor = Color(0xFFFE637E);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaterialVelocity> get _filteredMaterials {
    if (_searchQuery.isEmpty) {
      return MaterialVelocitiesData.materials;
    }

    final query = _searchQuery.toLowerCase();
    return MaterialVelocitiesData.materials.where((material) {
      return material.material.toLowerCase().contains(query) ||
          material.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          (material.notes?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        duration: const Duration(seconds: 1),
        backgroundColor: _accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      appBar: AppBar(
        title: const Text('Material Velocities'),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search materials...',
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
                  fillColor: _bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Material list
            Expanded(
              child: _filteredMaterials.isEmpty
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
                            'No materials found',
                            style: TextStyle(
                              fontSize: 18,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filteredMaterials.length,
                      itemBuilder: (context, index) {
                        final material = _filteredMaterials[index];
                        return _buildMaterialCard(material);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(MaterialVelocity material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material name
            Row(
              children: [
                Expanded(
                  child: Text(
                    material.material,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            if (material.notes != null) ...[
              const SizedBox(height: 6),
              Text(
                material.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Velocities
            Row(
              children: [
                Expanded(
                  child: _buildValueTile(
                    'VL',
                    '${material.longitudinalVelocity.toStringAsFixed(0)} m/s',
                    material.longitudinalVelocity.toStringAsFixed(0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValueTile(
                    'VS',
                    '${material.shearVelocity.toStringAsFixed(0)} m/s',
                    material.shearVelocity.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
            
            if (material.density != null) ...[
              const SizedBox(height: 12),
              _buildValueTile(
                'Density',
                '${material.density!.toStringAsFixed(0)} kg/m³',
                material.density!.toStringAsFixed(0),
              ),
            ],
            
            // Tags
            if (material.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: material.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile(String label, String displayValue, String copyValue) {
    return GestureDetector(
      onTap: () => _copyValue(copyValue),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _accentColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                ),
                Icon(
                  Icons.content_copy,
                  size: 14,
                  color: _accentColor.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _bgElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
