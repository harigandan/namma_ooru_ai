import 'package:flutter/foundation.dart';

/// API endpoint paths matching backend specification
class ApiEndpoints {
  ApiEndpoints._();

  /// Dynamic API Base URL supporting custom domain deployments:
  /// 1. `--dart-define=API_BASE_URL=https://yourdomain.com/api/v1`
  /// 2. In release web mode: `/api/v1` (relative proxy through Nginx)
  /// 3. Development fallback: `http://localhost:8000/api/v1`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb && kReleaseMode) {
      return '/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';

  // User
  static const String userMe = '/users/me';

  // Complaints
  static const String complaints = '/complaints';
  static String complaintDetail(String id) => '/complaints/$id';
  static String complaintHistory(String id) => '/complaints/$id/history';
  static String complaintFeedback(String id) => '/complaints/$id/feedback';

  // Uploads
  static const String uploads = '/uploads';

  // AI Services
  static const String aiClassify = '/ai/classify';
  static const String aiSummarize = '/ai/summarize';
  static const String aiDuplicates = '/ai/duplicates';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminComplaints = '/admin/complaints';
  static String adminAssign(String id) => '/admin/complaints/$id/assign';
  static String adminStatus(String id) => '/admin/complaints/$id/status';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminDepartments = '/admin/departments';
  static const String adminOfficers = '/admin/officers';
  static const String adminUsers = '/admin/users';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminAnnouncements = '/admin/announcements';

  // Officer
  static const String officerAssignments = '/officer/assignments';
  static String officerAssignmentDetail(String id) =>
      '/officer/assignments/$id';
  static String officerUpdates(String id) => '/officer/assignments/$id/updates';
  static String officerComplete(String id) =>
      '/officer/assignments/$id/complete';

  // Maps
  static const String mapComplaints = '/maps/complaints';
  static const String mapHotspots = '/maps/hotspots';

  // Wards & Geography
  static const String municipalities = '/wards/municipalities';
  static const String zones = '/wards/zones';
  static const String wards = '/wards';
  static const String resolveWard = '/wards/resolve';
  static const String updateWard = '/auth/ward';

  // Notifications & Announcements
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String publicAnnouncements = '/announcements';
}
