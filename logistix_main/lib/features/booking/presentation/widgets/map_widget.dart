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
    );
  }

  @override
  void dispose() {
    _locationButtonController.dispose();
    super.dispose();
  }
} 