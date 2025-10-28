/// language_selection_screen.dart - Language Selection Interface
/// 
/// Purpose:
/// - Provides user interface for selecting preferred language
/// - Supports English and Hindi language options
/// - Manages language state and persistence
/// - Navigates to login screen after selection
/// 
/// Key Logic:
/// - Displays two language cards with visual indicators
/// - Handles language selection with radio button-like indicators
/// - Saves selected language preference using SharedPreferences
/// - Provides smooth navigation to login screen
/// - Maintains consistent UI design with app theme
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en'; // Default to English

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // Light gray background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60), // Top spacing
              
              // Title Section
              Text(
                l10n.chooseLanguage,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                l10n.languageDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Language Selection Cards
              Row(
                children: [
                  // English Card
                  Expanded(
                    child: _buildLanguageCard(
                      context: context,
                      languageCode: 'en',
                      languageName: l10n.english,
                      character: 'a',
                      isSelected: _selectedLanguage == 'en',
                      onTap: () => _selectLanguage('en'),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Hindi Card
                  Expanded(
                    child: _buildLanguageCard(
                      context: context,
                      languageCode: 'hi',
                      languageName: l10n.hindi,
                      character: 'अ',
                      isSelected: _selectedLanguage == 'hi',
                      onTap: () => _selectLanguage('hi'),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continueWithLanguage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, // Orange-brown
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.continueButton,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String character,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFD2B48C), // Light brown/tan background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language name and radio button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    languageName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  // Radio button indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Large character
              Center(
                child: Text(
                  character,
                  style: languageCode == 'hi' 
                    ? GoogleFonts.notoSansDevanagari(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )
                    : GoogleFonts.inter(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    // Immediately change the language when user selects
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(Locale(languageCode));
  }

  void _continueWithLanguage() {
    // Language is already set when user selected it, just navigate
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
