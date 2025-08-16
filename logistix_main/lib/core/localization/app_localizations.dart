import 'package:flutter/material.dart';

/// App Localizations
/// 
/// Provides localized strings for English and Hindi
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Language Selection Screen
      'chooseLanguage': 'Choose Language',
      'languagePreferenceNote': 'You can change your language preference anytime in the settings.',
             'continue': 'Continue',
       'changeYourCountry': 'Change Your Country',
       'selectCountry': 'Select Country',
      
      // Common
      'login': 'Login',
      'signup': 'Sign Up',
      'home': 'Home',
      'welcomeBack': 'Welcome Back!',
      'sendOtp': 'Send OTP',
      'pleaseEnterValidPhone': 'Please enter a valid phone number',
      'userNotFound': 'User Not Found',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      
      // Auth
      'emailAddress': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'phoneNumber': 'Phone Number',
      'otp': 'OTP',
      'resendOtp': 'Resend OTP',
      'verifyOtp': 'Verify OTP',
      
      // Booking
      'bookNow': 'Book Now',
      'booking': 'Booking',
      'pickupLocation': 'Pickup Location',
      'deliveryLocation': 'Delivery Location',
      'packageDetails': 'Package Details',
      'weight': 'Weight',
      'dimensions': 'Dimensions',
      'fragile': 'Fragile',
      'express': 'Express',
      'standard': 'Standard',
      'scheduled': 'Scheduled',
      
      // Tracking
      'trackPackage': 'Track Package',
      'trackingNumber': 'Tracking Number',
      'liveTracking': 'Live Tracking',
      'status': 'Status',
      'estimatedDelivery': 'Estimated Delivery',
      'inTransit': 'In Transit',
      'delivered': 'Delivered',
      'outForDelivery': 'Out for Delivery',
      
      // Payment
      'payment': 'Payment',
      'paymentMethods': 'Payment Methods',
      'addPaymentMethod': 'Add Payment Method',
      'cardNumber': 'Card Number',
      'expiryDate': 'Expiry Date',
      'cvv': 'CVV',
      'cardholderName': 'Cardholder Name',
      'pay': 'Pay',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'discount': 'Discount',
      
      // Wallet
      'wallet': 'Wallet',
      'balance': 'Balance',
      'addMoney': 'Add Money',
      'withdraw': 'Withdraw',
      'transactions': 'Transactions',
      'recentTransactions': 'Recent Transactions',
      
      // Support
      'support': 'Support',
      'help': 'Help',
      'contactUs': 'Contact Us',
      'faq': 'FAQ',
      'chat': 'Chat',
      'call': 'Call',
      'email': 'Email',
      
      // Settings
      'language': 'Language',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'terms': 'Terms',
      'about': 'About',
      'version': 'Version',
      'rateApp': 'Rate App',
      'shareApp': 'Share App',
    },
         'hi': {
       // Language Selection Screen
       'chooseLanguage': 'भाषा चुनें',
       'languagePreferenceNote': 'आप अपनी भाषा की पसंद को कभी भी सेटिंग्स में बदल सकते हैं।',
       'continue': 'जारी रखें',
       'changeYourCountry': 'अपना देश बदलें',
       'selectCountry': 'देश चुनें',
      
      // Common
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'home': 'होम',
      'welcomeBack': 'वापसी पर स्वागत है!',
      'sendOtp': 'OTP भेजें',
      'pleaseEnterValidPhone': 'कृपया एक वैध फोन नंबर दर्ज करें',
      'userNotFound': 'उपयोगकर्ता नहीं मिला',
      'profile': 'प्रोफाइल',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'search': 'खोजें',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'warning': 'चेतावनी',
      'info': 'जानकारी',
      
      // Auth
      'emailAddress': 'ईमेल',
      'password': 'पासवर्ड',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'dontHaveAccount': 'खाता नहीं है?',
      'alreadyHaveAccount': 'पहले से खाता है?',
      'signIn': 'साइन इन',
      'signUp': 'साइन अप',
      'phoneNumber': 'फोन नंबर',
      'otp': 'OTP',
      'resendOtp': 'OTP पुनः भेजें',
      'verifyOtp': 'OTP सत्यापित करें',
      
      // Booking
      'bookNow': 'अभी बुक करें',
      'booking': 'बुकिंग',
      'pickupLocation': 'पिकअप स्थान',
      'deliveryLocation': 'डिलीवरी स्थान',
      'packageDetails': 'पैकेज विवरण',
      'weight': 'वजन',
      'dimensions': 'आयाम',
      'fragile': 'नाजुक',
      'express': 'एक्सप्रेस',
      'standard': 'मानक',
      'scheduled': 'अनुसूचित',
      
      // Tracking
      'trackPackage': 'पैकेज ट्रैक करें',
      'trackingNumber': 'ट्रैकिंग नंबर',
      'liveTracking': 'लाइव ट्रैकिंग',
      'status': 'स्थिति',
      'estimatedDelivery': 'अनुमानित डिलीवरी',
      'inTransit': 'पारगमन में',
      'delivered': 'पहुंचा दिया गया',
      'outForDelivery': 'डिलीवरी के लिए बाहर',
      
      // Payment
      'payment': 'भुगतान',
      'paymentMethods': 'भुगतान के तरीके',
      'addPaymentMethod': 'भुगतान का तरीका जोड़ें',
      'cardNumber': 'कार्ड नंबर',
      'expiryDate': 'समाप्ति तिथि',
      'cvv': 'CVV',
      'cardholderName': 'कार्डधारक का नाम',
      'pay': 'भुगतान करें',
      'total': 'कुल',
      'subtotal': 'उप-कुल',
      'tax': 'कर',
      'discount': 'छूट',
      
      // Wallet
      'wallet': 'बटुआ',
      'balance': 'शेष राशि',
      'addMoney': 'पैसा जोड़ें',
      'withdraw': 'निकासी',
      'transactions': 'लेन-देन',
      'recentTransactions': 'हाल के लेन-देन',
      
      // Support
      'support': 'सहायता',
      'help': 'मदद',
      'contactUs': 'हमसे संपर्क करें',
      'faq': 'सामान्य प्रश्न',
      'chat': 'चैट',
      'call': 'कॉल',
      'email': 'ईमेल',
      
      // Settings
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'privacy': 'गोपनीयता',
      'terms': 'शर्तें',
      'about': 'के बारे में',
      'version': 'संस्करण',
      'rateApp': 'ऐप रेट करें',
      'shareApp': 'ऐप शेयर करें',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']![key] ?? 
           key;
  }
}

/// App Localizations Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 