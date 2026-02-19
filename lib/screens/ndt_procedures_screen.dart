import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pdf_management_service.dart';
import 'company_pdfs_screen.dart';

class NDTProceduresScreen extends StatefulWidget {
  const NDTProceduresScreen({super.key});

  @override
  State<NDTProceduresScreen> createState() => _NDTProceduresScreenState();
}

class _NDTProceduresScreenState extends State<NDTProceduresScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PdfManagementService _pdfService = PdfManagementService();
  late Future<List<String>> _companiesFuture;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Dark theme colors matching the rest of the app
  static const Color _background = Color(0xFF1E232A);
  static const Color _elevatedSurface = Color(0xFF242A33);
  static const Color _cardSurface = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _secondaryText = Color(0xFFAEBBC8);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _secondaryAccent = Color(0xFF00E5A8);
  static const Color _yellowAccent = Color(0xFFF8B800);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _refreshCompanies();
  }

  void _refreshCompanies() {
    setState(() {
      _companiesFuture = _pdfService.getCompanies(_userId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showAddCompanyDialog() async {
    final TextEditingController controller = TextEditingController();
    bool isCreating = false;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _elevatedSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: _primaryAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Add Company',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the company name to create a new procedures folder.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _mutedText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: _cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        style: const TextStyle(color: _primaryText),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'e.g. Boardwalk Pipeline',
                          hintStyle: TextStyle(color: _mutedText),
                          prefixIcon: const Icon(
                            Icons.folder_outlined,
                            color: _mutedText,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _submitAddCompany(
                          controller,
                          setDialogState,
                          () => isCreating = true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isCreating
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: _mutedText),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isCreating
                              ? null
                              : () async {
                                  setDialogState(() => isCreating = true);
                                  await _submitAddCompany(
                                      controller, setDialogState, () {});
                                  // Dialog is already closed at this point — do NOT
                                  // call setDialogState here or Flutter will assert
                                  // "_dependents.isEmpty is not true".
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryAccent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _primaryAccent.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add, size: 18),
                          label:
                              Text(isCreating ? 'Creating...' : 'Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _submitAddCompany(
    TextEditingController controller,
    StateSetter setDialogState,
    VoidCallback onStart,
  ) async {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    onStart();

    final normalized = name.toLowerCase().replaceAll(' ', '_');
    final success = await _pdfService.createCompanyFolder(_userId, normalized);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        _refreshCompanies();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00E5A8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"$name" folder created successfully!',
                    style: const TextStyle(color: _primaryText),
                  ),
                ),
              ],
            ),
            backgroundColor: _elevatedSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to create folder. Please try again.',
                    style: TextStyle(color: _primaryText),
                  ),
                ),
              ],
            ),
            backgroundColor: _elevatedSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatCompanyName(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _elevatedSurface,
        foregroundColor: _primaryText,
        elevation: 0,
        title: const Text(
          'Company Procedures',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshCompanies,
            icon: Icon(Icons.refresh, color: _mutedText),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      // ── The key fix: SafeArea > Column > Expanded wraps the animations
      // ── so the inner Column+Expanded has bounded height constraints.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header card ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 28),
                          decoration: BoxDecoration(
                            color: _cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _yellowAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.folder_special_rounded,
                                  size: 32,
                                  color: _yellowAccent,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Company Procedures',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Select a company to view or upload NDT procedures',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _secondaryText,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Section label ────────────────────────────────
                        Text(
                          'Companies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _secondaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Company list ─────────────────────────────────
                        Expanded(
                          child: FutureBuilder<List<String>>(
                            future: _companiesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: _primaryAccent,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 48,
                                          color: Colors.red.shade400),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Error loading companies',
                                        style:
                                            TextStyle(color: _primaryText),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _refreshCompanies,
                                        child: const Text(
                                          'Try Again',
                                          style: TextStyle(
                                              color: _primaryAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final companies = snapshot.data ?? [];

                              return ListView(
                                children: [
                                  ...companies.map(
                                    (company) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 12),
                                      child: _buildCompanyCard(company),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildAddCompanyCard(),
                                  const SizedBox(height: 80),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(String company) {
    final displayName = _formatCompanyName(company);

    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyPdfsScreen(
                  company: company,
                  userId: _userId,
                ),
              ),
            ).then((_) => _refreshCompanies());
          },
          borderRadius: BorderRadius.circular(16),
          hoverColor: Colors.white.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: _primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _primaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap to view & upload procedures',
                        style: TextStyle(fontSize: 12, color: _mutedText),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: _primaryAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCompanyCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _secondaryAccent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _secondaryAccent.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddCompanyDialog,
          borderRadius: BorderRadius.circular(16),
          hoverColor: _secondaryAccent.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _secondaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _secondaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Company',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _secondaryAccent,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Create a new folder for your company's procedures",
                        style: TextStyle(fontSize: 12, color: _mutedText),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: _secondaryAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
