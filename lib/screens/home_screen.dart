import 'package:flutter/material.dart';
import '../calculators/abs_es_calculator.dart';
import '../calculators/b31g_calculator.dart';
import '../screens/ndt_procedures_screen.dart';
import '../calculators/soc_eoc_calculator.dart';
import '../calculators/dent_ovality_calculator.dart';
import '../screens/unified_defect_analyzer_screen.dart';
import '../screens/paut_setup_screen.dart';
import '../screens/field_strength_estimator_screen.dart';
import '../screens/sweep_simulator_screen.dart';
import '../screens/beam_plot_visualizer_screen.dart';
import '../screens/method_hours_screen.dart';
import '../screens/most_used_tools_screen.dart';
import '../screens/beam_geometry_category_screen.dart';
import '../screens/array_geometry_category_screen.dart';
import '../screens/pipeline_specific_category_screen.dart';
import '../screens/reference_hub_screen.dart';
import '../screens/amplitude_db_category_screen.dart';
import '../screens/magnetic_particle_category_screen.dart';
import '../screens/field_productivity_category_screen.dart';
import '../screens/focal_law_tools_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A), // Main background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 32.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEDF9FF), // Primary text
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to your NDT inspection toolkit',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFAEBBC8), // Secondary text
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ── AI-Powered Tools Promo Card (GREEN) ⭐ ──────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: _buildAIToolsPromoCard(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Quick Actions (4 Diverse Tools)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEDF9FF), // Primary text
                          ),
                        ),
                        const SizedBox(height: 16),
                        isLargeScreen
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'Defect Analyzer',
                                      Icons.auto_awesome,
                                      const Color(0xFF00E5A8), // AI Green
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const UnifiedDefectAnalyzerScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'PAUT Setup',
                                      Icons.waves_outlined,
                                      const Color(0xFF6C5BFF), // Purple
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PautSetupScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'Field Strength',
                                      Icons.blur_on,
                                      const Color(0xFFFE637E), // Pink
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const FieldStrengthEstimatorScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickActionCard(
                                      context,
                                      'B31G',
                                      Icons.engineering_outlined,
                                      const Color(0xFFF8B800), // Yellow
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const B31GCalculator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildQuickActionCard(
                                    context,
                                    'Defect Analyzer',
                                    Icons.auto_awesome,
                                    const Color(0xFF00E5A8), // AI Green
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const UnifiedDefectAnalyzerScreen(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickActionCard(
                                    context,
                                    'PAUT Setup',
                                    Icons.waves_outlined,
                                    const Color(0xFF6C5BFF), // Purple
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PautSetupScreen(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickActionCard(
                                    context,
                                    'Field Strength',
                                    Icons.blur_on,
                                    const Color(0xFFFE637E), // Pink
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FieldStrengthEstimatorScreen(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildQuickActionCard(
                                    context,
                                    'B31G',
                                    Icons.engineering_outlined,
                                    const Color(0xFFF8B800), // Yellow
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const B31GCalculator(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── New Tools Carousel ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32.0 : 24.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Recently Added',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEDF9FF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5BFF).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF6C5BFF).withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6C5BFF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32.0 : 24.0,
                          ),
                          children: [
                            _buildNewToolCard(
                              context,
                              'PAUT Setup',
                              'Phased Array Assistant',
                              Icons.waves_outlined,
                              const Color(0xFF6C5BFF),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PautSetupScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildNewToolCard(
                              context,
                              'Sweep Simulator',
                              'Visualize beam sweeps',
                              Icons.graphic_eq,
                              const Color(0xFF00E5A8),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SweepSimulatorScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildNewToolCard(
                              context,
                              'Beam Plot',
                              'Visualizer tool',
                              Icons.show_chart,
                              const Color(0xFFFE637E),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BeamPlotVisualizerScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildNewToolCard(
                              context,
                              'Method Hours',
                              'Track productivity',
                              Icons.access_time,
                              const Color(0xFFF8B800),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MethodHoursScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Procedures Promo Card ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: _buildProceduresPromoCard(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Most Used Tools ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: _buildMostUsedToolsSection(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Explore by Category ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: Text(
                      'Explore by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEDF9FF),
                      ),
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Category Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 32.0 : 24.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildCategoryCard(
                        context,
                        'Beam\nGeometry',
                        Icons.show_chart,
                        const Color(0xFF6C5BFF),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BeamGeometryCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Array/PAUT\nTools',
                        Icons.grid_on,
                        const Color(0xFF00E5A8),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArrayGeometryCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Pipeline\nTools',
                        Icons.engineering,
                        const Color(0xFFF8B800),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PipelineSpecificCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Reference\nMaterials',
                        Icons.library_books,
                        const Color(0xFFFE637E),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReferenceHubScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Amplitude\n& dB',
                        Icons.equalizer,
                        const Color(0xFF2A9D8F),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AmplitudeDbCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Magnetic\nParticle',
                        Icons.blur_on,
                        const Color(0xFFE76F51),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MagneticParticleCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Field\nProductivity',
                        Icons.business_center,
                        const Color(0xFF9B5DE5),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FieldProductivityCategoryScreen(),
                          ),
                        ),
                      ),
                      _buildCategoryCard(
                        context,
                        'Focal Law\nTools',
                        Icons.lens,
                        const Color(0xFFF15BB5),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FocalLawToolsCategoryScreen(),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Essential Resources
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.0 : 24.0,
                    ),
                    child: Text(
                      'Essential Resources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEDF9FF), // Primary text
                      ),
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // Resource Cards Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 32.0 : 24.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isLargeScreen ? 2.5 : 3.5,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildResourceCard(
                        context,
                        'ABS + ES Calculator',
                        'Calculate ABS and ES values',
                        Icons.calculate_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AbsEsCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'SOC & EOC',
                        'Start/End of Coating calculations',
                        Icons.straighten,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SocEocCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'Dent Ovality',
                        'Calculate dent ovality percentage',
                        Icons.circle_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DentOvalityCalculator(),
                          ),
                        ),
                      ),
                      _buildResourceCard(
                        context,
                        'Company Directory',
                        'Access company contacts',
                        Icons.people_outline,
                        () => Navigator.pushNamed(context, '/company_directory'),
                      ),
                    ]),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // AI-POWERED TOOLS PROMO CARD (GREEN ACCENT)
  // ══════════════════════════════════════════════════════════
  Widget _buildAIToolsPromoCard(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UnifiedDefectAnalyzerScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF00E5A8).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5A8).withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A313B),
                const Color(0xFF252C35),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5A8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00E5A8).withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 30,
                    color: Color(0xFF00E5A8),
                  ),
                ),
                const SizedBox(width: 18),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "AI" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5A8).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00E5A8).withOpacity(0.35),
                          ),
                        ),
                        child: const Text(
                          '🤖  AI-Powered',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00E5A8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const Text(
                        'AI Defect Analysis & Identification',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEDF9FF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Use cutting-edge AI to analyze defects and identify them from photos. Smart, fast, and accurate.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAEBBC8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // CTA
                      Row(
                        children: [
                          const Text(
                            'Try AI tools',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00E5A8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: Color(0xFF00E5A8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // NEW TOOL CARD (for horizontal carousel)
  // ══════════════════════════════════════════════════════════
  Widget _buildNewToolCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: accentColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAEBBC8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MOST USED TOOLS SECTION
  // ══════════════════════════════════════════════════════════
  Widget _buildMostUsedToolsSection(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MostUsedToolsScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5BFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 28,
                  color: Color(0xFF6C5BFF),
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Used Tools',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEDF9FF),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'See your frequently used calculators and tools',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFAEBBC8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFF7F8A96),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CATEGORY CARD (for Explore by Category grid)
  // ══════════════════════════════════════════════════════════
  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEDF9FF),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ORIGINAL HELPER METHODS
  // ══════════════════════════════════════════════════════════
  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B), // Card surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDF9FF), // Primary text
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: const Color(0xFF7F8A96), // Muted text
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceduresPromoCard(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NDTProceduresScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFF8B800).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF8B800).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A313B),
                const Color(0xFF252C35),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF8B800).withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    size: 30,
                    color: Color(0xFFF8B800),
                  ),
                ),
                const SizedBox(width: 18),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "New Feature" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8B800).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF8B800).withOpacity(0.35),
                          ),
                        ),
                        child: const Text(
                          '✨  New Feature',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF8B800),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const Text(
                        'Upload Your Own Procedures',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEDF9FF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add your company\'s NDT procedures as PDFs — access them anytime, right in the app.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAEBBC8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // CTA
                      Row(
                        children: [
                          const Text(
                            'Get started',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF8B800),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: Color(0xFFF8B800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B), // Card surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C5BFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF6C5BFF), // Primary accent
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDF9FF), // Primary text
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFAEBBC8), // Secondary text
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: const Color(0xFF7F8A96), // Muted text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
