import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class CountrySelectionDialog extends StatelessWidget {
  final String currentCountry;
  final Function(String) onCountrySelected;

  const CountrySelectionDialog({
    super.key,
    required this.currentCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final countries = [
      {'name': 'India', 'flag': '🇮🇳'},
      {'name': 'United States', 'flag': '🇺🇸'},
      {'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'name': 'Canada', 'flag': '🇨🇦'},
      {'name': 'Australia', 'flag': '🇦🇺'},
      {'name': 'Germany', 'flag': '🇩🇪'},
      {'name': 'France', 'flag': '🇫🇷'},
      {'name': 'Japan', 'flag': '🇯🇵'},
      {'name': 'China', 'flag': '🇨🇳'},
      {'name': 'Brazil', 'flag': '🇧🇷'},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).get('selectCountry'),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.pureBlack,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = country['name'] == currentCountry;
                  
                  return ListTile(
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primaryOrange : AppColors.pureBlack,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: AppColors.primaryOrange,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onCountrySelected(country['name']!);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context).get('cancel'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.neutralGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 