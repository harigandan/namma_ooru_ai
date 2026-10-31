/// App-wide constants for Namma Ooru AI
class AppConstants {
  AppConstants._();

  static const String appName = 'Namma Ooru AI';
  static const String appTagline = 'Smart Civic Governance for Tamil Nadu';
  static const String appVersion = '1.0.0';

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeTa = 'ta';

  // Complaint Categories
  static const List<String> categories = [
    'garbage_collection',
    'road_damage',
    'water_supply',
    'drainage',
    'streetlights',
    'electricity',
    'public_sanitation',
    'public_infrastructure',
    'illegal_dumping',
    'public_safety',
    'other',
  ];

  // Complaint Priorities
  static const List<String> priorities = [
    'low',
    'medium',
    'high',
    'critical',
  ];

  // Complaint Statuses
  static const List<String> statuses = [
    'submitted',
    'under_review',
    'assigned',
    'in_progress',
    'resolved',
    'closed',
    'reopened',
  ];

  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleAdmin = 'admin';
  static const String roleOfficer = 'field_officer';
}
