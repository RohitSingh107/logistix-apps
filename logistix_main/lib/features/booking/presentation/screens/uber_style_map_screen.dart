/**
 * uber_style_map_screen.dart - Uber-Style Map Screen
 * 
 * Purpose:
 * - Demonstrates all Uber-like map features in a comprehensive screen
 * - Shows zoom in/out, pan, location tracking, and real-time updates
 * - Provides a complete Uber-like map experience
 * 
 * Key Features:
 * - Interactive map with pinch-to-zoom and pan gestures
 * - Real-time location tracking with GPS
 * - Smooth camera animations between locations
 * - Dynamic marker positioning and updates
 * - Uber-style location button with GPS access
 * - Interactive tap detection for location selection
 * - Real-time address updates as you move
 * - Zoom controls (+ and - buttons)
 * - Location info overlay
 * - Performance optimizations for smooth interactions
 */

import 'package:flutter/material.dart';
import '../../../../core/services/map_service_interface.dart';
import '../widgets/map_widget.dart';
import '../../data/services/location_service.dart';
import 'dart:async';

class UberStyleMapScreen extends StatefulWidget {
  final String title;
  final MapLatLng? initialLocation;
  final Function(MapLatLng, String)? onLocationSelected;

  const UberStyleMapScreen({
    Key? key,
    this.title = 'Select Location',
    this.initialLocation,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<UberStyleMapScreen> createState() => _UberStyleMapScreenState();
}

class _UberStyleMapScreenState extends State<UberStyleMapScreen> {
  final LocationService _locationService = LocationService();
  
  MapLatLng? _selectedLocation;
  MapLatLng? _userLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _showAddressCard = false;
  
  Timer? _addressUpdateTimer;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _loadInitialData();
  }

  @override
  void dispose() {
    _addressUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get user's current location
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = MapLatLng(position.latitude, position.longitude);
          if (_selectedLocation == null) {
            _selectedLocation = _userLocation;
          }
        });
        
        // Get initial address
        await _updateAddress(_selectedLocation!);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress(MapLatLng location) async {
    try {
      final address = await _locationService.getAddressFromLatLng(location);
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _showAddressCard = true;
        });
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
    }
  }

  void _onMapTap(MapLatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    
    // Debounce address updates
    _addressUpdateTimer?.cancel();
    _addressUpdateTimer = Timer(const Duration(milliseconds: 500), () {
      _updateAddress(location);
    });
  }

  void _onCameraMove(MapLatLng location) {
    // Update location as user moves the map
    setState(() {
      _selectedLocation = location;
    });
    
    // Debounce address updates during camera movement
    _addressUpdateTimer?.cancel();
    _addressUpdateTimer = Timer(const Duration(milliseconds: 1000), () {
      _updateAddress(location);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final location = MapLatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = location;
          _selectedLocation = location;
        });
        
        await _updateAddress(location);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location. Please enable location services.'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
      widget.onLocationSelected?.call(_selectedLocation!, _selectedAddress);
      Navigator.pop(context, {
        'location': _selectedLocation,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map
          MapWidget(
            initialPosition: _selectedLocation ?? MapLatLng(13.0827, 80.2707),
            initialZoom: 17.0, // Optimal zoom for street detail without rate limiting
            onTap: _onMapTap,
            onCameraMove: _onCameraMove,
            showUserLocation: true,
            showCenterMarker: true,
            floatingActionButton: _buildCustomFAB(),
          ),
          
          // Address Card (Uber-style)
          if (_showAddressCard && _selectedAddress.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selected Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _getCurrentLocation,
          child: Container(
            width: 40,
            height: 40,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.my_location,
                    color: Colors.black87,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
} 