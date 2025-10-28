/// localized_home_page.dart - Sample HomePage with Localization
/// 
/// Purpose:
/// - Demonstrates how to use localized strings in Flutter
/// - Shows language switcher in AppBar
/// - Includes examples of placeholders and pluralization
/// - Provides a complete example of i18n implementation
/// 
/// Key Logic:
/// - Uses AppLocalizations for accessing translated strings
/// - Implements language switcher with PopupMenuButton
/// - Shows examples of different localization features
/// - Demonstrates proper font usage for different scripts
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LocalizedHomePage extends StatefulWidget {
  const LocalizedHomePage({super.key});

  @override
  State<LocalizedHomePage> createState() => _LocalizedHomePageState();
}

class _LocalizedHomePageState extends State<LocalizedHomePage> {
  final String _driverName = 'John Doe';
  int _arrivalMinutes = 5;

  /// Get appropriate font style based on locale
  TextStyle _getFontStyle(LocaleProvider localeProvider, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    if (localeProvider.currentLocale.languageCode == 'hi') {
      return GoogleFonts.notoSansDevanagari(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Language Switcher
          PopupMenuButton<Locale>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localeProvider.getLocaleFlag(localeProvider.currentLocale),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.language, size: 20),
              ],
            ),
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return localeProvider.supportedLocales.map((Locale locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    children: [
                      Text(
                        localeProvider.getLocaleFlag(locale),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localeProvider.getLocaleDisplayName(locale),
                        style: TextStyle(
                          fontFamily: locale.languageCode == 'hi' 
                            ? 'NotoSansDevanagari' 
                            : 'Inter',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: _getFontStyle(
                        localeProvider,
                        fontSize: theme.textTheme.headlineMedium?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.home,
                      style: _getFontStyle(
                        localeProvider,
                        fontSize: theme.textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.rideNow)),
                      );
                    },
                    icon: const Icon(Icons.directions_car),
                    label: Text(
                      l10n.rideNow,
                      style: TextStyle(
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.scheduleForLater)),
                      );
                    },
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      l10n.scheduleForLater,
                      style: TextStyle(
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Driver Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverOnWay(_driverName),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _arrivalMinutes == 1 
                        ? l10n.arrivalTimeOne
                        : l10n.arrivalTime(_arrivalMinutes),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _arrivalMinutes.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_arrivalMinutes',
                            onChanged: (value) {
                              setState(() {
                                _arrivalMinutes = value.round();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$_arrivalMinutes',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                              ? 'NotoSansDevanagari' 
                              : 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildNavigationCard(
                  context: context,
                  icon: Icons.person,
                  title: l10n.profile,
                  localeProvider: localeProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.profile)),
                    );
                  },
                ),
                _buildNavigationCard(
                  context: context,
                  icon: Icons.account_balance_wallet,
                  title: l10n.wallet,
                  localeProvider: localeProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.wallet)),
                    );
                  },
                ),
                _buildNavigationCard(
                  context: context,
                  icon: Icons.directions_car,
                  title: l10n.trips,
                  localeProvider: localeProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.trips)),
                    );
                  },
                ),
                _buildNavigationCard(
                  context: context,
                  icon: Icons.notifications,
                  title: l10n.notifications,
                  localeProvider: localeProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.notifications)),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Language Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chooseLanguage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.languageDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                          ? 'NotoSansDevanagari' 
                          : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${l10n.info}: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                              ? 'NotoSansDevanagari' 
                              : 'Inter',
                          ),
                        ),
                        Text(
                          '${localeProvider.getLocaleFlag(localeProvider.currentLocale)} ${localeProvider.getLocaleDisplayName(localeProvider.currentLocale)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                              ? 'NotoSansDevanagari' 
                              : 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required LocaleProvider localeProvider,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: localeProvider.currentLocale.languageCode == 'hi' 
                    ? 'NotoSansDevanagari' 
                    : 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
