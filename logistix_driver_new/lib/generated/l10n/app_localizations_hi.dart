// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'लॉजिस्टिक्स ड्राइवर';

  @override
  String get rideNow => 'अभी सवारी करें';

  @override
  String get scheduleForLater => 'बाद के लिए शेड्यूल करें';

  @override
  String driverOnWay(String driverName) {
    return 'आपका ड्राइवर, $driverName, रास्ते में है!';
  }

  @override
  String arrivalTime(int minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString मिनट में पहुंचेगा।';
  }

  @override
  String get arrivalTimeOne => '1 मिनट में पहुंचेगा।';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get languageDescription =>
      'आप सेटिंग्स में कभी भी अपनी भाषा प्राथमिकता बदल सकते हैं।';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get change => 'बदलें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get resendOtp => 'OTP पुनः भेजें';

  @override
  String get waitingToAutoVerify =>
      'OTP को स्वचालित रूप से सत्यापित करने की प्रतीक्षा कर रहे हैं';

  @override
  String get otpInstructions =>
      'इस नंबर पर एक बार का पासवर्ड (OTP) भेजा गया है';

  @override
  String get enterOtp => 'OTP दर्ज करें';

  @override
  String get invalidOtp => 'अमान्य OTP। कृपया जांच करें और पुनः प्रयास करें।';

  @override
  String get otpExpired => 'OTP समाप्त हो गया है। कृपया नया अनुरोध करें।';

  @override
  String get next => 'अगला';

  @override
  String get termsAndConditions => 'मैं नियम और शर्तों से सहमत हूं';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get trips => 'यात्राएं';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get home => 'होम';

  @override
  String get driverProfile => 'ड्राइवर प्रोफाइल';

  @override
  String get createProfile => 'प्रोफाइल बनाएं';

  @override
  String get firstName => 'पहला नाम';

  @override
  String get lastName => 'अंतिम नाम';

  @override
  String get email => 'ईमेल';

  @override
  String get address => 'पता';

  @override
  String get save => 'सेव करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get yes => 'हां';

  @override
  String get no => 'नहीं';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String get warning => 'चेतावनी';

  @override
  String get info => 'जानकारी';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get back => 'वापस';

  @override
  String get close => 'बंद करें';

  @override
  String get done => 'हो गया';

  @override
  String get search => 'खोजें';

  @override
  String get filter => 'फिल्टर';

  @override
  String get sort => 'सॉर्ट करें';

  @override
  String get refresh => 'रिफ्रेश करें';

  @override
  String get pullToRefresh => 'रिफ्रेश के लिए खींचें';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get somethingWentWrong => 'कुछ गलत हुआ';

  @override
  String get pleaseTryAgain => 'कृपया पुनः प्रयास करें';

  @override
  String get permissionDenied => 'अनुमति अस्वीकृत';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get locationPermission => 'इस सुविधा के लिए स्थान अनुमति आवश्यक है';

  @override
  String get cameraPermission => 'इस सुविधा के लिए कैमरा अनुमति आवश्यक है';

  @override
  String get storagePermission => 'इस सुविधा के लिए स्टोरेज अनुमति आवश्यक है';

  @override
  String get grantPermission => 'अनुमति दें';

  @override
  String get goToSettings => 'सेटिंग्स पर जाएं';

  @override
  String get exitApp => 'ऐप से बाहर निकलें';

  @override
  String get areYouSureExit => 'क्या आप वाकई ऐप से बाहर निकलना चाहते हैं?';

  @override
  String get exit => 'बाहर निकलें';
}
