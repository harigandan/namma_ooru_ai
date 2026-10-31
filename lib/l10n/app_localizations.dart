import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Namma Ooru AI'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tamil Nadu Municipal Administration (GCC)'**
  String get appSubtitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Civic Issue Resolution & Governance Platform'**
  String get tagline;

  /// No description provided for @tamilNaduAdministration.
  ///
  /// In en, this message translates to:
  /// **'Tamil Nadu Municipal Administration'**
  String get tamilNaduAdministration;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your civic dashboard and track services'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen Registration'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to lodge civic issues and track resolution in your ward'**
  String get registerSubtitle;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get emailOrPhone;

  /// No description provided for @emailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'citizen@nammaooru.ai / 9840000002'**
  String get emailOrPhoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hidePassword;

  /// No description provided for @rememberSession.
  ///
  /// In en, this message translates to:
  /// **'Remember session'**
  String get rememberSession;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Assistance'**
  String get forgotPasswordDialogTitle;

  /// No description provided for @forgotPasswordDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'To reset your credentials, contact the Municipal Grievance Helpline (1913) or verify your phone with the ward administration.'**
  String get forgotPasswordDialogMsg;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get signUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City / District'**
  String get city;

  /// No description provided for @municipalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Municipality / Corporation'**
  String get municipalityLabel;

  /// No description provided for @zoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zoneLabel;

  /// No description provided for @wardLabel.
  ///
  /// In en, this message translates to:
  /// **'Ward Number'**
  String get wardLabel;

  /// No description provided for @selectMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Select Corporation / Municipality'**
  String get selectMunicipality;

  /// No description provided for @selectZone.
  ///
  /// In en, this message translates to:
  /// **'Select Zone'**
  String get selectZone;

  /// No description provided for @selectWard.
  ///
  /// In en, this message translates to:
  /// **'Select Ward'**
  String get selectWard;

  /// No description provided for @searchWardHint.
  ///
  /// In en, this message translates to:
  /// **'Search ward by name or number...'**
  String get searchWardHint;

  /// No description provided for @preferredLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguageLabel;

  /// No description provided for @authCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Government Authorization Code'**
  String get authCodeOptional;

  /// No description provided for @authCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Required for Admin / Officer registration'**
  String get authCodeHint;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register here'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @quickDevAccounts.
  ///
  /// In en, this message translates to:
  /// **'Developer Quick Test Accounts'**
  String get quickDevAccounts;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Municipal Admin'**
  String get admin;

  /// No description provided for @fieldOfficer.
  ///
  /// In en, this message translates to:
  /// **'Field Officer'**
  String get fieldOfficer;

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Account Role'**
  String get accountRole;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationPasswordLen.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordLen;

  /// No description provided for @validationPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMatch;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationWardRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your residential ward'**
  String get validationWardRequired;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @civicMap.
  ///
  /// In en, this message translates to:
  /// **'Civic Map'**
  String get civicMap;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @lodgeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Lodge Complaint'**
  String get lodgeComplaint;

  /// No description provided for @myComplaints.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get myComplaints;

  /// No description provided for @recentIssues.
  ///
  /// In en, this message translates to:
  /// **'Recent Issues'**
  String get recentIssues;

  /// No description provided for @totalLodged.
  ///
  /// In en, this message translates to:
  /// **'Total Lodged'**
  String get totalLodged;

  /// No description provided for @activeAction.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get activeAction;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get solved;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @lodgeComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Lodge Civic Complaint'**
  String get lodgeComplaintTitle;

  /// No description provided for @aiNotice.
  ///
  /// In en, this message translates to:
  /// **'Tamil & English supported. As you type, AI auto-classifies the category and urgency.'**
  String get aiNotice;

  /// No description provided for @issueTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get issueTitle;

  /// No description provided for @issueTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Water pipe burst on 2nd Avenue'**
  String get issueTitleHint;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Complaint Description'**
  String get issueDescription;

  /// No description provided for @issueDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe problem in Tamil or English (e.g., குடிநீர் குழாய் உடைந்துள்ளது...)'**
  String get issueDescriptionHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Department Category'**
  String get categoryLabel;

  /// No description provided for @categoryWater.
  ///
  /// In en, this message translates to:
  /// **'Water Supply'**
  String get categoryWater;

  /// No description provided for @categoryWaste.
  ///
  /// In en, this message translates to:
  /// **'Solid Waste & Garbage'**
  String get categoryWaste;

  /// No description provided for @categoryRoads.
  ///
  /// In en, this message translates to:
  /// **'Road Damage & Potholes'**
  String get categoryRoads;

  /// No description provided for @categoryStreetlights.
  ///
  /// In en, this message translates to:
  /// **'Streetlights'**
  String get categoryStreetlights;

  /// No description provided for @categoryDrainage.
  ///
  /// In en, this message translates to:
  /// **'Drainage & Sewage'**
  String get categoryDrainage;

  /// No description provided for @aiAssessedPriority.
  ///
  /// In en, this message translates to:
  /// **'AI Assessed Priority'**
  String get aiAssessedPriority;

  /// No description provided for @locationAddress.
  ///
  /// In en, this message translates to:
  /// **'Location Address'**
  String get locationAddress;

  /// No description provided for @takePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with GPS Camera'**
  String get takePhotoCamera;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseGallery;

  /// No description provided for @photoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo Attached with GPS Metadata'**
  String get photoAttached;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @gpsLocationCaptured.
  ///
  /// In en, this message translates to:
  /// **'GPS Location Captured'**
  String get gpsLocationCaptured;

  /// No description provided for @gpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get gpsAccuracy;

  /// No description provided for @accuracyMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get accuracyMeters;

  /// No description provided for @accuracyHigh.
  ///
  /// In en, this message translates to:
  /// **'High Accuracy'**
  String get accuracyHigh;

  /// No description provided for @accuracyMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate Accuracy'**
  String get accuracyMedium;

  /// No description provided for @accuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Poor Accuracy - Manual Review Recommended'**
  String get accuracyLow;

  /// No description provided for @gpsDisabledWarning.
  ///
  /// In en, this message translates to:
  /// **'GPS is disabled or permission denied. Please allow location access or specify the address manually.'**
  String get gpsDisabledWarning;

  /// No description provided for @manualLocationEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Location Entry'**
  String get manualLocationEntry;

  /// No description provided for @submitAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Submit Anonymously'**
  String get submitAnonymous;

  /// No description provided for @submitAnonymousHint.
  ///
  /// In en, this message translates to:
  /// **'Hide citizen name from public complaint list'**
  String get submitAnonymousHint;

  /// No description provided for @submitComplaintButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaintButton;

  /// No description provided for @complaintRegisteredTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint Registered!'**
  String get complaintRegisteredTitle;

  /// No description provided for @ticketNumberIs.
  ///
  /// In en, this message translates to:
  /// **'Your complaint ticket number is:'**
  String get ticketNumberIs;

  /// No description provided for @ticketAssignedInspection.
  ///
  /// In en, this message translates to:
  /// **'Assigned to municipal department for field inspection within 24 hours.'**
  String get ticketAssignedInspection;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive Civic Complaints Map (OpenStreetMap)'**
  String get mapTitle;

  /// No description provided for @mapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live geo-referenced municipal issues across Tamil Nadu'**
  String get mapSubtitle;

  /// No description provided for @filterWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get filterWater;

  /// No description provided for @filterSolidWaste.
  ///
  /// In en, this message translates to:
  /// **'Solid Waste'**
  String get filterSolidWaste;

  /// No description provided for @filterRoads.
  ///
  /// In en, this message translates to:
  /// **'Roads'**
  String get filterRoads;

  /// No description provided for @filterStreetlights.
  ///
  /// In en, this message translates to:
  /// **'Streetlights'**
  String get filterStreetlights;

  /// No description provided for @filterDrainage.
  ///
  /// In en, this message translates to:
  /// **'Drainage'**
  String get filterDrainage;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading OpenStreetMap tiles...'**
  String get loadingMap;

  /// No description provided for @noComplaintsFound.
  ///
  /// In en, this message translates to:
  /// **'No complaints found in this category'**
  String get noComplaintsFound;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get statusReopened;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen Profile'**
  String get profileTitle;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @registeredWard.
  ///
  /// In en, this message translates to:
  /// **'Registered Ward'**
  String get registeredWard;

  /// No description provided for @registeredZone.
  ///
  /// In en, this message translates to:
  /// **'Registered Zone'**
  String get registeredZone;

  /// No description provided for @registeredMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get registeredMunicipality;

  /// No description provided for @changeWardRequest.
  ///
  /// In en, this message translates to:
  /// **'Request Ward Correction'**
  String get changeWardRequest;

  /// No description provided for @selectNewWard.
  ///
  /// In en, this message translates to:
  /// **'Select New Ward'**
  String get selectNewWard;

  /// No description provided for @wardUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ward updated successfully!'**
  String get wardUpdateSuccess;

  /// No description provided for @languagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language Preference'**
  String get languagePreference;

  /// No description provided for @selectLanguageDialog.
  ///
  /// In en, this message translates to:
  /// **'Choose Preferred Language'**
  String get selectLanguageDialog;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Municipal Central Command'**
  String get adminDashboardTitle;

  /// No description provided for @officerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Officer Workstation'**
  String get officerDashboardTitle;

  /// No description provided for @assignComplaint.
  ///
  /// In en, this message translates to:
  /// **'Assign Complaint'**
  String get assignComplaint;

  /// No description provided for @confirmAssignment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Assignment'**
  String get confirmAssignment;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @beforePhoto.
  ///
  /// In en, this message translates to:
  /// **'Before Photo'**
  String get beforePhoto;

  /// No description provided for @afterPhoto.
  ///
  /// In en, this message translates to:
  /// **'After Photo'**
  String get afterPhoto;

  /// No description provided for @resolutionNotes.
  ///
  /// In en, this message translates to:
  /// **'Resolution Notes'**
  String get resolutionNotes;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
