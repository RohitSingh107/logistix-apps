import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onCameraMove;
  final List<Marker>? markers;
  final bool showUserLocation;
  final bool showCenterMarker;
  final Widget? floatingActionButton;
  final Function()? onMapReady;

  const MapWidget({
    Key? key,
    required this.initialPosition,
    this.initialZoom = 15.0,
    this.onTap,
    this.onCameraMove,
    this.markers,
    this.showUserLocation = true,
    this.showCenterMarker = false,
    this.floatingActionButton,
    this.onMapReady,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng? _currentLocation;
  late AnimationController _locationButtonController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        _animateToLocation(_currentLocation!);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
      _locationButtonController.stop();
      _locationButtonController.reset();
    }
  }

  void _animateToLocation(LatLng location) {
    _mapController.move(location, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialPosition,
              initialZoom: widget.initialZoom,
              onTap: widget.onTap != null 
                ? (tapPosition, point) => widget.onTap!(point)
                : null,
              onPositionChanged: (position, hasGesture) {
                if (widget.onCameraMove != null && hasGesture) {
                  final center = position.center;
                  if (center != null) {
                    widget.onCameraMove!(center);
                  }
                }
              },
              minZoom: 5.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.logistix_main',
                subdomains: const ['a', 'b', 'c'],
                maxZoom: 19,
              ),
              
              // User location marker
              if (_currentLocation != null && widget.showUserLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              // Custom markers
              if (widget.markers != null)
                MarkerLayer(markers: widget.markers!),
            ],
          ),
          
          // Center marker (Uber-style)
          if (widget.showCenterMarker)
            Center(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Icon(
                  Icons.location_pin,
                  size: 40,
                  color: theme.colorScheme.primary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          
          // Location button
          Positioned(
            right: 16,
            bottom: widget.floatingActionButton != null ? 100 : 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              child: RotationTransition(
                turns: _locationButtonController,
                child: Icon(
                  _currentLocation != null 
                    ? Icons.my_location 
                    : Icons.location_searching,
                  color: _isLoadingLocation 
                    ? Colors.blue 
                    : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  @override
  void dispose() {
    _locationButtonController.dispose();
    super.dispose();
  }
} 