import 'package:flutter/material.dart';
import '../../data/services/location_service.dart';

/// Professional Uber-like search results widget
class SearchResultsWidget extends StatelessWidget {
  final List<PlaceResult> searchResults;
  final List<PlaceResult> recentSearches;
  final List<SavedPlace> savedPlaces;
  final bool isLoading;
  final bool showRecentSearches;
  final bool showSavedPlaces;
  final Function(PlaceResult) onResultSelected;
  final Function(SavedPlace) onSavedPlaceSelected;
  final VoidCallback? onClearRecent;
  final String searchQuery;

  const SearchResultsWidget({
    Key? key,
    required this.searchResults,
    required this.recentSearches,
    required this.savedPlaces,
    required this.isLoading,
    required this.onResultSelected,
    required this.onSavedPlaceSelected,
    this.showRecentSearches = true,
    this.showSavedPlaces = true,
    this.onClearRecent,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.5, // Limit height to prevent overlapping
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Results Section
          if (searchQuery.isNotEmpty && searchResults.isNotEmpty) ...[
            _buildSectionHeader('SEARCH RESULTS', theme),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return _buildSearchResultTile(searchResults[index], theme);
                },
              ),
            ),
          ],
          
          // Loading Indicator
          if (isLoading) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Searching...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // No Results Message
          if (searchQuery.isNotEmpty && searchResults.isEmpty && !isLoading) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No results found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try a different search term or check your spelling',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          
          // Saved Places Section
          if (showSavedPlaces && savedPlaces.isNotEmpty && searchQuery.isEmpty) ...[
            if (searchQuery.isEmpty) const Divider(height: 1),
            _buildSectionHeader('SAVED PLACES', theme),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedPlaces.length,
                itemBuilder: (context, index) {
                  return _buildSavedPlaceTile(savedPlaces[index], theme);
                },
              ),
            ),
          ],
          
          // Recent Searches Section
          if (showRecentSearches && recentSearches.isNotEmpty && searchQuery.isEmpty) ...[
            if (searchQuery.isEmpty) const Divider(height: 1),
            _buildRecentSearchesHeader(theme),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  return _buildRecentSearchTile(recentSearches[index], theme);
                },
              ),
            ),
          ],
          
          // Empty State
          if (searchQuery.isEmpty && 
              savedPlaces.isEmpty && 
              recentSearches.isEmpty && 
              !isLoading) ...[
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search for a location',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter an address, landmark, or business name',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RECENT',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (onClearRecent != null)
            TextButton(
              onPressed: onClearRecent,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: Text(
                'Clear',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(PlaceResult result, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getPlaceIcon(result.placeType),
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        result.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => onResultSelected(result),
    );
  }

  Widget _buildSavedPlaceTile(SavedPlace place, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          place.type == SavedPlaceType.home ? Icons.home : Icons.work,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        place.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        place.address,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => onSavedPlaceSelected(place),
    );
  }

  Widget _buildRecentSearchTile(PlaceResult result, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.history,
          color: theme.colorScheme.outline,
          size: 20,
        ),
      ),
      title: Text(
        result.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => onResultSelected(result),
    );
  }

  IconData _getPlaceIcon(PlaceType placeType) {
    switch (placeType) {
      case PlaceType.airport:
        return Icons.flight;
      case PlaceType.station:
        return Icons.train;
      case PlaceType.shopping:
        return Icons.shopping_bag;
      case PlaceType.hospital:
        return Icons.local_hospital;
      case PlaceType.education:
        return Icons.school;
      case PlaceType.home:
        return Icons.home;
      case PlaceType.work:
        return Icons.work;
      case PlaceType.other:
      default:
        return Icons.location_on;
    }
  }
} 