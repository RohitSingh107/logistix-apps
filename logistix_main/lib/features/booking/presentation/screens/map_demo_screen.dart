/// map_demo_screen.dart - Map Features Demo Screen
/// 
/// Purpose:
/// - Demonstrates all Uber-like map features in an interactive demo
/// - Shows zoom in/out, pan, location tracking, and real-time updates
/// - Provides a comprehensive test environment for map functionality
/// 
/// Key Features Demonstrated:
/// - Interactive map with pinch-to-zoom and pan gestures
/// - Real-time location tracking with GPS
/// - Smooth camera animations between locations
/// - Dynamic marker positioning and updates
/// - Uber-style location button with GPS access
/// - Interactive tap detection for location selection
/// - Real-time address updates as you move
/// - Zoom controls (+ and - buttons)
/// - Location info overlay
/// - Performance optimizations for smooth interactions

import 'package:flutter/material.dart';
import '../../../../core/services/map_service_interface.dart';
import '../widgets/map_widget.dart';
import '../widgets/ola_map_widget.dart';
import '../../data/services/location_service.dart';
import 'dart:async';

class MapDemoScreen extends StatefulWidget {
  const MapDemoScreen({Key? key}) : super(key: key);

  @override
  State<MapDemoScreen> createState() => _MapDemoScreenState();
}

class _MapDemoScreenState extends State<MapDemoScreen> {
  final LocationService _locationService = LocationService();
  
  MapLatLng _currentCenter = MapLatLng(13.0827, 80.2707);
  final double _currentZoom = 17.0; // Optimal zoom for street detail without rate limiting
  MapLatLng? _userLocation;
  String _currentAddress = '';
  bool _isLoading = false;
  bool _showDebugInfo = true;
  
  // Demo markers
  List<OlaMapMarker> _demoMarkers = [];
  
  Timer? _addressUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _createDemoMarkers();
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
          _currentCenter = _userLocation!;
        });
        
        // Get initial address
        await _updateAddress(_currentCenter);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createDemoMarkers() {
    // Create some demo markers around Chennai
    final demoLocations = [
      MapLatLng(13.0827, 80.2707), // Chennai Center
      MapLatLng(13.0878, 80.2785), // Marina Beach
      MapLatLng(13.0604, 80.2494), // Chennai Airport
      MapLatLng(13.0827, 80.2707), // Central Station
    ];
    
    _demoMarkers = demoLocations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;
      
      return OlaMapMarker(
        point: location,
        width: 40,
        height: 40,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _updateAddress(MapLatLng location) async {
    try {
      final address = await _locationService.getAddressFromLatLng(location);
      if (mounted) {
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
    }
  }

  void _onMapTap(MapLatLng location) {
    setState(() {
      _currentCenter = location;
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
      _currentCenter = location;
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
          _currentCenter = location;
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

  void _toggleDebugInfo() {
    setState(() {
      _showDebugInfo = !_showDebugInfo;
    });
  }

  void _addDemoMarker() {
    setState(() {
      _demoMarkers.add(
        OlaMapMarker(
          point: _currentCenter,
          width: 40,
          height: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _clearMarkers() {
    setState(() {
      _demoMarkers.clear();
    });
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
        title: const Text(
          'Uber-Style Map Demo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showDebugInfo ? Icons.info : Icons.info_outline,
              color: Colors.black,
            ),
            onPressed: _toggleDebugInfo,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map
          MapWidget(
            initialPosition: _currentCenter,
            initialZoom: _currentZoom,
            onTap: _onMapTap,
            onCameraMove: _onCameraMove,
            markers: _demoMarkers,
            showUserLocation: true,
            showCenterMarker: true,
          ),
          
          // Feature Demo Panel
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.map,
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
                              'Uber-Style Map Features',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try: Pinch to zoom, drag to pan, tap to select',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (_currentAddress.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _currentAddress,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Demo Controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('GPS'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addDemoMarker,
                          icon: const Icon(Icons.add_location, size: 16),
                          label: const Text('Add Marker'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearMarkers,
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Debug Info (Uber-style)
          if (_showDebugInfo)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Debug Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zoom: ${_currentZoom.toStringAsFixed(1)}\n'
                      'Markers: ${_demoMarkers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
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
} 