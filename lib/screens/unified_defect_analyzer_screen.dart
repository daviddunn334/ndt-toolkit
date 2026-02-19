import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/defect_entry.dart';
import '../models/defect_type.dart';
import '../services/defect_service.dart';
import '../services/defect_type_service.dart';
import '../services/pdf_management_service.dart';
import '../services/analytics_service.dart';
import '../services/image_service.dart';

/// Unified AI Defect Analyzer Screen
/// Combines photo capture with defect logging and severity rating
class UnifiedDefectAnalyzerScreen extends StatefulWidget {
  const UnifiedDefectAnalyzerScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedDefectAnalyzerScreen> createState() => _UnifiedDefectAnalyzerScreenState();
}

class _UnifiedDefectAnalyzerScreenState extends State<UnifiedDefectAnalyzerScreen> {
  static const bool _aiToolsDisabled = true;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final DefectService _defectService = DefectService();
  final DefectTypeService _defectTypeService = DefectTypeService();
  final PdfManagementService _pdfManagementService = PdfManagementService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final ImageService _imageService = ImageService();
  
  final TextEditingController _pipeODController = TextEditingController();
  final TextEditingController _pipeNWTController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedDefectType;
  String? _selectedClient;
  String? _selectedSeverity;
  List<DefectType> _defectTypes = [];
  List<String> _clients = [];
  List<XFile> _selectedPhotos = [];
  bool _isLoading = false;
  bool _isLoadingTypes = true;
  bool _isLoadingClients = true;
  
