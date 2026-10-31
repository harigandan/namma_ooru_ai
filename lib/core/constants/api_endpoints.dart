/// API endpoint paths matching backend specification
class ApiEndpoints {
  ApiEndpoints._();

  /// Production API host deployed on Render
  static const String defaultProductionHost = 'https://namma-ooru-ai-2.onrender.com';
  static const String apiVersion = '/api/v1';

  /// Dynamic API Base URL:
  /// 1. `--dart-define=API_BASE_URL=https://...` (override if custom domain or local staging)
  /// 2. If kIsWeb and hosted together with Nginx: relative `/api/v1`
  /// 3. Default: `https://namma-ooru-ai-2.onrender.com/api/v1`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      final sanitized = fromEnv.endsWith('/')
          ? fromEnv.substring(0, fromEnv.length - 1)
          : fromEnv;
      return sanitized.endsWith(apiVersion)
          ? sanitized
          : '$sanitized$apiVersion';
    }
    return '$defaultProductionHost$apiVersion';
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
