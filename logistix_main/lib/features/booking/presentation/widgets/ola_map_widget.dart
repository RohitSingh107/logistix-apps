/// ola_map_widget.dart - Optimized Uber-Style Interactive Map Widget
/// 
/// Purpose:
/// - Provides a smooth, lag-free Uber-like map experience
/// - Handles zoom, pan, location tracking, and smooth animations
/// - Implements real-time location updates and marker management
/// - Includes search functionality with dynamic markers
/// 
/// Key Features:
/// - Optimized performance with minimal state updates
/// - Pinch to zoom in/out with smooth animations
/// - Pan/drag to move around the map
/// - Real-time location tracking with GPS
/// - Smooth camera animations between locations
/// - Dynamic marker positioning and updates
/// - Uber-style location button with GPS access
/// - Interactive tap detection for location selection
/// - Real-time address updates as you move
/// - Search functionality with location markers
/// - Performance optimizations for smooth interactions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/services/map_service_factory.dart';
import '../../data/services/location_service.dart';
import 'dart:math' as math;
import 'dart:async';

class OlaMapWidget extends StatefulWidget {
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

  const OlaMapWidget({
    Key? key,
    required this.initialPosition,
    this.initialZoom = 17.0, // Optimal zoom for street detail without rate limitingR
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
  State<OlaMapWidget> createState() => _OlaMapWidgetState();
}

class _OlaMapWidgetState extends State<OlaMapWidget> with TickerProviderStateMixin {
  late AnimationController _locationButtonController;
  late AnimationController _zoomInController;
  late AnimationController _zoomOutController;
  late AnimationController _cameraAnimationController;
  
  final MapServiceInterface _mapService = MapServiceFactory.instance;
  final LocationService _locationService = LocationService();
  
  // Current map state
  MapLatLng _currentCenter = MapLatLng(13.0827, 80.2707);
  double _currentZoom = _defaultZoom;
  MapLatLng? _userLocation;
  
  // Gesture state
  bool _isDragging = false;
  bool _isZooming = false;
  Offset? _lastPanPosition;
  double? _lastZoomLevel;
  
  // Animation state
  bool _isLoadingLocation = false;
  bool _isMapReady = false;
  bool _isAnimating = false;
  final bool _isMapLoading = false;
  
  // Search state
  String _searchQuery = '';
  List<MapLatLng> _searchResults = [];
  List<String> _searchResultNames = [];
  bool _isSearching = false;
  
  // Performance optimizations
  Timer? _debounceTimer;
  Timer? _cameraMoveTimer;
  
  // Search controller
  late TextEditingController _searchController;
  
  // Zoom constraints - Uber-style defaults
  static const double _minZoom = 5.0;
  static const double _maxZoom = 18.0; // Reduced to avoid rate limiting
  static const double _zoomStep = 1.0;
  static const double _defaultZoom = 17.0; // Optimal zoom for street detail without rate limiting

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition;
    _currentZoom = widget.initialZoom.clamp(_minZoom, _maxZoom);
    _searchController = TextEditingController();
    
    _locationButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _zoomInController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _zoomOutController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cameraAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isMapReady = true);
      widget.onMapReady?.call();
      if (widget.showUserLocation) {
        _getCurrentLocation();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;
    
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
        
        final newLocation = MapLatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = newLocation;
        });
        