  final List<String> _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _loadDefectTypes();
    _loadClients();
  }

  Future<void> _loadDefectTypes() async {
    setState(() => _isLoadingTypes = true);
    _defectTypeService.getActiveDefectTypes().listen((types) {
      setState(() {
        _defectTypes = types;
        _isLoadingTypes = false;
      });
    });
  }

  Future<void> _loadClients() async {
    setState(() => _isLoadingClients = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final clients = await _pdfManagementService.getCompanies(userId);
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      print('Error loading clients: $e');
      setState(() => _isLoadingClients = false);
    }
  }

  bool get _isHardspot => 
      _selectedDefectType?.toLowerCase().contains('hardspot') ?? false;

  String get _depthLabel => _isHardspot ? 'Max HB' : 'Depth (in)';

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        setState(() {
          _selectedPhotos.add(photo);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking images: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _submitDefect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDefectType == null) {
      _showErrorSnackBar('Please select a defect type');
      return;
    }

    if (_selectedClient == null) {
      _showErrorSnackBar('Please select a client');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload photos if any
      List<String>? photoUrls;
      if (_selectedPhotos.isNotEmpty) {
        photoUrls = [];
        for (final photo in _selectedPhotos) {
          final url = await _imageService.uploadReportImage(photo, userId);
          if (url != null) {
            photoUrls.add(url);
          }
        }
      }

      final defectEntry = DefectEntry(
        id: '',
        userId: userId,
        defectType: _selectedDefectType!,
        pipeOD: double.parse(_pipeODController.text),
        pipeNWT: double.parse(_pipeNWTController.text),
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        depth: double.parse(_depthController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        clientName: _selectedClient!,
        userSeverityRating: _selectedSeverity,
        photoUrls: photoUrls,
        photoMetadata: photoUrls != null ? {
          'photoCount': photoUrls.length,
          'uploadedAt': DateTime.now().toUtc().toIso8601String(),
        } : null,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await _defectService.addDefectEntry(defectEntry);

      await _analyticsService.logDefectLogged(
        _selectedDefectType!,
        _selectedClient!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    photoUrls != null && photoUrls.isNotEmpty
                        ? 'Defect logged with ${photoUrls.length} photo(s)!'
                        : 'Defect logged successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00E5A8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error logging defect: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFE637E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _pipeODController.dispose();
    _pipeNWTController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_aiToolsDisabled) {
      return _buildDisabledView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'AI Defect Analyzer',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: (_isLoadingTypes || _isLoadingClients)
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
              ),
            )
          : _isLoading
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6C5BFF).withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF6C5BFF),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Photos optional • All measurements in inches',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEDF9FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Photo Section Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5BFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            color: Color(0xFF6C5BFF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Photos (Optional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEDF9FF),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedPhotos.length} photo(s)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAEBBC8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Photo Preview Grid
                    if (_selectedPhotos.isNotEmpty)
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return _buildPhotoPreview(_selectedPhotos[index], index);
                          },
                        ),
                      ),

                    // Photo Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text('Camera'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C5BFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFF6C5BFF),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: const Text('Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C5BFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFF6C5BFF),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Defect Details Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5A8).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.assessment,
                            color: Color(0xFF00E5A8),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Defect Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEDF9FF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Pipe OD Field
                    _buildFieldLabel('Pipe OD (in)', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pipeODController,
                      hint: 'Enter pipe outside diameter',
                      icon: Icons.straighten,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pipe OD';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Pipe OD must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Pipe NWT Field
                    _buildFieldLabel('Pipe NWT (in)', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pipeNWTController,
                      hint: 'Enter nominal wall thickness',
                      icon: Icons.width_normal,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pipe NWT';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Pipe NWT must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Defect Type Dropdown
                    _buildFieldLabel('Defect Type', required: true),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedDefectType,
                      hint: 'Select defect type',
                      icon: Icons.category,
                      items: _defectTypes.map((defectType) {
                        return DropdownMenuItem<String>(
                          value: defectType.name,
                          child: Text(defectType.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDefectType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Length Field
                    _buildFieldLabel('Length (in)', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _lengthController,
                      hint: 'Enter length',
                      icon: Icons.straighten,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter length';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Length must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Width Field
                    _buildFieldLabel('Width (in)', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _widthController,
                      hint: 'Enter width',
                      icon: Icons.width_normal,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter width';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Width must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Depth/Max HB Field
                    _buildFieldLabel(_depthLabel, required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _depthController,
                      hint: _isHardspot ? 'Enter Max HB value' : 'Enter depth',
                      icon: Icons.height,
                      suffix: _isHardspot ? 'HB' : 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ${_isHardspot ? 'Max HB' : 'depth'}';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return '${_isHardspot ? 'Max HB' : 'Depth'} must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Severity Rating Dropdown
                    _buildFieldLabel('Severity Rating', required: false),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedSeverity,
                      hint: 'Select severity (optional)',
                      icon: Icons.warning_amber,
                      items: _severityLevels.map((severity) {
                        return DropdownMenuItem<String>(
                          value: severity,
                          child: Row(
                            children: [
                              _getSeverityIcon(severity),
                              const SizedBox(width: 8),
                              Text(severity),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSeverity = value;
                        });
                      },
                      isRequired: false,
                    ),

                    const SizedBox(height: 20),

                    // Client Selection Dropdown
                    _buildFieldLabel('Client', required: true),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedClient,
                      hint: 'Select client company',
                      icon: Icons.business,
                      items: _clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client,
                          child: Text(client.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Notes Field
                    _buildFieldLabel('Notes', required: false),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFEDF9FF)),
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes or observations...',
                        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.note, color: Color(0xFFAEBBC8)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF242A33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C5BFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitDefect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF6C5BFF).withOpacity(0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Log Defect',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Tip
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8B800).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF8B800).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFF8B800),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tip: Adding photos and severity ratings helps build better AI training data for future analysis',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFEDF9FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDisabledView() {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'AI Defect Analyzer',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8B800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFF8B800),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'AI Defect Analyzer is temporarily disabled',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDF9FF),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We\'ve paused AI features to prevent unexpected costs.\nPlease check back soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFAEBBC8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Logging Defect...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEDF9FF),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Uploading photos and saving defect data',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFAEBBC8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(XFile photo, int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? Image.network(
                    photo.path,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(photo.path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFE637E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool required}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEDF9FF),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFE637E),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
        prefixIcon: Icon(icon, color: const Color(0xFFAEBBC8)),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Color(0xFFAEBBC8)),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFE637E)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF242A33),
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
        prefixIcon: Icon(icon, color: const Color(0xFFAEBBC8)),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFE637E)),
      ),
      items: items,
      onChanged: onChanged,
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      } : null,
    );
  }

  Widget _getSeverityIcon(String severity) {
    IconData iconData;
    Color color;

    switch (severity) {
      case 'Low':
        iconData = Icons.check_circle;
        color = const Color(0xFF00E5A8);
        break;
      case 'Medium':
        iconData = Icons.warning;
        color = const Color(0xFFF8B800);
        break;
      case 'High':
        iconData = Icons.error;
        color = const Color(0xFFFF9D3D);
        break;
      case 'Critical':
        iconData = Icons.dangerous;
        color = const Color(0xFFFE637E);
        break;
      default:
        iconData = Icons.help;
        color = const Color(0xFFAEBBC8);
    }

    return Icon(iconData, color: color, size: 20);
  }
}
