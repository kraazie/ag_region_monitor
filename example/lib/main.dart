import 'package:flutter/material.dart';
import 'package:ag_region_monitor/ag_region_monitor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Region Monitor Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegionMonitorExample(),
    );
  }
}

class RegionMonitorExample extends StatefulWidget {
  const RegionMonitorExample({super.key});

  @override
  _RegionMonitorExampleState createState() => _RegionMonitorExampleState();
}

class _RegionMonitorExampleState extends State<RegionMonitorExample> {
  bool _isInitialized = false;
  String _lastEvent = 'No events yet';
  String _currentLocation = 'Unknown';
  List<Widget> _activeRegionCards = [];

  @override
  void initState() {
    super.initState();
    _initializePlugin();
    _listenToEvents();
  }

  Future<void> _initializePlugin() async {
    // Initialize the location manager
    bool initialized = await AgRegionMonitor.initialize();

    if (initialized) {
      // Request notification permission
      await AgRegionMonitor.requestNotificationPermission();

      // Setup the default Karachi danger zone
      await AgRegionMonitor.setupKarachiDangerZone();

      // Start monitoring
      await AgRegionMonitor.startMonitoring();

      // Get Active Regions
      _loadActiveRegionCards();

      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadActiveRegionCards() async {
    final cards = await displayActiveRegions(); // Calls your static method
    setState(() {
      _activeRegionCards = cards;
    });
  }

  void _listenToEvents() {
    // Listen for region events
    AgRegionMonitor.regionEvents.listen(
      (event) {
        debugPrint('Region event received: $event');
        setState(() {
          _lastEvent = '${event['event']} - ${event['identifier']}';
        });

        // Show snackbar for region events
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_lastEvent), backgroundColor: event['event'] == 'didEnterRegion' ? Colors.red : Colors.green));
        }
      },
      onError: (error) {
        debugPrint('Region events error: $error');
        setState(() {
          _lastEvent = 'Error: $error';
        });
      },
    );

    // Listen for location updates
    AgRegionMonitor.locationUpdates.listen(
      (location) {
        debugPrint('Location update received: $location');
        setState(() {
          _currentLocation =
              'Lat: ${location['latitude']?.toStringAsFixed(4) ?? 'N/A'}, '
              'Lng: ${location['longitude']?.toStringAsFixed(4) ?? 'N/A'}';
        });
      },
      onError: (error) {
        debugPrint('Location updates error: $error');
        setState(() {
          _currentLocation = 'Error: $error';
        });
      },
    );
  }

  Future<void> _addCustomRegion() async {
    // Example: Add a custom region around a specific location
    await AgRegionMonitor.setupGeofence(
      latitude: 24.8700, // Different location in Karachi
      longitude: 67.0300,
      radius: 150,
      identifier: 'CustomZone1',
      notifyOnEntry: true,
      notifyOnExit: true,
    );

    // Get active regions list again..!!
    _loadActiveRegionCards();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Custom region added!')));
  }

  // // Example: Get all active regions and display them
  // static Future<void> displayActiveRegions() async {
  //   try {
  //     final regions = await AgRegionMonitor.getActiveRegions();

  //     print('Active Regions Count: ${regions.length}');

  //     for (var region in regions) {
  //       print('Region ID: ${region['identifier']}');
  //       print('  Location: ${region['latitude']}, ${region['longitude']}');
  //       print('  Radius: ${region['radius']}m');
  //       print('  Notify on Entry: ${region['notifyOnEntry']}');
  //       print('  Notify on Exit: ${region['notifyOnExit']}');
  //       print('---');
  //     }
  //   } catch (e) {
  //     print('Error getting active regions: $e');
  //   }
  // }

  Future<List<Widget>> displayActiveRegions() async {
    List<Widget> cards = [];

    try {
      final regions = await AgRegionMonitor.getActiveRegions();

      for (var region in regions) {
        cards.add(
          Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Region ID: ${region['identifier']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Location: ${region['latitude']}, ${region['longitude']}'),
                  Text('Radius: ${region['radius']} m'),
                  Text('Notify on Entry: ${region['notifyOnEntry']}'),
                  Text('Notify on Exit: ${region['notifyOnExit']}'),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      cards.add(
        Card(
          color: Colors.red[100],
          child: Padding(padding: const EdgeInsets.all(12.0), child: Text('Error getting active regions: $e')),
        ),
      );
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Region Monitor Demo'), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Initialized: ${_isInitialized ? 'Yes' : 'No'}'),
                    Text('Current Location: $_currentLocation'),
                    Text('Last Event: $_lastEvent'),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 20),
            // Card(
            //   child: Padding(
            //     padding: EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text('Active Regions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            //         SizedBox(height: 8),
            //         Text('• Karachi Danger Zone (24.8615, 67.0099) - 200m radius'),
            //         Text('• Notify on Entry: Yes'),
            //         Text('• Notify on Exit: No'),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 20),
            Text('Active Regions:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var card in _activeRegionCards) card, // << your for-loop here
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: _addCustomRegion, child: Text('Add Custom Region')),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AgRegionMonitor.stopAllMonitoring();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All monitoring stopped')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Stop All'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
