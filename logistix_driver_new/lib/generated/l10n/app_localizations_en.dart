// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Logistix Driver';

  @override
  String get rideNow => 'Ride Now';

  @override
  String get scheduleForLater => 'Schedule for Later';

  @override
  String driverOnWay(String driverName) {
    return 'Your driver, $driverName, is on the way!';
  }

  @override
  String arrivalTime(int minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Will arrive in $minutesString minutes.';
  }

  @override
  String get arrivalTimeOne => 'Will arrive in 1 minute.';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get languageDescription =>
      'You can change your language preference anytime in the settings.';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get continueButton => 'Continue';

  @override
  String get change => 'CHANGE';

  @override
  String get verify => 'Verify';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get waitingToAutoVerify => 'Waiting to auto verify OTP';

  @override
  String get otpInstructions =>
      'One time password(OTP) has been sent to this number';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get invalidOtp => 'Invalid OTP. Please check and try again.';

  @override
  String get otpExpired => 'OTP has expired. Please request a new one.';

  @override
  String get next => 'Next';

  @override
  String get termsAndConditions => 'I agree to the Terms and Conditions';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get wallet => 'Wallet';

  @override
  String get trips => 'Trips';

  @override
  String get notifications => 'Notifications';

  @override
  String get home => 'Home';

  @override
  String get driverProfile => 'Driver Profile';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get noData => 'No data available';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get pleaseTryAgain => 'Please try again';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get locationPermission =>
      'Location permission is required for this feature';

  @override
  String get cameraPermission =>
      'Camera permission is required for this feature';

  @override
  String get storagePermission =>
      'Storage permission is required for this feature';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get exitApp => 'Exit App';

  @override
  String get areYouSureExit => 'Are you sure you want to exit the app?';

  @override
  String get exit => 'Exit';
}
