import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';
import '../../features/complaints/domain/models/complaint_model.dart';

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

  /// Centralized error message extractor for consistent user notifications
  String _parseDioError(DioException dioError, {String fallback = 'Operation failed'}) {
    if (dioError.response != null) {
      final statusCode = dioError.response?.statusCode;
      final data = dioError.response?.data;

      if (data is Map && data['detail'] != null) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return '${first['loc']?.last ?? ''}: ${first['msg']}';
          }
          return detail.toString();
        }
      }

      switch (statusCode) {
        case 401:
          return 'Authentication failed or session expired (401).';
        case 403:
          return 'Access forbidden. You do not have permissions for this action (403).';
        case 404:
          return 'The requested record or resource was not found (404).';
        case 422:
          return 'Validation error. Please verify input fields (422).';
        case 500:
          return 'Internal server error (500). Please try again shortly.';
        case 502:
        case 503:
          return 'Render backend is starting up. Please wait a moment and retry.';
        default:
          return '$fallback (Status $statusCode)';
      }
    }

    if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.receiveTimeout ||
        dioError.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Render backend may be waking up from sleep. Retrying...';
    }

    if (dioError.type == DioExceptionType.connectionError) {
      return 'Cannot reach backend at ${ApiEndpoints.baseUrl}. Please check internet connection.';
    }

    return dioError.message ?? fallback;
  }

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
        await prefs.setString('user_full_name', _currentUserProfile?['full_name'] ?? data['full_name'] ?? '');
        await prefs.setString('user_email', emailOrPhone.trim());

        return _currentUserProfile ?? data;
      } else {
        throw Exception('Login failed: Unexpected server response');
      }
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Authentication failed. Please verify credentials.'));
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
      throw Exception(_parseDioError(dioError, fallback: 'Registration failed. Please verify inputs.'));
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

  /// Explicit Token Refresh
  Future<String?> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('auth_refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final res = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      if (res.statusCode == 200 && res.data != null) {
        final newAccessToken = res.data['access_token'] as String;
        DioClient().setAuthToken(newAccessToken);
        await prefs.setString('auth_access_token', newAccessToken);
        return newAccessToken;
      }
    } catch (_) {}
    return null;
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

  /// Fetch Map Complaints from live backend
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
      throw Exception('Failed to load map data: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Could not load civic map issues'));
    }
  }

  /// Fetch Complaints list from live backend (Zero mock fallback)
  Future<List<ComplaintModel>> getComplaints({
    String? status,
    String? category,
    String? ward,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (category != null && category != 'all') {
        queryParams['category'] = category;
      }
      if (ward != null && ward != 'all') {
        queryParams['ward'] = ward;
      }

      final res = await _dio.get(
        ApiEndpoints.complaints,
        queryParameters: queryParams,
      );

      if (res.statusCode == 200 && res.data is List) {
        _isBackendConnected = true;
        final list = res.data as List;
        return list
            .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load complaints from backend: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Could not retrieve complaints list'));
    } catch (e) {
      _isBackendConnected = false;
      rethrow;
    }
  }

  /// Create a new complaint via live API
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
      throw Exception('Failed to lodge complaint: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Complaint submission failed'));
    }
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
      throw Exception('AI classification failed: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'AI analysis service temporarily unavailable'));
    }
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
      throw Exception('Failed to update complaint status: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Could not update status'));
    }
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
          if (officerId != null && officerId.isNotEmpty) 'officer_id': officerId,
        },
      );
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
      throw Exception('Failed to assign complaint: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Failed to assign complaint'));
    }
  }

  /// Admin Dashboard Metrics from Live Backend
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      final res = await _dio.get(ApiEndpoints.adminDashboard);
      if (res.statusCode == 200 && res.data != null) {
        _isBackendConnected = true;
        return res.data as Map<String, dynamic>;
      }
      throw Exception('Failed to retrieve dashboard metrics: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Could not load administrative metrics'));
    }
  }

  /// Admin Departments
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final res = await _dio.get(ApiEndpoints.adminDepartments);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
      throw Exception('Failed to load departments');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not load departments'));
    }
  }

  /// Field Officer Assignments
  Future<List<ComplaintModel>> getOfficerAssignments() async {
    try {
      final res = await _dio.get(ApiEndpoints.officerAssignments);
      if (res.statusCode == 200 && res.data is List) {
        _isBackendConnected = true;
        final list = res.data as List;
        return list
            .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load officer tasks: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      _isBackendConnected = false;
      throw Exception(_parseDioError(dioError, fallback: 'Could not retrieve assigned work'));
    }
  }

  /// Field Officer Work Update Progress
  Future<bool> updateOfficerProgress({
    required String complaintId,
    required String status,
    String? resolutionNotes,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.officerUpdates(complaintId),
        data: {
          'status': status,
          'resolution_notes': resolutionNotes,
        },
      );
      if (res.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to update task progress: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Failed to update work progress'));
    }
  }

  /// Field Officer Complete Assignment
  Future<bool> completeOfficerAssignment({
    required String complaintId,
    String? resolutionNotes,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.officerComplete(complaintId),
        data: {
          'status': 'resolved',
          'resolution_notes': resolutionNotes ?? 'Completed by field officer.',
        },
      );
      if (res.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to complete assignment: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Failed to mark task resolved'));
    }
  }

  /// Upload Complaint Photo Attachment (Before/After Evidence)
  Future<Map<String, dynamic>> uploadComplaintAttachment({
    required String complaintId,
    required List<int> fileBytes,
    required String filename,
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
    String uploadPhase = 'resolution',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: filename),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
        'upload_phase': uploadPhase,
      });

      final res = await _dio.post(
        '${ApiEndpoints.complaints}/$complaintId/attachments',
        data: formData,
      );

      if (res.statusCode == 200 && res.data != null) {
        return res.data as Map<String, dynamic>;
      }
      throw Exception('Failed to upload photo: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not upload photo evidence'));
    }
  }

  /// Complaint Activity History
  Future<List<Map<String, dynamic>>> getComplaintHistory(String complaintId) async {
    try {
      final res = await _dio.get(ApiEndpoints.complaintHistory(complaintId));
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
    } catch (_) {}
    return [];
  }

  /// Get Municipalities
  Future<List<Map<String, dynamic>>> getMunicipalities() async {
    try {
      final res = await _dio.get(ApiEndpoints.municipalities);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
      throw Exception('Failed to load municipalities: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not load municipal data'));
    }
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
      throw Exception('Failed to load zones: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not load zones'));
    }
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
      throw Exception('Failed to load wards: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not load wards'));
    }
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
      throw Exception('Failed to update ward: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Ward update request failed'));
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await _dio.get(ApiEndpoints.userMe);
      if (res.statusCode == 200 && res.data != null) {
        _currentUserProfile = res.data as Map<String, dynamic>;
        return _currentUserProfile!;
      }
      throw Exception('Failed to get user profile: Status ${res.statusCode}');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Could not fetch user profile'));
    }
  }

  /// Submit citizen resolution feedback
  Future<bool> submitFeedback({
    required String complaintId,
    required int rating,
    String? feedbackText,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiEndpoints.complaints}/$complaintId/feedback',
        queryParameters: {
          'rating': rating,
          if (feedbackText != null && feedbackText.isNotEmpty) 'feedback_text': feedbackText,
        },
      );
      if (res.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to submit feedback');
    } on DioException catch (dioError) {
      throw Exception(_parseDioError(dioError, fallback: 'Failed to submit feedback'));
    }
  }
}
