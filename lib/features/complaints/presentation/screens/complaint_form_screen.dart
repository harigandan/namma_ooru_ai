import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/priority_indicator.dart';

class ComplaintFormScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const ComplaintFormScreen({super.key, this.onSubmitted});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController =
      TextEditingController(text: "Anna Nagar 2nd Avenue, Ward 102, Chennai");

  String _selectedCategory = "water_supply";
  String _detectedPriority = "high";
  bool _isAnonymous = false;
  bool _isAnalyzingAI = false;
  bool _isSubmitting = false;

  // GPS & Camera Photo State
  final ImagePicker _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoBase64;
  String? _photoFilename;
  double _latitude = 13.0850;
  double _longitude = 80.2101;
  double? _gpsAccuracy;
  DateTime? _captureTime;
  String? _resolvedWardName;
  String? _resolvedWardNumber;
  bool _isCapturingLocation = false;
  String? _locationWarning;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _triggerAIAnalysis(String text) {
    if (text.length < 8) return;

    setState(() => _isAnalyzingAI = true);

    ApiService().classifyAI(text).then((res) {
      if (!mounted) return;
      setState(() {
        _isAnalyzingAI = false;
        _selectedCategory = res['predicted_category'] ?? _selectedCategory;
        _detectedPriority = res['predicted_priority'] ?? _detectedPriority;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isAnalyzingAI = false);
    });
  }

  Future<void> _capturePhotoWithGPS(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isCapturingLocation = true;
      _locationWarning = null;
    });

    try {
      // 1. Pick or capture photograph
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isCapturingLocation = false);
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final filename = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Obtain GPS Coordinates at the exact moment of photo capture
      double lat = _latitude;
      double lng = _longitude;
      double? accuracy;
      String? warning;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        warning = l10n.tr('gps_disabled_warning');
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          warning = l10n.tr('gps_disabled_warning');
        } else {
          try {
            final Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );
            lat = position.latitude;
            lng = position.longitude;
            accuracy = position.accuracy;
          } catch (_) {
            warning = 'GPS signal low. Used estimated coordinates.';
          }
        }
      }

      // 3. Resolve Ward independently from coordinates
      Map<String, dynamic>? resolvedWard;
      try {
        resolvedWard = await ApiService()
            .resolveWardByCoordinates(latitude: lat, longitude: lng);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoBase64 = base64String;
        _photoFilename = filename;
        _latitude = lat;
        _longitude = lng;
        _gpsAccuracy = accuracy;
        _captureTime = DateTime.now();
        _locationWarning = warning;
        if (resolvedWard != null) {
          _resolvedWardNumber = resolvedWard['ward_number'];
          _resolvedWardName = resolvedWard['ward_name'];
          _addressController.text =
              "${_resolvedWardNumber ?? 'Ward'} - ${_resolvedWardName ?? ''}, Chennai (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})";
        }
        _isCapturingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturingLocation = false;
        _locationWarning = 'Could not access camera or GPS: $e';
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
      _photoBase64 = null;
      _photoFilename = null;
      _gpsAccuracy = null;
      _captureTime = null;
      _resolvedWardName = null;
      _resolvedWardNumber = null;
      _locationWarning = null;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _isSubmitting = true);

    final created = await ApiService().createComplaint(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _detectedPriority,
      latitude: _latitude,
      longitude: _longitude,
      gpsAccuracy: _gpsAccuracy,
      address: _addressController.text.trim(),
      wardNumber: _resolvedWardNumber ?? 'Ward 102',
      zone: 'Zone 8 (Anna Nagar)',
      isAnonymous: _isAnonymous,
      photoBase64: _photoBase64,
      photoFilename: _photoFilename,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          title: Text(l10n.tr('complaint_registered_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tr('ticket_number_is')),
              const SizedBox(height: 6),
              Text(
                created.complaintNumber,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(l10n.tr('ticket_assigned_inspection')),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (widget.onSubmitted != null) widget.onSubmitted!();
              },
              child: Text(l10n.tr('done')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('lodge_complaint_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Notice
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.tr('ai_notice'),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title Field
              AppTextField(
                label: l10n.tr('issue_title'),
                hint: l10n.tr('issue_title_hint'),
                controller: _titleController,
                validator: (val) => (val == null || val.isEmpty)
                    ? l10n.tr('validation_required')
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Description Field
              Text(
                l10n.tr('issue_description'),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                onChanged: _triggerAIAnalysis,
                validator: (val) => (val == null || val.length < 5)
                    ? l10n.tr('validation_required')
                    : null,
                decoration: InputDecoration(
                  hintText: l10n.tr('issue_description_hint'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Category Selector
              Text(l10n.tr('category_label'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: [
                  DropdownMenuItem(
                      value: "water_supply",
                      child: Text(l10n.tr('category_water'))),
                  DropdownMenuItem(
                      value: "garbage_collection",
                      child: Text(l10n.tr('category_waste'))),
                  DropdownMenuItem(
                      value: "road_damage",
                      child: Text(l10n.tr('category_roads'))),
                  DropdownMenuItem(
                      value: "streetlights",
                      child: Text(l10n.tr('category_streetlights'))),
                  DropdownMenuItem(
                      value: "drainage",
                      child: Text(l10n.tr('category_drainage'))),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // AI Suggested Priority
              Row(
                children: [
                  Text('${l10n.tr('ai_assessed_priority')}: ',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  PriorityIndicator(priority: _detectedPriority),
                  if (_isAnalyzingAI) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section: GPS-Enabled In-App Camera
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(
                      color: _photoBytes != null
                          ? AppColors.primary
                          : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _photoBytes != null
                              ? Icons.camera_alt
                              : Icons.photo_camera_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.tr('take_photo_camera'),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isTamil
                          ? 'புகைப்படம் எடுக்கும்போது துல்லியமான GPS அட்சரேகை/தீர்க்கரேகை பதிவு செய்யப்படும்.'
                          : 'Capturing photo automatically records verified GPS coordinates and accuracy.',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Photo Action Buttons (if no photo yet)
                    if (_photoBytes == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textInverse,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm),
                              ),
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: Text(
                                l10n.isTamil ? 'கேமரா' : 'Open Camera',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: _isCapturingLocation
                                  ? null
                                  : () =>
                                      _capturePhotoWithGPS(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm),
                              ),
                              icon: const Icon(Icons.photo_library_outlined,
                                  size: 18),
                              label: Text(
                                l10n.tr('choose_gallery'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: _isCapturingLocation
                                  ? null
                                  : () =>
                                      _capturePhotoWithGPS(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      if (_isCapturingLocation) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'Acquiring GPS fix & resolving ward...',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      // Photo Preview Thumbnail
                      ClipRRect(
                        borderRadius: AppSpacing.roundedSm,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.memory(
                              _photoBytes!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                                tooltip: l10n.tr('remove_photo'),
                                onPressed: _removePhoto,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // GPS Metadata Confirmation Box
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gps_fixed,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  l10n.tr('gps_location_captured'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark),
                                ),
                                const Spacer(),
                                _buildAccuracyBadge(l10n),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Lat: ${_latitude.toStringAsFixed(6)}°, Lon: ${_longitude.toStringAsFixed(6)}°',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            if (_resolvedWardNumber != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.tr('ward_label')}: $_resolvedWardNumber (${_resolvedWardName ?? ''})',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                            if (_captureTime != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Time: ${_captureTime!.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Retake button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text(l10n.tr('retake_photo'),
                                  style: const TextStyle(fontSize: 12)),
                              onPressed: () =>
                                  _capturePhotoWithGPS(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              label: Text(l10n.tr('remove_photo'),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.error)),
                              onPressed: _removePhoto,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_locationWarning != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _locationWarning!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Address Field
              AppTextField(
                label: l10n.tr('location_address'),
                controller: _addressController,
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),

              // Anonymous Checkbox
              CheckboxListTile(
                value: _isAnonymous,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tr('submit_anonymous'),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.tr('submit_anonymous_hint'),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                onChanged: (val) => setState(() => _isAnonymous = val ?? false),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              AppButton(
                label: l10n.tr('submit_complaint_button'),
                leadingIcon: Icons.send,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyBadge(AppLocalizations l10n) {
    if (_gpsAccuracy == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: AppSpacing.roundedPill,
        ),
        child: const Text('Estimated',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      );
    }

    final acc = _gpsAccuracy!;
    Color badgeColor = AppColors.success;
    String badgeText = '${acc.toStringAsFixed(1)}m • High';

    if (acc > 30) {
      badgeColor = AppColors.error;
      badgeText = '${acc.toStringAsFixed(0)}m • Poor';
    } else if (acc > 15) {
      badgeColor = AppColors.warning;
      badgeText = '${acc.toStringAsFixed(0)}m • Moderate';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: badgeColor, width: 0.8),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
      ),
    );
  }
}
