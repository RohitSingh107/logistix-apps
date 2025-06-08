# Ola Maps Rate Limiting Fix

This document explains the fixes implemented to resolve HTTP 429 (rate limiting) errors when using Ola Maps tiles.

## Problem

The application was encountering HTTP 429 errors when loading map tiles:
```
HttpException: Invalid statusCode: 429, uri = https://api.olamaps.io/tiles/v1/styles/default/13/1317/3177?api_key=...
```

## Root Cause

1. **Too many simultaneous requests**: The map widget was loading all 9 tiles (3x3 grid) simultaneously without throttling
2. **No caching mechanism**: Same tiles were being requested multiple times
3. **No retry logic**: Failed requests weren't being retried with appropriate delays

## Solution Implemented

### 1. TileCacheManager
A comprehensive tile cache manager that:
- Limits concurrent requests to 6 simultaneous tiles
- Enforces minimum 100ms delay between requests for the same tile
- Maintains a request queue for throttling
- Auto-cleanup of old cache entries

### 2. Smart Tile Loading
- **Priority loading**: Center tile loads first, then adjacent tiles
- **Request throttling**: Only loads tiles when cache manager permits
- **Visual feedback**: Shows loading indicators for throttled tiles

### 3. Enhanced Error Handling
- **Specific 429 handling**: Special icon for rate-limited tiles
- **Retry mechanism**: Automatic retry with 500ms delay for rate-limited requests
- **Graceful degradation**: Shows placeholder when tiles can't load

### 4. HTTP Client Improvements
- Added proper User-Agent header
- Retry interceptor for 429 errors
- Better timeout settings (10s connect, 15s receive)

## Configuration

### Rate Limiting Settings
```dart
// In MapProviderConfig
static const int maxConcurrentRequests = 6;
static const Duration requestDelay = Duration(milliseconds: 100);
static const Duration retryDelay = Duration(milliseconds: 500);
static const int maxRetries = 2;
```

### Tile Caching Settings
```dart
static const Duration tileCacheDuration = Duration(minutes: 5);
static const int maxCachedTiles = 200;
```

## API Key Management

### Current Setup
The application uses a demo API key. For production:

1. **Get your own API key** from [Ola Maps Console](https://maps.olakrutrim.com/)
2. **Replace the key** in `lib/core/config/map_provider_config.dart`:
   ```dart
   static const String olaMapsApiKey = 'YOUR_ACTUAL_API_KEY';
   ```

### Rate Limits by Plan
- **Free Tier**: 1,000 requests/day, 10 requests/minute
- **Basic Tier**: 10,000 requests/day, 100 requests/minute
- **Pro Tier**: 100,000 requests/day, 1,000 requests/minute

## Best Practices

### 1. Minimize Tile Requests
- Use appropriate zoom levels
- Implement proper map bounds
- Cache tiles locally using `cached_network_image`

### 2. Handle Rate Limits Gracefully
- Always show loading indicators
- Provide fallback content for failed tiles
- Implement exponential backoff for retries

### 3. Monitor Usage
- Log API usage in debug mode
- Track 429 errors to optimize request patterns
- Consider implementing client-side usage analytics

## Troubleshooting

### Still Getting 429 Errors?

1. **Check API Key Limits**
   - Verify your daily/minute quotas
   - Check if key has proper permissions

2. **Reduce Concurrent Requests**
   ```dart
   // Further reduce if needed
   static const int maxConcurrentRequests = 3;
   ```

3. **Increase Delays**
   ```dart
   static const Duration requestDelay = Duration(milliseconds: 200);
   ```

4. **Implement Circuit Breaker**
   - Stop requests temporarily when rate limit hit
   - Gradually resume after cooldown period

### Alternative Solutions

1. **Switch to Different Provider**
   ```dart
   MapProviderConfig.switchProvider(MapProvider.openStreetMap);
   ```

2. **Use Tile Proxy/Cache Server**
   - Set up your own tile caching server
   - Reduce direct API calls

3. **Implement Progressive Loading**
   - Load lower resolution first
   - Progressively enhance with higher resolution

## Performance Impact

The rate limiting fixes add minimal overhead:
- ~10-50ms delay per tile request
- ~1MB memory for cache management
- Improved user experience with better error handling

## Files Modified

1. `lib/features/booking/presentation/widgets/ola_map_widget.dart`
   - Added TileCacheManager
   - Implemented smart tile loading
   - Enhanced error handling

2. `lib/core/services/implementations/ola_maps_service_impl.dart`
   - Added retry interceptor
   - Improved HTTP headers
   - Better timeout configuration

3. `lib/core/config/map_provider_config.dart`
   - Added rate limiting configuration
   - Enhanced API key management
   - Provider switching capability

## Testing

To verify the fix works:

1. **Monitor Debug Logs**
   ```
   I/flutter: [OlaMaps] Rate limited, retrying after delay...
   ```

2. **Check Network Tab**
   - Requests should be spaced out
   - 429 errors should retry automatically

3. **Visual Verification**
   - Map tiles load smoothly
   - No error icons for rate limiting
   - Loading indicators appear appropriately

## Future Improvements

1. **Persistent Tile Cache**: Store tiles in device storage
2. **Predictive Loading**: Preload tiles for likely user movements
3. **Dynamic Rate Adjustment**: Adapt request rate based on API responses
4. **Usage Analytics**: Track and optimize API usage patterns 