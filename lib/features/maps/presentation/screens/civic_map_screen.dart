import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/priority_indicator.dart';

/// Interactive Civic Complaints Map powered by OpenStreetMap & Backend Geospatial Data
class CivicMapScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CivicMapScreen({super.key, this.onBack});

  @override
  State<CivicMapScreen> createState() => _CivicMapScreenState();
}

class _CivicMapScreenState extends State<CivicMapScreen> {
  final MapController _mapController = MapController();

  // Chennai Central Coordinates
  static const LatLng _initialCenter = LatLng(13.0827, 80.2707);

  String _selectedCategory = 'all';
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  LatLng? _userLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    LanguageController().addListener(_onLanguageChanged);
    _fetchMapComplaints();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LanguageController().removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _fetchMapComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService().getMapComplaints(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _complaints = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestAndLocateUser() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location services are disabled on device.')),
        );
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permission permanently denied. Enable in app settings.')),
        );
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _userLocation = userLatLng;
          _isLocating = false;
        });
        _mapController.move(userLatLng, 15.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to obtain GPS location: $e')),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'water_supply':
        return const Color(0xFF0284C7); // Sky blue
      case 'solid_waste':
        return const Color(0xFFD97706); // Amber
      case 'roads_footpaths':
      case 'road_damage':
        return const Color(0xFFDC2626); // Red
      case 'street_lighting':
        return const Color(0xFFCA8A04); // Yellow/Gold
      case 'drainage_sewage':
        return const Color(0xFF7C3AED); // Purple
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water_supply':
        return Icons.water_drop;
      case 'solid_waste':
        return Icons.delete_outline;
      case 'roads_footpaths':
      case 'road_damage':
        return Icons.warning_amber;
      case 'street_lighting':
        return Icons.lightbulb_outline;
      case 'drainage_sewage':
        return Icons.plumbing;
      default:
        return Icons.location_on;
    }
  }

  void _showComplaintDetailsSheet(Map<String, dynamic> c) {
    final l10n = AppLocalizations.of(context);
    final category = c['category']?.toString() ?? 'other';
    final color = _getCategoryColor(category);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: AppSpacing.roundedPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(category),
                            size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          category.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: c['status']?.toString() ?? 'submitted'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                c['complaint_number']?.toString() ?? 'NO-TICKET',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                c['title']?.toString() ?? 'Civic Issue',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              if (c['description'] != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  c['description'].toString(),
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      c['address']?.toString() ?? 'Chennai, Tamil Nadu',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${l10n.tr('priority_critical').substring(0, 3)}: ',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  PriorityIndicator(
                      priority: c['priority']?.toString() ?? 'medium'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.roundedSm),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.tr('close'),
                      style: const TextStyle(color: AppColors.textInverse)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Build Map Markers
    final List<Marker> markers = [];

    // 1. Complaint Markers
    for (final c in _complaints) {
      final lat = (c['latitude'] as num?)?.toDouble();
      final lng = (c['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final category = c['category']?.toString() ?? 'other';
      final color = _getCategoryColor(category);

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _showComplaintDetailsSheet(c),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    // 2. User Location Marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap Layer
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12.5,
              minZoom: 6.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.gov.tn.nammaooru.ai',
                maxZoom: 19,
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Top Header & Category Filter Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Title Bar Container
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedMd,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (widget.onBack != null) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: widget.onBack,
                          ),
                        ] else ...[
                          const Icon(Icons.map, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.tr('map_title'),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${_complaints.length} ${l10n.tr('complaints')} active',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),

                  // Horizontal Category Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        _buildFilterChip(
                            'all', l10n.tr('filter_all'), Icons.layers),
                        _buildFilterChip('water_supply',
                            l10n.tr('filter_water'), Icons.water_drop),
                        _buildFilterChip(
                            'solid_waste',
                            l10n.tr('filter_solid_waste'),
                            Icons.delete_outline),
                        _buildFilterChip('roads_footpaths',
                            l10n.tr('filter_roads'), Icons.warning_amber),
                        _buildFilterChip(
                            'street_lighting',
                            l10n.tr('filter_streetlights'),
                            Icons.lightbulb_outline),
                        _buildFilterChip('drainage_sewage',
                            l10n.tr('filter_drainage'), Icons.plumbing),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedPill,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text(l10n.tr('loading_map'),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

          // Error State Banner
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Card(
                color: AppColors.errorLight,
                shape:
                    RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchMapComplaints,
                        child: Text(l10n.tr('refresh')),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Empty State Banner if no complaints
          if (!_isLoading && _errorMessage == null && _complaints.isEmpty)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape:
                    RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.tr('no_complaints_found'),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Action Buttons (Locate Me & Refresh)
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'refresh_map',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  onPressed: _fetchMapComplaints,
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'locate_user',
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  onPressed: _isLocating ? null : _requestAndLocateUser,
                  child: _isLocating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedCategory == key;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? AppColors.textInverse : AppColors.primary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
        ),
        elevation: 2,
        pressElevation: 4,
        onSelected: (selected) {
          setState(() => _selectedCategory = key);
          _fetchMapComplaints();
        },
      ),
    );
  }
}
