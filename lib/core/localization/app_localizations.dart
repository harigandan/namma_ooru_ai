import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full Tamil and English Localization Engine for Namma Ooru AI
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(LanguageController().currentLocale);
  }

  static const List<Locale> supportedLocales = [
    Locale('ta', 'IN'),
    Locale('en', 'US'),
    Locale('ta'),
    Locale('en'),
  ];

  bool get isTamil => locale.languageCode == 'ta';

  static final Map<String, Map<String, String>> _localizedValues = {
    'ta': {
      'app_name': 'நம்ம ஊர் AI',
      'app_subtitle': 'தமிழ்நாடு நகராட்சி நிர்வாகம் (GCC)',
      'tagline': 'அறிவார்ந்த நகராட்சி புகார் தீர்வு மற்றும் நிர்வாக தளம்',
      'tamil_nadu_administration': 'தமிழ்நாடு நகராட்சி நிர்வாகம்',

      'login_title': 'உள்நுழைக',
      'login_subtitle': 'உங்கள் நகராட்சி சேவைகளை அணுக உள்நுழையவும்',
      'register_title': 'குடிமக்கள் பதிவு',
      'register_subtitle': 'உங்கள் வார்டில் உள்ள குறைகளை பதிவு செய்ய புதிய கணக்கை தொடங்கவும்',

      'email_or_phone': 'மின்னஞ்சல் அல்லது அலைபேசி எண்',
      'email_or_phone_hint': 'citizen@nammaooru.ai / 9840000002',
      'password': 'கடவுச்சொல்',
      'password_hint': 'குறைந்தது 6 எழுத்துக்கள்',
      'confirm_password': 'கடவுச்சொல்லை உறுதிப்படுத்துக',
      'confirm_password_hint': 'கடவுச்சொல்லை மீண்டும் உள்ளிடவும்',
      'show_password': 'காட்டு',
      'hide_password': 'மறை',
      'remember_session': 'அமர்வை நினைவில் வைக்கவும்',
      'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'forgot_password_dialog_title': 'கடவுச்சொல் உதவி',
      'forgot_password_dialog_msg':
          'உங்கள் கடவுச்சொல்லை மீட்டமைக்க, நகராட்சி கட்டுப்பாட்டு அறையை (ஹெல்ப்லைன் 1913) தொடர்பு கொள்ளவும் அல்லது உங்கள் வார்டு நிர்வாகத்தை அணுகவும்.',
      'close': 'மூடு',
      'sign_in': 'உள்நுழைக',
      'sign_up': 'பதிவு செய்க',
      'full_name': 'முழு பெயர்',
      'phone_number': 'அலைபேசி எண்',
      'city': 'மாவட்டம் / நகரம்',
      'municipality_label': 'மாநகராட்சி / நகராட்சி',
      'zone_label': 'மண்டலம்',
      'ward_label': 'வார்டு எண்',
      'select_municipality': 'மாநகராட்சி / நகராட்சியைத் தேர்ந்தெடுக்கவும்',
      'select_zone': 'மண்டலத்தைத் தேர்ந்தெடுக்கவும்',
      'select_ward': 'வார்டைத் தேர்ந்தெடுக்கவும்',
      'search_ward_hint': 'வார்டு பெயர் அல்லது எண் கொண்டு தேடுக...',
      'preferred_language_label': 'விருப்ப மொழி',
      'auth_code_optional': 'அரசு அனுமதி குறியீடு',
      'auth_code_hint': 'நிர்வாகம் / கள அதிகாரி பதிவுக்கு கட்டாயம்',
      'dont_have_account': 'புதிய பயனரா? இங்கு பதிவு செய்க',
      'already_have_account': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக',
      'quick_dev_accounts': 'டெவலப்பர் விரைவு உள்நுழைவு',
      'citizen': 'குடிமக்கள்',
      'admin': 'நகராட்சி நிர்வாகம்',
      'field_officer': 'கள அதிகாரி',
      'account_role': 'கணக்கு வகை',

      'validation_required': 'இப்புலம் கட்டாயமானது',
      'validation_password_len': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்',
      'validation_password_match': 'கடவுச்சொற்கள் பொருந்தவில்லை',
      'validation_phone': 'சரியான 10 இலக்க அலைபேசி எண்ணை உள்ளிடவும்',
      'validation_email': 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்',
      'validation_ward_required': 'தயவுசெய்து உங்கள் வசிப்பிட வார்டைத் தேர்ந்தெடுக்கவும்',

      'home': 'முகப்பு',
      'complaints': 'புகார்கள்',
      'ai_assistant': 'AI உதவியாளர்',
      'civic_map': 'நேரடி வரைபடம்',
      'profile': 'சுயவிவரம்',
      'logout': 'வெளியேறு',
      'logout_confirm': 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
      'cancel': 'ரத்து',
      'done': 'முடிந்தது',
      'retry': 'மீண்டும் முயற்சி',
      'connection_error': 'இணைப்பு பிழை',

      'welcome': 'வணக்கம்',
      'lodge_complaint': 'புதிய புகார் பதிவு',
      'my_complaints': 'எனது புகார்கள்',
      'recent_issues': 'சமீபத்திய பிரச்சினைகள்',
      'total_lodged': 'மொத்த புகார்கள்',
      'active_action': 'நடவடிக்கையில்',
      'solved': 'தீர்க்கப்பட்டது',
      'filter_all': 'அனைத்தும்',

      'lodge_complaint_title': 'புதிய நகராட்சி புகார் பதிவு',
      'ai_notice':
          'தமிழ் மற்றும் ஆங்கிலம் ஆதரிக்கப்படுகிறது. நீங்கள் தட்டச்சு செய்யும்போது, AI தானாகவே வகையையும் அவசரத்தையும் வகைப்படுத்துகிறது.',
      'issue_title': 'தலைப்பு',
      'issue_title_hint': 'எ.கா., 2வது அவென்யூவில் குடிநீர் குழாய் உடைந்துள்ளது',
      'issue_description': 'புகார் விளக்கம்',
      'issue_description_hint':
          'பிரச்சினையை தமிழில் அல்லது ஆங்கிலத்தில் விவரிக்கவும் (எ.கா., குடிநீர் விநியோகம் தடைபட்டுள்ளது...)',
      'category_label': 'துறை வகை',
      'category_water': 'குடிநீர் வழங்கல்',
      'category_waste': 'திடக்கழிவு மற்றும் குப்பை',
      'category_roads': 'சாலை சேதம் மற்றும் பள்ளங்கள்',
      'category_streetlights': 'தெருவிளக்குகள்',
      'category_drainage': 'வடிகால் மற்றும் பாதாள சாக்கடை',
      'ai_assessed_priority': 'AI நிர்ணயித்த முன்னுரிமை',
      'location_address': 'இருப்பிட முகவரி',

      'take_photo_camera': 'GPS கேமரா மூலம் படம் எடுக்கவும்',
      'choose_gallery': 'கேலரியில் இருந்து தேர்வு செய்க',
      'photo_attached': 'GPS தகவலுடன் புகைப்படம் இணைக்கப்பட்டது',
      'retake_photo': 'மீண்டும் எடுக்கவும்',
      'remove_photo': 'நீக்குக',
      'gps_location_captured': 'GPS இருப்பிடம் பெறப்பட்டது',
      'gps_accuracy': 'துல்லியம்',
      'accuracy_meters': 'மீ',
      'accuracy_high': 'உயர் துல்லியம்',
      'accuracy_medium': 'நடுத்தர துல்லியம்',
      'accuracy_low': 'குறைந்த துல்லியம் - முகவரியை சரிபார்க்கவும்',
      'gps_disabled_warning':
          'GPS முடக்கப்பட்டுள்ளது அல்லது அனுமதி மறுக்கப்பட்டது. தயவுசெய்து இருப்பிட அனுமதியை வழங்கவும் அல்லது முகவரியை கைமுறையாக உள்ளிடவும்.',
      'manual_location_entry': 'கைமுறை இருப்பிட பதிவு',
      'submit_anonymous': 'பெயர் வெளியிடாமல் பதிவு செய்',
      'submit_anonymous_hint': 'பொது புகார் பட்டியலில் இருந்து என் பெயரை மறை',
      'submit_complaint_button': 'புகாரை பதிவு செய்',
      'complaint_registered_title': 'புகார் வெற்றிகரமாக பதிவானது!',
      'ticket_number_is': 'உங்கள் புகார் எண்:',
      'ticket_assigned_inspection':
          '24 மணி நேரத்திற்குள் கள ஆய்விற்காக நகராட்சி துறைக்கு ஒதுக்கப்பட்டுள்ளது.',

      'map_title': 'நேரடி புகார்கள் வரைபடம் (OpenStreetMap)',
      'map_subtitle': 'தமிழ்நாட்டின் நேரடி புவிசார் நகராட்சி பிரச்சினைகள்',
      'filter_water': 'குடிநீர்',
      'filter_solid_waste': 'திடக்கழிவு',
      'filter_roads': 'சாலைகள்',
      'filter_streetlights': 'தெருவிளக்கு',
      'filter_drainage': 'வடிகால்',
      'view_details': 'விவரங்களை காண்க',
      'refresh': 'புதுப்பி',
      'my_location': 'என் இருப்பிடம்',
      'loading_map': 'வரைபடம் ஏற்றப்படுகிறது...',
      'no_complaints_found': 'இந்த பிரிவில் புகார்கள் இல்லை',

      'status_submitted': 'பதிவானது',
      'status_under_review': 'ஆய்வில்',
      'status_assigned': 'ஒதுக்கப்பட்டது',
      'status_in_progress': 'நடவடிக்கையில்',
      'status_resolved': 'தீர்க்கப்பட்டது',
      'status_closed': 'நிறைவுற்றது',
      'status_reopened': 'மீண்டும் திறக்கப்பட்டது',
      'status_rejected': 'நிராகரிக்கப்பட்டது',

      'priority_critical': 'அவசரம்',
      'priority_high': 'உயர்',
      'priority_medium': 'நடுத்தரம்',
      'priority_low': 'குறைவு',

      'profile_title': 'குடிமக்கள் சுயவிவரம்',
      'account_details': 'கணக்கு விவரங்கள்',
      'registered_ward': 'பதிவு செய்யப்பட்ட வார்டு',
      'registered_zone': 'பதிவு செய்யப்பட்ட மண்டலம்',
      'registered_municipality': 'மாநகராட்சி / நகராட்சி',
      'change_ward_request': 'வார்டு திருத்தம் கோருக',
      'select_new_ward': 'புதிய வார்டைத் தேர்ந்தெடுக்கவும்',
      'ward_update_success': 'வார்டு வெற்றிகரமாக மாற்றப்பட்டது!',
      'language_preference': 'மொழி விருப்பம்',
      'select_language_dialog': 'விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
      'save_changes': 'சேமிக்க',

      'admin_dashboard_title': 'நகராட்சி கட்டுப்பாட்டு மையம்',
      'officer_dashboard_title': 'களப்பணி பணிநிலையம்',
      'assign_complaint': 'புகாரை ஒதுக்கு',
      'confirm_assignment': 'ஒதுக்கீட்டை உறுதிப்படுத்து',
      'update_status': 'நிலையை மாற்று',
      'before_photo': 'முந்தைய புகைப்படம்',
      'after_photo': 'பணி முடிந்த புகைப்படம்',
      'resolution_notes': 'தீர்வு குறிப்புகள்',
      'mark_resolved': 'தீர்க்கப்பட்டதாக குறிக்கவும்',
    },
    'en': {
      'app_name': 'Namma Ooru AI',
      'app_subtitle': 'Tamil Nadu Municipal Administration (GCC)',
      'tagline': 'Smart Civic Issue Resolution & Governance Platform',
      'tamil_nadu_administration': 'Tamil Nadu Municipal Administration',

      'login_title': 'Sign In',
      'login_subtitle': 'Access your civic dashboard and track services',
      'register_title': 'Citizen Registration',
      'register_subtitle':
          'Create an account to lodge civic issues and track resolution in your ward',

      'email_or_phone': 'Email or Phone Number',
      'email_or_phone_hint': 'citizen@nammaooru.ai / 9840000002',
      'password': 'Password',
      'password_hint': 'Minimum 6 characters',
      'confirm_password': 'Confirm Password',
      'confirm_password_hint': 'Re-enter your password',
      'show_password': 'Show',
      'hide_password': 'Hide',
      'remember_session': 'Remember session',
      'forgot_password': 'Forgot password?',
      'forgot_password_dialog_title': 'Password Assistance',
      'forgot_password_dialog_msg':
          'To reset your credentials, contact the Municipal Grievance Helpline (1913) or verify your phone with the ward administration.',
      'close': 'Close',
      'sign_in': 'Sign In',
      'sign_up': 'Register Account',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'city': 'City / District',
      'municipality_label': 'Municipality / Corporation',
      'zone_label': 'Zone',
      'ward_label': 'Ward Number',
      'select_municipality': 'Select Corporation / Municipality',
      'select_zone': 'Select Zone',
      'select_ward': 'Select Ward',
      'search_ward_hint': 'Search ward by name or number...',
      'preferred_language_label': 'Preferred Language',
      'auth_code_optional': 'Government Authorization Code',
      'auth_code_hint': 'Required for Admin / Officer registration',
      'dont_have_account': "Don't have an account? Register here",
      'already_have_account': 'Already have an account? Sign In',
      'quick_dev_accounts': 'Developer Quick Test Accounts',
      'citizen': 'Citizen',
      'admin': 'Municipal Admin',
      'field_officer': 'Field Officer',
      'account_role': 'Account Role',

      'validation_required': 'This field is required',
      'validation_password_len': 'Password must be at least 6 characters',
      'validation_password_match': 'Passwords do not match',
      'validation_phone': 'Enter a valid 10-digit mobile number',
      'validation_email': 'Enter a valid email address',
      'validation_ward_required': 'Please select your residential ward',

      'home': 'Home',
      'complaints': 'Complaints',
      'ai_assistant': 'AI Assistant',
      'civic_map': 'Civic Map',
      'profile': 'Profile',
      'logout': 'Sign Out',
      'logout_confirm': 'Are you sure you want to sign out?',
      'cancel': 'Cancel',
      'done': 'Done',
      'retry': 'Retry',
      'connection_error': 'Connection Error',

      'welcome': 'Welcome',
      'lodge_complaint': 'Lodge Complaint',
      'my_complaints': 'My Complaints',
      'recent_issues': 'Recent Issues',
      'total_lodged': 'Total Lodged',
      'active_action': 'In Progress',
      'solved': 'Resolved',
      'filter_all': 'All',

      'lodge_complaint_title': 'Lodge Civic Complaint',
      'ai_notice':
          'Tamil & English supported. As you type, AI auto-classifies the category and urgency.',
      'issue_title': 'Title',
      'issue_title_hint': 'e.g., Water pipe burst on 2nd Avenue',
      'issue_description': 'Complaint Description',
      'issue_description_hint':
          'Describe problem in Tamil or English (e.g., குடிநீர் குழாய் உடைந்துள்ளது...)',
      'category_label': 'Department Category',
      'category_water': 'Water Supply',
      'category_waste': 'Solid Waste & Garbage',
      'category_roads': 'Road Damage & Potholes',
      'category_streetlights': 'Streetlights',
      'category_drainage': 'Drainage & Sewage',
      'ai_assessed_priority': 'AI Assessed Priority',
      'location_address': 'Location Address',

      'take_photo_camera': 'Take Photo with GPS Camera',
      'choose_gallery': 'Choose from Gallery',
      'photo_attached': 'Photo Attached with GPS Metadata',
      'retake_photo': 'Retake Photo',
      'remove_photo': 'Remove Photo',
      'gps_location_captured': 'GPS Location Captured',
      'gps_accuracy': 'Accuracy',
      'accuracy_meters': 'm',
      'accuracy_high': 'High Accuracy',
      'accuracy_medium': 'Moderate Accuracy',
      'accuracy_low': 'Poor Accuracy - Manual Review Recommended',
      'gps_disabled_warning':
          'GPS is disabled or permission denied. Please allow location access or specify the address manually.',
      'manual_location_entry': 'Manual Location Entry',
      'submit_anonymous': 'Submit Anonymously',
      'submit_anonymous_hint': 'Hide citizen name from public complaint list',
      'submit_complaint_button': 'Submit Complaint',
      'complaint_registered_title': 'Complaint Registered!',
      'ticket_number_is': 'Your complaint ticket number is:',
      'ticket_assigned_inspection':
          'Assigned to municipal department for field inspection within 24 hours.',

      'map_title': 'Interactive Civic Complaints Map (OpenStreetMap)',
      'map_subtitle': 'Live geo-referenced municipal issues across Tamil Nadu',
      'filter_water': 'Water',
      'filter_solid_waste': 'Solid Waste',
      'filter_roads': 'Roads',
      'filter_streetlights': 'Streetlights',
      'filter_drainage': 'Drainage',
      'view_details': 'View Details',
      'refresh': 'Refresh',
      'my_location': 'My Location',
      'loading_map': 'Loading OpenStreetMap tiles...',
      'no_complaints_found': 'No complaints found in this category',

      'status_submitted': 'Submitted',
      'status_under_review': 'Under Review',
      'status_assigned': 'Assigned',
      'status_in_progress': 'In Progress',
      'status_resolved': 'Resolved',
      'status_closed': 'Closed',
      'status_reopened': 'Reopened',
      'status_rejected': 'Rejected',

      'priority_critical': 'Critical',
      'priority_high': 'High',
      'priority_medium': 'Medium',
      'priority_low': 'Low',

      'profile_title': 'Citizen Profile',
      'account_details': 'Account Details',
      'registered_ward': 'Registered Ward',
      'registered_zone': 'Registered Zone',
      'registered_municipality': 'Municipality',
      'change_ward_request': 'Request Ward Correction',
      'select_new_ward': 'Select New Ward',
      'ward_update_success': 'Ward updated successfully!',
      'language_preference': 'Language Preference',
      'select_language_dialog': 'Choose Preferred Language',
      'save_changes': 'Save Changes',

      'admin_dashboard_title': 'Municipal Central Command',
      'officer_dashboard_title': 'Field Officer Workstation',
      'assign_complaint': 'Assign Complaint',
      'confirm_assignment': 'Confirm Assignment',
      'update_status': 'Update Status',
      'before_photo': 'Before Photo',
      'after_photo': 'After Photo',
      'resolution_notes': 'Resolution Notes',
      'mark_resolved': 'Mark Resolved',
    },
  };

  /// Translate by key (supports both camelCase and snake_case)
  String tr(String key) {
    final lang = locale.languageCode;
    // Check direct key
    String? val = _localizedValues[lang]?[key];
    if (val != null) return val;

    // Convert camelCase to snake_case
    final snakeKey = key.replaceAllMapped(
        RegExp(r'([A-Z])'), (m) => '_${m.group(1)!.toLowerCase()}');
    val = _localizedValues[lang]?[snakeKey];
    if (val != null) return val;

    // Convert snake_case to camelCase
    final camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'), (m) => m.group(1)!.toUpperCase());
    val = _localizedValues[lang]?[camelKey];
    if (val != null) return val;

    // Fallback to English
    return _localizedValues['en']?[key] ??
        _localizedValues['en']?[snakeKey] ??
        _localizedValues['en']?[camelKey] ??
        key;
  }

  // Common typed convenience getters
  String get appName => tr('app_name');
  String get appSubtitle => tr('app_subtitle');
  String get tagline => tr('tagline');
  String get loginTitle => tr('login_title');
  String get loginSubtitle => tr('login_subtitle');
  String get registerTitle => tr('register_title');
  String get registerSubtitle => tr('register_subtitle');
  String get signIn => tr('sign_in');
  String get signUp => tr('sign_up');
  String get emailOrPhone => tr('email_or_phone');
  String get password => tr('password');
  String get confirmPassword => tr('confirm_password');
  String get fullName => tr('full_name');
  String get phoneNumber => tr('phone_number');
  String get city => tr('city');
  String get municipalityLabel => tr('municipality_label');
  String get zoneLabel => tr('zone_label');
  String get wardLabel => tr('ward_label');
  String get home => tr('home');
  String get complaints => tr('complaints');
  String get aiAssistant => tr('ai_assistant');
  String get civicMap => tr('civic_map');
  String get profile => tr('profile');
  String get logout => tr('logout');
  String get cancel => tr('cancel');
  String get done => tr('done');
  String get retry => tr('retry');
  String get lodgeComplaint => tr('lodge_complaint');
  String get myComplaints => tr('my_complaints');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ta', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Global language controller with SharedPreferences persistence
class LanguageController extends ChangeNotifier {
  static final LanguageController _instance = LanguageController._internal();
  factory LanguageController() => _instance;

  Locale _currentLocale = const Locale('ta');
  Locale get currentLocale => _currentLocale;
  bool get isTamil => _currentLocale.languageCode == 'ta';

  LanguageController._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language_code') ?? 'ta';
    _currentLocale = Locale(savedCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newCode = _currentLocale.languageCode == 'ta' ? 'en' : 'ta';
    await setLanguage(newCode);
  }
}

/// Global Riverpod Provider for reactive language changes
final languageProvider = ChangeNotifierProvider<LanguageController>((ref) {
  return LanguageController();
});

/// Context Extension for easy localization access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
