# OpenStreetMap Integration Guide

## Overview

This guide explains how the OpenStreetMap (OSM) integration works in the Logistix app and how to use it effectively.

## Architecture

The map functionality is organized in the `booking` feature module with the following structure:

```
lib/features/booking/
├── presentation/
│   ├── screens/
│   │   ├── booking_screen.dart         # Main booking screen with map
│   │   └── location_selection_screen.dart  # Location picker screen
│   └── widgets/
│       └── map_widget.dart             # Reusable map component
```

## Key Components

### 1. MapWidget (`map_widget.dart`)

A reusable Flutter widget that wraps the `flutter_map` package:

**Features:**
- Displays OpenStreetMap tiles
- Supports custom markers
- Handles tap events for location selection
- Configurable initial position and zoom level

**Usage:**
```dart
MapWidget(
  initialPosition: LatLng(13.0827, 80.2707),
  initialZoom: 15.0,
  onTap: (location) => print('Tapped at: $location'),
  markers: [
    Marker(
      point: LatLng(13.0827, 80.2707),
      child: Icon(Icons.location_pin, color: Colors.red),
    ),
  ],
)
```

### 2. LocationSelectionScreen (`location_selection_screen.dart`)

A full-screen location picker with search functionality:

**Features:**
- Search locations by address
- Tap on map to select location
- Shows selected address
- Gets user's current location (with permission)
- Different UI for pickup vs drop selection

**Usage:**
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LocationSelectionScreen(
      isPickup: true,
      initialLocation: LatLng(13.0827, 80.2707),
    ),
  ),
);

if (result != null) {
  print('Selected location: ${result['location']}');
  print('Address: ${result['address']}');
}
```

### 3. BookingScreen (`booking_screen.dart`)

The main booking interface that combines all map features:

**Features:**
- Separate pickup and drop location selection
- Shows both locations on map with different colored markers
- Calculates distance, estimated time, and fare
- Displays route information
- Confirm booking action

## How It Works

### User Flow

1. **From Home Screen:**
   - User taps "Where to?" search bar
   - Or taps on vehicle category cards
   - Or taps on quick action cards

2. **In Booking Screen:**
   - User sees two location cards: Pickup and Drop
   - Tapping either card opens the location selection screen
   - Selected locations appear on the map with markers
   - Distance, time, and fare estimates are shown

3. **Location Selection:**
   - User can search for an address
   - Or tap directly on the map
   - Or use current location
   - Confirm selection to return to booking screen

### Technical Implementation

**Dependencies Used:**
- `flutter_map`: OSM map rendering
- `latlong2`: Coordinate handling
- `geolocator`: GPS location access
- `geocoding`: Convert coordinates to addresses
- `flutter_map_marker_popup`: Marker interactions

**Key Functions:**

1. **Getting Current Location:**
```dart
Position position = await Geolocator.getCurrentPosition();
LatLng currentLocation = LatLng(position.latitude, position.longitude);
```

2. **Converting Coordinates to Address:**
```dart
List<Placemark> placemarks = await placemarkFromCoordinates(
  location.latitude,
  location.longitude,
);
String address = '${placemarks[0].street}, ${placemarks[0].locality}';
```

3. **Calculating Distance:**
```dart
final Distance distance = Distance();
double km = distance.as(
  LengthUnit.Kilometer,
  pickupLocation,
  dropLocation,
);
```

## Customization

### Change Map Style

To use a different tile provider, modify the `TileLayer` in `map_widget.dart`:

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  // Change to other providers like:
  // 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png'
  // 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png'
)
```

### Customize Markers

Modify marker appearance in `booking_screen.dart`:

```dart
Marker(
  width: 80.0,
  height: 80.0,
  point: location,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.green,
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.local_taxi, color: Colors.white),
  ),
)
```

### Adjust Fare Calculation

Edit the `_estimateFare()` method in `booking_screen.dart`:

```dart
int _estimateFare() {
  final double km = double.parse(_calculateDistance());
  // Customize your fare logic here
  int baseFare = 40;
  int perKmRate = 15;
  return (baseFare + (km * perKmRate)).round();
}
```

## Permissions

### Android
Permissions are automatically requested when needed. Configured in `AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `INTERNET`

### iOS
Permissions are configured in `Info.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`

## Testing

To test the map functionality:

1. **On Emulator/Simulator:**
   - Use the location controls to set GPS coordinates
   - Default location is set to Chennai (13.0827, 80.2707)

2. **On Physical Device:**
   - Ensure GPS is enabled
   - Grant location permissions when prompted

## Troubleshooting

### Map Not Loading
- Check internet connection
- Verify OSM tile server is accessible
- Check if API limits are reached

### Location Permission Denied
- The app will use default location (Chennai)
- User can still select location manually

### Search Not Working
- Geocoding service might be temporarily unavailable
- Try tapping directly on the map instead

## Future Enhancements

Potential improvements you can add:

1. **Route Visualization:**
   - Draw polylines between pickup and drop
   - Show turn-by-turn directions

2. **Live Tracking:**
   - Real-time driver location updates
   - ETA updates during ride

3. **Multiple Stops:**
   - Add waypoints between pickup and drop
   - Optimize route for multiple destinations

4. **Offline Maps:**
   - Cache map tiles for offline use
   - Store frequently used areas

5. **Custom Map Themes:**
   - Dark mode map tiles
   - Custom styling for brand consistency

## API Reference

### MapWidget Properties
- `initialPosition` (LatLng, required): Starting map center
- `initialZoom` (double): Initial zoom level (default: 13.0)
- `onTap` (Function(LatLng)?): Callback for map taps
- `markers` (List<Marker>?): Map markers to display
- `showUserLocation` (bool): Show current location marker
- `floatingActionButton` (Widget?): Custom FAB widget

### LocationSelectionScreen Properties
- `isPickup` (bool): Whether selecting pickup location
- `initialLocation` (LatLng?): Pre-selected location

### BookingScreen
No parameters - manages its own state internally

## Support

For issues or questions:
1. Check the Flutter logs for error messages
2. Ensure all dependencies are properly installed
3. Verify platform-specific configurations
4. Test with different network conditions 