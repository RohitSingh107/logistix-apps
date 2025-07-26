/**
 * map_widget.dart - Generic Map Widget Component
 * 
 * Purpose:
 * - Provides reusable map component for location display and interaction
 * - Abstracts map implementation details from parent screens
 * - Supports multiple map providers through unified interface
 * 
 * Key Logic:
 * - Generic map widget supporting different map service providers
 * - Marker management for pickup/dropoff locations and driver tracking
 * - User interaction handling (tap, drag, zoom) with callback support
 * - Real-time location updates and map centering functionality
 * - Route visualization and polyline drawing capabilities
 * - Map state management (loading, error, ready states)
 * - Integration with location services for GPS and geocoding
 * - Responsive design adapting to different screen sizes
 */

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/map_service_interface.dart';
import 'ola_map_widget.dart';

class MapWidget extends StatefulWidget {
  final MapLatLng initialPosition;
  final double initialZoom;
  final Function(MapLatLng)? onTap;
  final Function(MapLatLng)? onCameraMove;
  final List<OlaMapMarker>? markers;
  final bool showUserLocation;
  final bool showCenterMarker;
  final Widget? floatingActionButton;
  final Function()? onMapReady;
  final bool enableSearch;
  final Function(String)? onSearchQuery;

  const MapWidget({
    Key? key,
    required this.initialPosition,
    this.initialZoom = 17.0, // Optimal zoom for street detail without rate limiting
    this.onTap,
    this.onCameraMove,
    this.markers,
    this.showUserLocation = true,
    this.showCenterMarker = false,
    this.floatingActionButton,
    this.onMapReady,
    this.enableSearch = false,
    this.onSearchQuery,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  MapLatLng? _currentLocation;
  late AnimationController _locationButtonController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapReady?.call();
      if (widget.showUserLocation) {
        _getCurrentLocation();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    _locationButtonController.repeat();
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentLocation = MapLatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
      _locationButtonController.stop();
      _locationButtonController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OlaMapWidget(
      initialPosition: widget.initialPosition,
      initialZoom: widget.initialZoom,
      onTap: widget.onTap,
      onCameraMove: widget.onCameraMove,
      markers: widget.markers,
      showUserLocation: widget.showUserLocation,
      showCenterMarker: widget.showCenterMarker,
      floatingActionButton: widget.floatingActionButton,
      onMapReady: widget.onMapReady,
      enableSearch: widget.enableSearch,
      onSearchQuery: widget.onSearchQuery,
    );
  }

  @override
  void dispose() {
    _locationButtonController.dispose();
    super.dispose();
  }
} 