        _animateToLocation(newLocation);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
      _locationButtonController.stop();
      _locationButtonController.reset();
    }
  }

  void _animateToLocation(MapLatLng location) {
    if (_isAnimating) return;
    
    setState(() => _isAnimating = true);
    
    _cameraAnimationController.forward().then((_) {
      setState(() {
        _currentCenter = location;
        _isAnimating = false;
      });
      _cameraAnimationController.reset();
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _isDragging = true;
      _isZooming = true;
      _lastPanPosition = details.localFocalPoint;
      _lastZoomLevel = _currentZoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!_isMapReady || _isAnimating) return;
    
    bool hasChanges = false;
    MapLatLng newCenter = _currentCenter;
    double newZoom = _currentZoom;
    
    // Handle zooming
    if (details.scale != 1.0) {
      newZoom = (_lastZoomLevel! * details.scale).clamp(_minZoom, _maxZoom);
      hasChanges = true;
    }
    
    // Handle panning
    if (details.focalPointDelta != Offset.zero) {
      final delta = details.focalPointDelta;
      _lastPanPosition = details.localFocalPoint;
      
      // Calculate new center based on pan delta
      final screenSize = MediaQuery.of(context).size;
      final zoomFactor = math.pow(2, _currentZoom);
      final metersPerPixel = 156543.03392 * math.cos(_currentCenter.lat * math.pi / 180) / zoomFactor;
      
      final deltaLat = -delta.dy * metersPerPixel / 111319.5;
      final deltaLng = delta.dx * metersPerPixel / (111319.5 * math.cos(_currentCenter.lat * math.pi / 180));
      
      newCenter = MapLatLng(
        _currentCenter.lat + deltaLat,
        _currentCenter.lng + deltaLng,
      );
      hasChanges = true;
    }
    
    // Only update state if there are actual changes
    if (hasChanges) {
      setState(() {
        _currentCenter = newCenter;
        _currentZoom = newZoom;
      });
      
          // Debounce camera move callbacks with longer delay to reduce API calls
    _cameraMoveTimer?.cancel();
    _cameraMoveTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onCameraMove?.call(_currentCenter);
    });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _isDragging = false;
      _isZooming = false;
      _lastPanPosition = null;
      _lastZoomLevel = null;
    });
  }

  void _handleTap(Offset localPosition) {
    if (!_isMapReady || _isDragging || _isZooming) return;
    
    // Convert screen tap to lat/lng coordinates
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    // Calculate offset from center
    final deltaX = localPosition.dx - centerX;
    final deltaY = localPosition.dy - centerY;
    
    // Convert pixels to lat/lng based on zoom level
    final zoomFactor = math.pow(2, _currentZoom);
    final metersPerPixel = 156543.03392 * math.cos(_currentCenter.lat * math.pi / 180) / zoomFactor;
    
    final deltaLat = -deltaY * metersPerPixel / 111319.5;
    final deltaLng = deltaX * metersPerPixel / (111319.5 * math.cos(_currentCenter.lat * math.pi / 180));
    
    final tappedLocation = MapLatLng(
      _currentCenter.lat + deltaLat,
      _currentCenter.lng + deltaLng,
    );
    
    widget.onTap?.call(tappedLocation);
    HapticFeedback.selectionClick();
  }

  void _zoomIn() {
    if (_isAnimating) return;
    
    final newZoom = (_currentZoom + _zoomStep).clamp(_minZoom, _maxZoom);
    if (newZoom != _currentZoom) {
      _zoomInController.forward().then((_) {
        setState(() => _currentZoom = newZoom);
        _zoomInController.reset();
        widget.onCameraMove?.call(_currentCenter);
      });
    }
  }

  void _zoomOut() {
    if (_isAnimating) return;
    
    final newZoom = (_currentZoom - _zoomStep).clamp(_minZoom, _maxZoom);
    if (newZoom != _currentZoom) {
      _zoomOutController.forward().then((_) {
        setState(() => _currentZoom = newZoom);
        _zoomOutController.reset();
        widget.onCameraMove?.call(_currentCenter);
      });
    }
  }

  void _onSearchChanged(String query) async {
    _searchQuery = query;
    
    // Debounce search
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (query.isEmpty) {
        // Show recent searches and saved places when query is empty
        try {
          final recentSearches = await _locationService.getRecentSearches();
          final savedPlaces = await _locationService.getSavedPlaces();
          
          List<MapLatLng> allResults = [];
          List<String> allNames = [];
          
          // Add saved places first (Home, Work)
          for (final savedPlace in savedPlaces) {
            if (savedPlace.location != null) {
              allResults.add(savedPlace.location!);
              allNames.add('${savedPlace.name} (Saved)');
            }
          }
          
          // Add recent searches
          for (final recentPlace in recentSearches) {
            allResults.add(recentPlace.location);
            allNames.add('${recentPlace.title} (Recent)');
          }
          
          if (mounted) {
            setState(() {
              _searchResults = allResults;
              _searchResultNames = allNames;
              _isSearching = false;
            });
          }
        } catch (e) {
          setState(() {
            _searchResults.clear();
            _searchResultNames.clear();
            _isSearching = false;
          });
        }
        return;
      }
      
      setState(() => _isSearching = true);
      
      try {
        // Use the new unified search method for better results
        final searchResults = await _locationService.unifiedSearch(
          query,
          userLocation: _currentCenter,
          radius: 25000, // Reduced radius for better results
        );
        
        if (mounted) {
          setState(() {
            _searchResults = searchResults.map((place) => place.location).toList();
            _searchResultNames = searchResults.map((place) {
              // Calculate distance for display
              final distance = _calculateDistance(_currentCenter.lat, _currentCenter.lng, place.location.lat, place.location.lng);
              return '${place.title} (${distance.toStringAsFixed(1)} km)';
            }).toList();
            _isSearching = false;
          });
        }
      } catch (e) {
        debugPrint('API Search error: $e');
        setState(() => _isSearching = false);
      }
    });
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
               math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
               math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  void _selectSearchResult(MapLatLng location) async {
    // Find the selected place from search results
    final selectedIndex = _searchResults.indexOf(location);
    if (selectedIndex != -1 && selectedIndex < _searchResultNames.length) {
      final placeName = _searchResultNames[selectedIndex].split(' (')[0]; // Remove distance part
      
      // Create a PlaceResult for recent searches
      final selectedPlace = PlaceResult(
        id: 'search_${DateTime.now().millisecondsSinceEpoch}',
        title: placeName,
        subtitle: 'Selected from search',
        location: location,
        placeType: PlaceType.other,
      );
      
      // Add to recent searches
      await _locationService.addToRecentSearches(selectedPlace);
    }
    
    setState(() {
      _currentCenter = location;
      _searchResults.clear();
      _searchResultNames.clear();
      _searchQuery = '';
      _searchController.clear();
    });
    
    // Animate to the selected location
    _animateToLocation(location);
    widget.onCameraMove?.call(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Interactive Map with Gesture Detection
          GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            onTap: () {
              // Handle tap at center of screen
              final screenSize = MediaQuery.of(context).size;
              final centerPosition = Offset(screenSize.width / 2, screenSize.height / 2);
              _handleTap(centerPosition);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
              child: _buildInteractiveMap(),
            ),
          ),
          
          // Search Bar
          if (widget.enableSearch)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
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
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search with real APIs - any location worldwide...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (_isSearching)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_searchQuery.isNotEmpty && !_isSearching)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchResults.clear();
                            _searchResultNames.clear();
                            _searchController.clear();
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          
          // Search Results
          if (widget.enableSearch && _searchResults.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            'SEARCH RESULTS',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchResults.clear();
                                  _searchResultNames.clear();
                                  _searchController.clear();
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Results List
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          final locationName = index < _searchResultNames.length 
                              ? _searchResultNames[index] 
                              : 'Location ${index + 1}';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              locationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Tap to select this location',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Center marker if enabled
          if (widget.showCenterMarker)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          
          // User location marker
          if (widget.showUserLocation && _userLocation != null)
            _buildUserLocationMarker(),
          
          // Custom markers
          if (widget.markers != null)
            ...widget.markers!.map((marker) => _buildCustomMarker(marker)),
          
          // Search result markers
          ..._searchResults.map((result) => _buildSearchResultMarker(result)),
          
          // Zoom Controls (Uber-style)
          Positioned(
            right: 16,
            top: widget.enableSearch ? 100 : 100,
            child: Column(
              children: [
                // Zoom In Button
                Container(
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
                      onTap: _zoomIn,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.add,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom Out Button
                Container(
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
                      onTap: _zoomOut,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.remove,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Location Button (Uber-style)
          if (widget.showUserLocation)
            Positioned(
              right: 16,
              bottom: 100,
              child: Container(
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
                    onTap: _isLoadingLocation ? null : _getCurrentLocation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _isLoadingLocation
                          ? RotationTransition(
                              turns: _locationButtonController,
                              child: const Icon(Icons.refresh, size: 18),
                            )
                          : const Icon(Icons.my_location, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          
          // Custom floating action button
          if (widget.floatingActionButton != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: widget.floatingActionButton!,
            ),
          
          // Map Info Overlay (Uber-style) - Removed coordinates display
          // Positioned(
          //   top: widget.enableSearch ? 80 : 40,
          //   left: 16,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.7),
          //       borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //         Icons.location_on,
          //         color: Colors.white,
          //         size: 16,
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         '${_currentCenter.lat.toStringAsFixed(4)}, ${_currentCenter.lng.toStringAsFixed(4)}',
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontSize: 12,
          //           fontFamily: 'monospace',
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
    final zoom = _currentZoom.clamp(1, 18).floor();
    final lat = _currentCenter.lat;
    final lng = _currentCenter.lng;
    
    // Get screen dimensions for optimal image size
    final screenSize = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = (screenSize.width * devicePixelRatio).toInt().clamp(256, 2048);
    final height = (screenSize.height * devicePixelRatio).toInt().clamp(256, 2048);
    
    // Use Ola Maps Static Tiles API with rate limiting protection
    final olaTileUrl = 'https://api.olamaps.io/tiles/v1/styles/default-light-standard/static/$lng,$lat,$zoom/${width}x$height.png?api_key=YGZHUWNx9FCMEw8K8OzqTW7WGZMp4DSQ8Upv6xdM';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: CachedNetworkImage(
        imageUrl: olaTileUrl,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Loading Map...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Ola Maps static tile failed: $error');
          // If rate limited (429), use OpenStreetMap tiles
          if (error.toString().contains('429')) {
            debugPrint('Rate limited by Ola Maps, using OpenStreetMap fallback');
          }
          return _buildOpenStreetMapTiles();
        },
        httpHeaders: const {
          'User-Agent': 'LogistixApp/1.0',
          'Accept': 'image/*',
        },
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.my_location,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMarker(OlaMapMarker marker) {
    // Calculate marker position based on its coordinates relative to center
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    // Convert marker coordinates to screen position
    final zoomFactor = math.pow(2, _currentZoom);
    final metersPerPixel = 156543.03392 * math.cos(_currentCenter.lat * math.pi / 180) / zoomFactor;
    
    final deltaLat = marker.point.lat - _currentCenter.lat;
    final deltaLng = marker.point.lng - _currentCenter.lng;
    
    final deltaX = deltaLng * 111319.5 * math.cos(_currentCenter.lat * math.pi / 180) / metersPerPixel;
    final deltaY = -deltaLat * 111319.5 / metersPerPixel;
    
    final screenX = centerX + deltaX;
    final screenY = centerY + deltaY;
    
    return Positioned(
      left: screenX - marker.width / 2,
      top: screenY - marker.height / 2,
      child: marker.child,
    );
  }

  Widget _buildSearchResultMarker(MapLatLng location) {
    // Calculate marker position based on its coordinates relative to center
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    // Convert marker coordinates to screen position
    final zoomFactor = math.pow(2, _currentZoom);
    final metersPerPixel = 156543.03392 * math.cos(_currentCenter.lat * math.pi / 180) / zoomFactor;
    
    final deltaLat = location.lat - _currentCenter.lat;
    final deltaLng = location.lng - _currentCenter.lng;
    
    final deltaX = deltaLng * 111319.5 * math.cos(_currentCenter.lat * math.pi / 180) / metersPerPixel;
    final deltaY = -deltaLat * 111319.5 / metersPerPixel;
    
    final screenX = centerX + deltaX;
    final screenY = centerY + deltaY;
    
    return Positioned(
      left: screenX - 20,
      top: screenY - 20,
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
            Icons.search,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOpenStreetMapTiles() {
    // Fallback to OpenStreetMap tile grid
    final zoom = _currentZoom.clamp(1, 18).floor();
    final lat = _currentCenter.lat;
    final lng = _currentCenter.lng;
    
    // Calculate tile coordinates for center
    final centerTileX = ((lng + 180.0) / 360.0 * math.pow(2, zoom)).floor();
    final centerTileY = ((1.0 - math.log(math.tan(lat * math.pi / 180.0) + 1.0 / math.cos(lat * math.pi / 180.0)) / math.pi) / 2.0 * math.pow(2, zoom)).floor();
    
    // Build a 3x3 grid for better performance as fallback
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemCount: 9, // 3x3 grid
      itemBuilder: (context, index) {
        final row = index ~/ 3 - 1; // -1, 0, 1
        final col = index % 3 - 1;  // -1, 0, 1
        
        final x = centerTileX + col;
        final y = centerTileY + row;
        
        // Ensure valid tile coordinates
        if (x < 0 || y < 0 || x >= math.pow(2, zoom) || y >= math.pow(2, zoom)) {
          return Container(color: Colors.blue[50]);
        }
        
        return _buildOSMTileImage(x, y, zoom);
      },
    );
  }

  Widget _buildOSMTileImage(int x, int y, int z) {
    final osmTileUrl = 'https://tile.openstreetmap.org/$z/$x/$y.png';
    
    return CachedNetworkImage(
      imageUrl: osmTileUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.blue[50],
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.terrain, size: 12, color: Colors.grey),
        ),
      ),
      httpHeaders: const {
        'User-Agent': 'LogistixApp/1.0',
      },
    );
  }

  @override
  void dispose() {
    _locationButtonController.dispose();
    _zoomInController.dispose();
    _zoomOutController.dispose();
    _cameraAnimationController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _cameraMoveTimer?.cancel();
    super.dispose();
  }
}

// Marker class for the map
class OlaMapMarker {
  final MapLatLng point;
  final double width;
  final double height;
  final Widget child;

  OlaMapMarker({
    required this.point,
    required this.width,
    required this.height,
    required this.child,
  });
} 