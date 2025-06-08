import 'package:flutter/material.dart';
import '../../data/services/location_service.dart';
import '../widgets/map_widget.dart';
import '../../../../core/services/map_service_interface.dart';
import 'dart:async';

class SimpleLocationSelectionScreen extends StatefulWidget {
  final String title;
  final MapLatLng? initialLocation;

  const SimpleLocationSelectionScreen({
    Key? key,
    required this.title,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<SimpleLocationSelectionScreen> createState() => _SimpleLocationSelectionScreenState();
}

class _SimpleLocationSelectionScreenState extends State<SimpleLocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  
  List<PlaceResult> _searchResults = [];
  List<PlaceResult> _recentSearches = [];
  bool _isLoading = false;
  bool _showMap = false;
  MapLatLng? _selectedLocation;
  MapLatLng? _userLocation; // Add user location for search
  String _selectedAddress = '';
  
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Load user location and set as default
    final defaultLocation = widget.initialLocation ?? await _locationService.getDefaultLocation();
    
    final recent = await _locationService.getRecentSearches();
    
    setState(() {
      _userLocation = defaultLocation;
      _selectedLocation = defaultLocation;
      _recentSearches = recent;
    });
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

  void _showMapSelection() {
    setState(() {
      _showMap = true;
      _selectedLocation = _userLocation ?? MapLatLng(13.0827, 80.2707);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons Row
                Row(
                  children: [
                    // Current Location Button
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
                    // Select on Map Button
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
          
          // Results Area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Search Results
                      if (_searchResults.isNotEmpty) ...[
                        _buildSectionHeader('Search Results'),
                        ..._searchResults.map((place) => _buildPlaceItem(place)),
                        const SizedBox(height: 16),
                      ],
                      
                      // Recent Searches
                      if (_recentSearches.isNotEmpty && _searchResults.isEmpty) ...[
                        _buildSectionHeader('Recent'),
                        ..._recentSearches.map((place) => _buildPlaceItem(place)),
                      ],
                    ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPlaceItem(PlaceResult place) {
    IconData icon = Icons.location_on;
    Color iconColor = Colors.grey[600]!;
    
    switch (place.placeType) {
      case PlaceType.airport:
        icon = Icons.flight;
        iconColor = Colors.blue;
        break;
      case PlaceType.station:
        icon = Icons.train;
        iconColor = Colors.orange;
        break;
      case PlaceType.shopping:
        icon = Icons.shopping_bag;
        iconColor = Colors.purple;
        break;
      case PlaceType.hospital:
        icon = Icons.local_hospital;
        iconColor = Colors.red;
        break;
      case PlaceType.education:
        icon = Icons.school;
        iconColor = Colors.green;
        break;
      default:
        break;
    }
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        place.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        place.subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => _selectLocation(place),
    );
  }
} 