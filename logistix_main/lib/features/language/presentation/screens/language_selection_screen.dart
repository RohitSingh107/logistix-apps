import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../widgets/country_selection_dialog.dart';
import '../bloc/language_bloc.dart';
import '../../../../core/widgets/splash_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English';
  String selectedCountry = 'India';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              // Header Section
              Center(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).get('chooseLanguage'),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).get('languagePreferenceNote'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.neutralGrey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Language Selection Cards
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageCard(
                      'English',
                      'a',
                      selectedLanguage == 'English',
                      () => setState(() => selectedLanguage = 'English'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLanguageCard(
                      'हिन्दी',
                      'अ',
                      selectedLanguage == 'Hindi',
                      () => setState(() => selectedLanguage = 'Hindi'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Set the selected language and country
                    await LanguageService.setCountry(selectedCountry);
                    await LanguageService.setLanguage(selectedLanguage);
                    // Use BLoC to change language
                    context.read<LanguageBloc>().add(ChangeLanguageEvent(selectedLanguage));
                    // Navigate directly to login screen
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.pureWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).get('continue'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
                             // Country Selection
               GestureDetector(
                 onTap: () {
                   showDialog(
                     context: context,
                     builder: (context) => CountrySelectionDialog(
                       currentCountry: selectedCountry,
                       onCountrySelected: (country) {
                         setState(() {
                           selectedCountry = country;
                         });
                       },
                     ),
                   );
                 },
                 child: Row(
                   children: [
                     Text(
                       AppLocalizations.of(context).get('changeYourCountry'),
                       style: GoogleFonts.inter(
                         fontSize: 16,
                         color: AppColors.pureBlack,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                     const Spacer(),
                     Row(
                       children: [
                         // Country Flag (simplified)
                         Container(
                           width: 24,
                           height: 16,
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               colors: [
                                 Color(0xFFFF9933), // Saffron
                                 Color(0xFFFFFFFF), // White
                                 Color(0xFF138808), // Green
                               ],
                               begin: Alignment.topCenter,
                               end: Alignment.bottomCenter,
                             ),
                             borderRadius: BorderRadius.circular(2),
                           ),
                           child: const Center(
                             child: CircleAvatar(
                               radius: 2,
                               backgroundColor: Color(0xFF000080), // Navy Blue for Ashoka Chakra
                             ),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text(
                           selectedCountry,
                           style: GoogleFonts.inter(
                             fontSize: 16,
                             color: AppColors.pureBlack,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                         const SizedBox(width: 8),
                         const Icon(
                           Icons.keyboard_arrow_down,
                           color: AppColors.pureBlack,
                           size: 20,
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    String languageName,
    String alphabetChar,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160, // Reduced height
        decoration: BoxDecoration(
          color: AppColors.lightOrange,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primaryOrange, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      languageName,
                      style: GoogleFonts.poppins(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 18, // Slightly smaller
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                      border: Border.all(
                        color: AppColors.primaryOrange,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 10, // Smaller icon
                              color: AppColors.pureWhite,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Text(
                  alphabetChar,
                  style: GoogleFonts.poppins(
                    fontSize: 60, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
            ],
          ),
        ),
      ),
    );
  }
} 