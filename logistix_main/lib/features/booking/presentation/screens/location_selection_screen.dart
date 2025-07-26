/**
 * location_selection_screen.dart - Location Selection Interface
 * 
 * Purpose:
 * - Provides interactive map interface for selecting pickup and dropoff locations
 * - Handles location search, map interaction, and address selection
 * - Integrates with map services for geocoding and place suggestions
 * 
 * Key Logic:
 * - Interactive map with draggable markers for precise location selection
 * - Search functionality with autocomplete suggestions
 * - Current location detection and GPS integration
 * - Address validation and confirmation workflow
 * - Real-time reverse geocoding for selected coordinates
 * - Navigation between pickup and dropoff location selection
 * - Integration with booking flow for location data passing
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/map_widget.dart';
import '../widgets/search_results_widget.dart';
import '../../../../core/config/app_theme.dart';
import '../../data/services/location_service.dart';
import '../../../../core/services/map_service_interface.dart';
import 'dart:async';

class LocationSelectionScreen extends StatefulWidget {
  final String title;
  final MapLatLng? initialLocation;

  const LocationSelectionScreen({
    Key? key,
    required this.title,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocationService _locationService = LocationService();
  Timer? _debounceTimer;
  
  List<PlaceResult> _searchResults = [];
  List<PlaceResult> _recentSearches = [];
  List<SavedPlace> _savedPlaces = [];
  bool _isLoading = false;
  bool _showMap = false;
  MapLatLng? _selectedLocation;
  MapLatLng? _userLocation; // Add user location for search
  String _selectedAddress = '';
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {});
      }
    });
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load user location and set as default
    final defaultLocation = widget.initialLocation ?? await _locationService.getDefaultLocation();
    
    final recent = await _locationService.getRecentSearches();
    final saved = await _locationService.getSavedPlaces();
    
    setState(() {
      _selectedLocation = defaultLocation;
      _userLocation = defaultLocation;
      _recentSearches = recent;
      _savedPlaces = saved;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final results = await _locationService.searchPlaces(
        query,
        userLocation: _userLocation,
        radius: 50000, // 50km radius
      );
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        final location = MapLatLng(position.latitude, position.longitude);
        final address = await _locationService.getAddressFromLatLng(location);
        
        if (mounted) {
          Navigator.pop(context, {
            'location': location,
            'address': address,
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get current location. Please enable location services.'),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectLocation(PlaceResult place) async {
    await _locationService.addToRecentSearches(place);
    
    if (mounted) {
      Navigator.pop(context, {
        'location': place.location,
        'address': '${place.title}, ${place.subtitle}',
      });
    }
  }

  void _selectSavedPlace(SavedPlace place) {
    if (place.location != null) {
      setState(() {
        _selectedLocation = place.location;
        _selectedAddress = place.address;
      });
      
      Navigator.pop(context, {
        'location': place.location,
        'address': place.address,
      });
    }
  }

  void _showMapSelection() {
    setState(() {
      _showMap = true;
    });
  }

  void _hideMap() {
    setState(() {
      _showMap = false;
      _selectedLocation = null;
      _selectedAddress = '';
    });
  }

  void _onMapLocationSelected() {
    if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
      Navigator.pop(context, {
        'location': _selectedLocation,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showMap) {
      return _buildMapView();
    }
    
    return _buildSearchView();
  }

  Widget _buildSearchView() {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSearching = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Map (Full screen)
          if (_selectedLocation != null)
            MapWidget(
              initialPosition: _selectedLocation!,
              initialZoom: 16.0,
              onCameraMove: (MapLatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
                _getAddressFromLatLng(location);
              },
              showCenterMarker: true,
              showUserLocation: true,
              onMapReady: () {
                if (_selectedLocation != null) {
                  setState(() => _selectedLocation = null);
                }
              },
            ),
          
          // Top Section with Search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: isSearching ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ] : null,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with back button and title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                                                  Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        // Debug button for testing search functionality
                        if (kDebugMode)
                          IconButton(
                            icon: const Icon(Icons.bug_report),
                            onPressed: () async {
                              await _locationService.testSearchFunctionality();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Search test completed. Check debug logs.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Search Input
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search for a location',
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults.clear());
                                },
                              )
                            : null,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    
                    // Search Results Container
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: size.height * 0.6,
                      ),
                      child: SearchResultsWidget(
                        searchResults: _searchResults,
                        recentSearches: _recentSearches,
                        savedPlaces: _savedPlaces,
                        isLoading: _isLoading,
                        searchQuery: _searchController.text,
                        onResultSelected: _selectLocation,
                        onSavedPlaceSelected: _selectSavedPlace,
                        onClearRecent: () async {
                          setState(() => _recentSearches.clear());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Section
          if (!isSearching)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Address
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Location',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _selectedAddress.isEmpty 
                                        ? 'Move the map to select location' 
                                        : _selectedAddress,
                                      style: theme.textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _getCurrentLocation,
                                icon: const Icon(Icons.my_location, size: 20),
                                label: const Text('Current Location'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showMapSelection,
                                icon: const Icon(Icons.map_outlined, size: 20),
                                label: const Text('Select on Map'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _hideMap,
        ),
        title: const Text(
          'Select on Map',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map
          MapWidget(
            initialPosition: _selectedLocation ?? MapLatLng(13.0827, 80.2707),
            markers: const [],
            onTap: (location) async {
              final address = await _locationService.getAddressFromLatLng(location);
              setState(() {
                _selectedLocation = location;
                _selectedAddress = address;
              });
            },
            showUserLocation: true,
          ),
          
          // Center pin overlay
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Colors.red,
              ),
            ),
          ),
          
          // Address Display and Confirm Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedAddress.isNotEmpty) ...[
                    Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _selectedLocation != null ? _onMapLocationSelected : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromLatLng(MapLatLng location) async {
    final address = await _locationService.getAddressFromLatLng(location);
    setState(() {
      _selectedAddress = address;
    });
  }
} 