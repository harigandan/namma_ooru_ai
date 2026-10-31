// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Namma Ooru AI';

  @override
  String get appSubtitle => 'Tamil Nadu Municipal Administration (GCC)';

  @override
  String get tagline => 'Smart Civic Issue Resolution & Governance Platform';

  @override
  String get tamilNaduAdministration => 'Tamil Nadu Municipal Administration';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Access your civic dashboard and track services';

  @override
  String get registerTitle => 'Citizen Registration';

  @override
  String get registerSubtitle =>
      'Create an account to lodge civic issues and track resolution in your ward';

  @override
  String get emailOrPhone => 'Email or Phone Number';

  @override
  String get emailOrPhoneHint => 'citizen@nammaooru.ai / 9840000002';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Minimum 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get rememberSession => 'Remember session';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordDialogTitle => 'Password Assistance';

  @override
  String get forgotPasswordDialogMsg =>
      'To reset your credentials, contact the Municipal Grievance Helpline (1913) or verify your phone with the ward administration.';

  @override
  String get close => 'Close';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Register Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get city => 'City / District';

  @override
  String get municipalityLabel => 'Municipality / Corporation';

  @override
  String get zoneLabel => 'Zone';

  @override
  String get wardLabel => 'Ward Number';

  @override
  String get selectMunicipality => 'Select Corporation / Municipality';

  @override
  String get selectZone => 'Select Zone';

  @override
  String get selectWard => 'Select Ward';

  @override
  String get searchWardHint => 'Search ward by name or number...';

  @override
  String get preferredLanguageLabel => 'Preferred Language';

  @override
  String get authCodeOptional => 'Government Authorization Code';

  @override
  String get authCodeHint => 'Required for Admin / Officer registration';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register here';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get quickDevAccounts => 'Developer Quick Test Accounts';

  @override
  String get citizen => 'Citizen';

  @override
  String get admin => 'Municipal Admin';

  @override
  String get fieldOfficer => 'Field Officer';

  @override
  String get accountRole => 'Account Role';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationPasswordLen => 'Password must be at least 6 characters';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get validationPhone => 'Enter a valid 10-digit mobile number';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationWardRequired => 'Please select your residential ward';

  @override
  String get home => 'Home';

  @override
  String get complaints => 'Complaints';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get civicMap => 'Civic Map';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get welcome => 'Welcome';

  @override
  String get lodgeComplaint => 'Lodge Complaint';

  @override
  String get myComplaints => 'My Complaints';

  @override
  String get recentIssues => 'Recent Issues';

  @override
  String get totalLodged => 'Total Lodged';

  @override
  String get activeAction => 'In Progress';

  @override
  String get solved => 'Resolved';

  @override
  String get filterAll => 'All';

  @override
  String get lodgeComplaintTitle => 'Lodge Civic Complaint';

  @override
  String get aiNotice =>
      'Tamil & English supported. As you type, AI auto-classifies the category and urgency.';

  @override
  String get issueTitle => 'Title';

  @override
  String get issueTitleHint => 'e.g., Water pipe burst on 2nd Avenue';

  @override
  String get issueDescription => 'Complaint Description';

  @override
  String get issueDescriptionHint =>
      'Describe problem in Tamil or English (e.g., குடிநீர் குழாய் உடைந்துள்ளது...)';

  @override
  String get categoryLabel => 'Department Category';

  @override
  String get categoryWater => 'Water Supply';

  @override
  String get categoryWaste => 'Solid Waste & Garbage';

  @override
  String get categoryRoads => 'Road Damage & Potholes';

  @override
  String get categoryStreetlights => 'Streetlights';

  @override
  String get categoryDrainage => 'Drainage & Sewage';

  @override
  String get aiAssessedPriority => 'AI Assessed Priority';

  @override
  String get locationAddress => 'Location Address';

  @override
  String get takePhotoCamera => 'Take Photo with GPS Camera';

  @override
  String get chooseGallery => 'Choose from Gallery';

  @override
  String get photoAttached => 'Photo Attached with GPS Metadata';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get gpsLocationCaptured => 'GPS Location Captured';

  @override
  String get gpsAccuracy => 'Accuracy';

  @override
  String get accuracyMeters => 'm';

  @override
  String get accuracyHigh => 'High Accuracy';

  @override
  String get accuracyMedium => 'Moderate Accuracy';

  @override
  String get accuracyLow => 'Poor Accuracy - Manual Review Recommended';

  @override
  String get gpsDisabledWarning =>
      'GPS is disabled or permission denied. Please allow location access or specify the address manually.';

  @override
  String get manualLocationEntry => 'Manual Location Entry';

  @override
  String get submitAnonymous => 'Submit Anonymously';

  @override
  String get submitAnonymousHint =>
      'Hide citizen name from public complaint list';

  @override
  String get submitComplaintButton => 'Submit Complaint';

  @override
  String get complaintRegisteredTitle => 'Complaint Registered!';

  @override
  String get ticketNumberIs => 'Your complaint ticket number is:';

  @override
  String get ticketAssignedInspection =>
      'Assigned to municipal department for field inspection within 24 hours.';

  @override
  String get mapTitle => 'Interactive Civic Complaints Map (OpenStreetMap)';

  @override
  String get mapSubtitle =>
      'Live geo-referenced municipal issues across Tamil Nadu';

  @override
  String get filterWater => 'Water';

  @override
  String get filterSolidWaste => 'Solid Waste';

  @override
  String get filterRoads => 'Roads';

  @override
  String get filterStreetlights => 'Streetlights';

  @override
  String get filterDrainage => 'Drainage';

  @override
  String get viewDetails => 'View Details';

  @override
  String get refresh => 'Refresh';

  @override
  String get myLocation => 'My Location';

  @override
  String get loadingMap => 'Loading OpenStreetMap tiles...';

  @override
  String get noComplaintsFound => 'No complaints found in this category';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusReopened => 'Reopened';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get profileTitle => 'Citizen Profile';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get registeredWard => 'Registered Ward';

  @override
  String get registeredZone => 'Registered Zone';

  @override
  String get registeredMunicipality => 'Municipality';

  @override
  String get changeWardRequest => 'Request Ward Correction';

  @override
  String get selectNewWard => 'Select New Ward';

  @override
  String get wardUpdateSuccess => 'Ward updated successfully!';

  @override
  String get languagePreference => 'Language Preference';

  @override
  String get selectLanguageDialog => 'Choose Preferred Language';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get adminDashboardTitle => 'Municipal Central Command';

  @override
  String get officerDashboardTitle => 'Field Officer Workstation';

  @override
  String get assignComplaint => 'Assign Complaint';

  @override
  String get confirmAssignment => 'Confirm Assignment';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get beforePhoto => 'Before Photo';

  @override
  String get afterPhoto => 'After Photo';

  @override
  String get resolutionNotes => 'Resolution Notes';

  @override
  String get markResolved => 'Mark Resolved';
}
