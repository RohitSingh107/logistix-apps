import 'package:flutter/material.dart';
import '../../../../core/services/map_service_factory.dart';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/services/test_map_service.dart';

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({Key? key}) : super(key: key);

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  late MapServiceInterface _mapService;
  bool _isLoading = false;
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _mapService = MapServiceFactory.instance;
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🧪 Starting Map Service Tests...');
    
    // Test 1: Configuration
    _addResult('Provider: ${_mapService.providerName}');
    _addResult('Configured: ${_mapService.isConfigured}');
    
    if (!_mapService.isConfigured) {
      _addResult('❌ Service not configured properly!');
      setState(() => _isLoading = false);
      return;
    }

    // Test 2: Geocoding
    try {
      _addResult('🔍 Testing geocoding...');
      final result = await _mapService.geocode('Chennai, India');
      if (result != null) {
        _addResult('✅ Geocoding: ${result.formattedAddress}');
        _addResult('📍 Location: ${result.location.lat}, ${result.location.lng}');
      } else {
        _addResult('⚠️ Geocoding returned null');
      }
    } catch (e) {
      _addResult('❌ Geocoding failed: $e');
    }

    // Test 3: Reverse Geocoding
    try {
      _addResult('🔄 Testing reverse geocoding...');
      final result = await _mapService.reverseGeocode(13.0827, 80.2707);
      if (result != null) {
        _addResult('✅ Reverse geocoding: ${result.formattedAddress}');
      } else {
        _addResult('⚠️ Reverse geocoding returned null');
      }
    } catch (e) {
      _addResult('❌ Reverse geocoding failed: $e');
    }

    // Test 4: Places Autocomplete
    try {
      _addResult('🔍 Testing autocomplete...');
      final results = await _mapService.placesAutocomplete('restaurant', lat: 13.0827, lng: 80.2707);
      _addResult('✅ Autocomplete: ${results.length} results');
      if (results.isNotEmpty) {
        _addResult('📋 First result: ${results.first.description}');
      }
    } catch (e) {
      _addResult('❌ Autocomplete failed: $e');
    }

    // Test 5: Tile URL
    try {
      final tileUrl = _mapService.getTileUrl(10, 512, 512);
      _addResult('✅ Tile URL generated successfully');
      _addResult('🗺️ URL: ${tileUrl.substring(0, 50)}...');
    } catch (e) {
      _addResult('❌ Tile URL failed: $e');
    }

    _addResult('🏁 Tests completed!');
    setState(() => _isLoading = false);
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Service Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runTests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Map Service Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _mapService.isConfigured ? Colors.green[50] : Colors.red[50],
                border: Border.all(
                  color: _mapService.isConfigured ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _mapService.isConfigured ? Icons.check_circle : Icons.error,
                    color: _mapService.isConfigured ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _mapService.isConfigured 
                        ? 'Service Configured ✅' 
                        : 'Service Not Configured ❌',
                    style: TextStyle(
                      color: _mapService.isConfigured ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final result = _testResults[index];
                    final isError = result.contains('❌');
                    final isSuccess = result.contains('✅');
                    final isWarning = result.contains('⚠️');
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: isError 
                              ? Colors.red[700]
                              : isSuccess 
                                  ? Colors.green[700]
                                  : isWarning
                                      ? Colors.orange[700]
                                      : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Running Tests...'),
                        ],
                      )
                    : const Text('Run Tests Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 