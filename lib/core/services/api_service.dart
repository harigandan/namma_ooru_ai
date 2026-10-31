import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';
import '../../features/complaints/domain/models/complaint_model.dart';
import '../../features/complaints/data/sample_complaints_data.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = DioClient().dio;
  bool _isBackendConnected = false;
  String? _currentUserRole;
  Map<String, dynamic>? _currentUserProfile;

  ApiService._internal();

  bool get isBackendConnected => _isBackendConnected;
  String? get currentUserRole => _currentUserRole;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;

  /// Check backend connectivity
  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get('/');
      _isBackendConnected = (res.statusCode == 200);
      return _isBackendConnected;
    } catch (_) {
      _isBackendConnected = false;
      return false;
    }
  }

  /// Authentication Login - Real Backend Authentication
  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email_or_phone': emailOrPhone.trim(),
          'password': password,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final role = data['role'] as String;

        // Set token in Dio headers
        DioClient().setAuthToken(accessToken);
        _currentUserRole = role;
        _currentUserProfile = data;
        _isBackendConnected = true;

        // Fetch complete profile from /users/me so email, phone, ward details are immediately populated
        try {
          final profileRes = await _dio.get(ApiEndpoints.userMe);
          if (profileRes.statusCode == 200 && profileRes.data is Map<String, dynamic>) {
            _currentUserProfile = {
              ...data,
              ...(profileRes.data as Map<String, dynamic>),
            };
          }
        } catch (_) {}

        // Persist session to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_access_token', accessToken);
        await prefs.setString('auth_refresh_token', refreshToken);
        await prefs.setString('user_role', role);
        await prefs.setString('user_full_name', data['full_name'] ?? '');
        await prefs.setString('user_email', emailOrPhone.trim());

        return data;
      } else {
        throw Exception('Login failed: Unexpected server response');
      }
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      String errorMsg = 'Authentication failed. Please verify credentials.';
      if (dioError.response?.data != null &&
          dioError.response?.data is Map &&
          dioError.response?.data['detail'] != null) {
        errorMsg = dioError.response?.data['detail'].toString() ?? errorMsg;
      } else if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout) {
        errorMsg =
            'Cannot reach backend server. Please verify backend is running on port 8000.';
      }
      throw Exception(errorMsg);
    } catch (e) {
      _isBackendConnected = false;
      rethrow;
    }
  }

  /// Citizen / User Registration - Real Backend Registration
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String? city,
    String? municipality,
    String? zone,
    String? wardId,
    String? wardNumber,
    String role = 'citizen',
    String? authorizationCode,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.register,
        data: {
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'city': city?.trim() ?? 'Chennai',
          'municipality': municipality?.trim() ?? 'Greater Chennai Corporation',
          if (zone != null) 'zone': zone.trim(),
          if (wardId != null) 'ward_id': wardId.trim(),
          if (wardNumber != null) 'ward_number': wardNumber.trim(),
          'preferred_language': 'ta',
          'role': role,
          if (authorizationCode != null && authorizationCode.isNotEmpty)
            'authorization_code': authorizationCode.trim(),
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final actualRole = data['role'] as String;

        DioClient().setAuthToken(accessToken);
        _currentUserRole = actualRole;
        _currentUserProfile = data;
        _isBackendConnected = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_access_token', accessToken);
        await prefs.setString('auth_refresh_token', refreshToken);
        await prefs.setString('user_role', actualRole);
        await prefs.setString('user_full_name', fullName);
        await prefs.setString('user_email', email.trim());

        return data;
      } else {
        throw Exception('Registration failed: Unexpected response');
      }
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      String errorMsg = 'Registration failed';
      if (dioError.response?.data != null &&
          dioError.response?.data is Map &&
          dioError.response?.data['detail'] != null) {
        errorMsg = dioError.response?.data['detail'].toString() ?? errorMsg;
      }
      throw Exception(errorMsg);
    }
  }

  /// Restore Persisted Authenticated Session
  Future<Map<String, dynamic>?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('auth_access_token');
      final refreshToken = prefs.getString('auth_refresh_token');

      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }

      DioClient().setAuthToken(accessToken);

      // Verify token with backend /users/me
      try {
        final res = await _dio.get(ApiEndpoints.userMe);
        if (res.statusCode == 200 && res.data != null) {
          final profile = res.data as Map<String, dynamic>;
          _currentUserRole = profile['role'];
          _currentUserProfile = profile;
          _isBackendConnected = true;
          return profile;
        }
      } catch (e) {
        // Access token might be expired, attempt refresh
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshRes = await _dio.post(
            ApiEndpoints.refresh,
            data: {'refresh_token': refreshToken},
          );
          if (refreshRes.statusCode == 200 && refreshRes.data != null) {
            final newAccessToken = refreshRes.data['access_token'] as String;
            DioClient().setAuthToken(newAccessToken);
            await prefs.setString('auth_access_token', newAccessToken);

            final profileRes = await _dio.get(ApiEndpoints.userMe);
            if (profileRes.statusCode == 200) {
              final profile = profileRes.data as Map<String, dynamic>;
              _currentUserRole = profile['role'];
              _currentUserProfile = profile;
              _isBackendConnected = true;
              return profile;
            }
          }
        }
      }

      // If token verification and refresh both failed, clear session
      await logout();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout and clear all persisted credentials
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_access_token');
      await prefs.remove('auth_refresh_token');
      await prefs.remove('user_role');
      await prefs.remove('user_full_name');
      await prefs.remove('user_email');
    } catch (_) {}
    DioClient().clearAuthToken();
    _currentUserRole = null;
    _currentUserProfile = null;
  }

  /// Fetch Map Complaints from backend
  Future<List<Map<String, dynamic>>> getMapComplaints({
    String? category,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category != 'all') {
        queryParams['category'] = category;
      }
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final res = await _dio.get(
        ApiEndpoints.mapComplaints,
        queryParameters: queryParams,
      );

      if (res.statusCode == 200 && res.data is List) {
        _isBackendConnected = true;
        return List<Map<String, dynamic>>.from(res.data as List);
      }
    } catch (e) {
      _isBackendConnected = false;
    }

    // Default seeded fallback map points
    return [
      {
        'id': 'c-map-1',
        'complaint_number': 'NO-2026-MAP001',
        'title': 'Major Drinking Water Pipeline Burst',
        'category': 'water_supply',
        'priority': 'critical',
        'status': 'in_progress',
        'latitude': 13.0850,
        'longitude': 80.2101,
        'address': '2nd Avenue, Anna Nagar, Chennai',
      },
      {
        'id': 'c-map-2',
        'complaint_number': 'NO-2026-MAP002',
        'title': 'Overflowing Public Garbage Dump',
        'category': 'solid_waste',
        'priority': 'high',
        'status': 'submitted',
        'latitude': 13.0400,
        'longitude': 80.2300,
        'address': 'Usman Road Market, T. Nagar, Chennai',
      },
      {
        'id': 'c-map-3',
        'complaint_number': 'NO-2026-MAP003',
        'title': 'Severe Deep Road Cave-in & Pothole',
        'category': 'roads_footpaths',
        'priority': 'critical',
        'status': 'assigned',
        'latitude': 13.0300,
        'longitude': 80.2150,
        'address': '100 Feet Road, Vadapalani, Chennai',
      },
      {
        'id': 'c-map-4',
        'complaint_number': 'NO-2026-MAP004',
        'title': 'Multiple Streetlights Non-Functional',
        'category': 'street_lighting',
        'priority': 'medium',
        'status': 'resolved',
        'latitude': 13.0200,
        'longitude': 80.2200,
        'address': 'Gandhi Road, Velachery, Chennai',
      },
    ];
  }

  /// Fetch Complaints list from backend
  Future<List<ComplaintModel>> getComplaints({
    String? status,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (category != null && category != 'all') {
        queryParams['category'] = category;
      }

      final res = await _dio.get(
        ApiEndpoints.complaints,
        queryParameters: queryParams,
      );

      if (res.statusCode == 200 && res.data is List) {
        _isBackendConnected = true;
        final list = res.data as List;
        return list
            .map(
                (item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _isBackendConnected = false;
    }

    return mockComplaints.where((c) {
      if (status != null && status != 'all' && c.statusString != status) {
        return false;
      }
      if (category != null && category != 'all' && c.category != category) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Create a new complaint via API
  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    String? descriptionTa,
    String? category,
    String? priority,
    required double latitude,
    required double longitude,
    double? gpsAccuracy,
    required String address,
    String? wardNumber,
    String? zone,
    bool isAnonymous = false,
    String? photoBase64,
    String? photoFilename,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.complaints,
        data: {
          'title': title,
          'description': description,
          'description_ta': descriptionTa,
          'category': category,
          'priority': priority,
          'latitude': latitude,
          'longitude': longitude,
          if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
          'address': address,
          'ward_number': wardNumber,
          'zone': zone,
          'is_anonymous': isAnonymous,
          if (photoBase64 != null) 'photo_base64': photoBase64,
          if (photoFilename != null) 'photo_filename': photoFilename,
        },
      );

      if (res.statusCode == 201 && res.data != null) {
        _isBackendConnected = true;
        return ComplaintModel.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      _isBackendConnected = false;
    }

    final newComp = ComplaintModel(
      id: 'comp-${DateTime.now().millisecondsSinceEpoch}',
      complaintNumber:
          'NOA-2026-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}',
      title: title,
      description: description,
      descriptionTa: descriptionTa,
      category: category ?? 'other',
      categoryLabel: (category ?? 'Other').replaceAll('_', ' ').toUpperCase(),
      categoryLabelTa: category ?? 'இதர புகார்',
      priority: ComplaintPriority.high,
      status: ComplaintStatus.submitted,
      departmentId: 'dept-auto',
      departmentName: 'Municipal Department',
      departmentNameTa: 'நகராட்சித் துறை',
      citizenName: isAnonymous ? 'Anonymous Citizen' : 'Namma Ooru Citizen',
      citizenPhone: '+91 98400 00002',
      address: address,
      wardNumber: wardNumber ?? 'Ward 102',
      zone: zone ?? 'Zone 5',
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      aiConfidence: 0.95,
      aiSummary: 'Classified by Namma Ooru AI.',
    );
    mockComplaints.insert(0, newComp);
    return newComp;
  }

  /// AI NLP Classification API
  Future<Map<String, dynamic>> classifyAI(String text) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.aiClassify,
        data: {'text': text},
      );
      if (res.statusCode == 200 && res.data != null) {
        _isBackendConnected = true;
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      _isBackendConnected = false;
    }

    return {
      'detected_language':
          text.contains(RegExp(r'[\u0B80-\u0BFF]')) ? 'ta' : 'en',
      'predicted_category':
          text.contains('குப்பை') ? 'garbage_collection' : 'water_supply',
      'category_confidence': 0.94,
      'predicted_priority': 'high',
      'priority_confidence': 0.88,
      'recommended_department_name': 'Municipal Administration',
      'summary': 'Classified civic issue.',
    };
  }

  /// Update complaint status / resolution notes
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    String? resolutionNotes,
  }) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.complaintDetail(complaintId),
        data: {
          'status': newStatus,
          'resolution_notes': resolutionNotes,
        },
      );
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      _isBackendConnected = false;
    }
    return true;
  }

  /// Admin assign complaint
  Future<bool> assignComplaint({
    required String complaintId,
    required String departmentId,
    String? officerId,
  }) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.adminAssign(complaintId),
        queryParameters: {
          'department_id': departmentId,
          if (officerId != null) 'officer_id': officerId,
        },
      );
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      _isBackendConnected = false;
    }
    return true;
  }

  /// Admin Dashboard Metrics
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      final res = await _dio.get(ApiEndpoints.adminDashboard);
      if (res.statusCode == 200 && res.data != null) {
        _isBackendConnected = true;
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      _isBackendConnected = false;
    }
    return {
      'total_complaints': mockComplaints.length,
      'pending_complaints': mockComplaints
          .where((c) => c.status != ComplaintStatus.resolved)
          .length,
      'resolved_complaints': mockComplaints
          .where((c) => c.status == ComplaintStatus.resolved)
          .length,
      'high_priority_complaints': mockComplaints
          .where((c) => c.priority == ComplaintPriority.critical)
          .length,
      'average_resolution_hours': 18.4,
    };
  }

  /// Get Municipalities
  Future<List<Map<String, dynamic>>> getMunicipalities() async {
    try {
      final res = await _dio.get(ApiEndpoints.municipalities);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
    } catch (_) {}
    return [
      {
        'id': 'muni-gcc',
        'name': 'Greater Chennai Corporation (GCC)',
        'name_ta': 'பெருநகர சென்னை மாநகராட்சி',
        'code': 'GCC',
        'district': 'Chennai',
      }
    ];
  }

  /// Get Zones for a Municipality
  Future<List<Map<String, dynamic>>> getZones({String? municipalityId}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.zones,
        queryParameters: {
          if (municipalityId != null) 'municipality_id': municipalityId,
        },
      );
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
    } catch (_) {}
    return [
      {'id': 'z-05', 'name': 'Zone 5 (Royapuram)', 'name_ta': 'மண்டலம் 5 (ராயபுரம்)', 'zone_number': 5, 'code': 'Z05'},
      {'id': 'z-08', 'name': 'Zone 8 (Anna Nagar)', 'name_ta': 'மண்டலம் 8 (அண்ணா நகர்)', 'zone_number': 8, 'code': 'Z08'},
      {'id': 'z-10', 'name': 'Zone 10 (Kodambakkam / T. Nagar)', 'name_ta': 'மண்டலம் 10 (கோடம்பாக்கம் / தி. நகர்)', 'zone_number': 10, 'code': 'Z10'},
      {'id': 'z-13', 'name': 'Zone 13 (Adyar / Velachery)', 'name_ta': 'மண்டலம் 13 (அடையாறு / வேளச்சேரி)', 'zone_number': 13, 'code': 'Z13'},
    ];
  }

  /// Get Wards for a Zone with optional search
  Future<List<Map<String, dynamic>>> getWards({String? zoneId, String? search}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.wards,
        queryParameters: {
          if (zoneId != null) 'zone_id': zoneId,
          if (search != null && search.isNotEmpty) 'q': search,
        },
      );
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
    } catch (_) {}
    return [
      {'id': 'w-101', 'ward_number': 'Ward 101', 'ward_name': 'Anna Nagar East', 'ward_name_ta': 'அண்ணா நகர் கிழக்கு'},
      {'id': 'w-102', 'ward_number': 'Ward 102', 'ward_name': 'Anna Nagar West', 'ward_name_ta': 'அண்ணா நகர் மேற்கு'},
      {'id': 'w-103', 'ward_number': 'Ward 103', 'ward_name': 'Shenoy Nagar', 'ward_name_ta': 'செனாய் நகர்'},
      {'id': 'w-104', 'ward_number': 'Ward 104', 'ward_name': 'Aminjikarai', 'ward_name_ta': 'அமைந்தகரை'},
      {'id': 'w-105', 'ward_number': 'Ward 105', 'ward_name': 'Arumbakkam', 'ward_name_ta': 'அரும்பாக்கம்'},
      {'id': 'w-114', 'ward_number': 'Ward 114', 'ward_name': 'T. Nagar North', 'ward_name_ta': 'தி. நகர் வடக்கு'},
      {'id': 'w-128', 'ward_number': 'Ward 128', 'ward_name': 'Vadapalani', 'ward_name_ta': 'வடபழனி'},
      {'id': 'w-177', 'ward_number': 'Ward 177', 'ward_name': 'Velachery', 'ward_name_ta': 'வேளச்சேரி'},
    ];
  }

  /// Resolve nearest ward by GPS coordinates
  Future<Map<String, dynamic>?> resolveWardByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.resolveWard,
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );
      if (res.statusCode == 200 && res.data != null) {
        return res.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Update citizen registered ward
  Future<Map<String, dynamic>> updateCitizenWard({
    required String wardId,
    String? reason,
  }) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.updateWard,
        data: {'ward_id': wardId, if (reason != null) 'reason': reason},
      );
      if (res.statusCode == 200 && res.data != null) {
        _currentUserProfile = res.data as Map<String, dynamic>;
        return _currentUserProfile!;
      }
    } catch (_) {}
    return _currentUserProfile ?? {};
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.userMe);
      if (res.statusCode == 200 && res.data != null) {
        _currentUserProfile = res.data as Map<String, dynamic>;
        return _currentUserProfile!;
      }
    } catch (_) {}
    return _currentUserProfile ?? {};
  }
}
