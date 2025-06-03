# AgRegionMonitor Plugin

A Flutter plugin for iOS that provides geofencing and region monitoring capabilities using CoreLocation. This plugin allows you to monitor when users enter or exit specific geographic regions, with support for local notifications and real-time location updates.

## Features

- ✅ **Geofencing** - Monitor circular geographic regions
- ✅ **Background Monitoring** - Works when app is in background (with proper permissions)
- ✅ **Local Notifications** - Automatic notifications when entering/exiting regions
- ✅ **Real-time Location Updates** - Stream of location changes
- ✅ **Permission Management** - Handle location and notification permissions
- ✅ **Multiple Regions** - Monitor multiple geofences simultaneously
- ✅ **Customizable Notifications** - Configure entry/exit notifications per region

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅      |
| Android  | ❌ (Coming Soon) |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ag_region_monitor: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## iOS Setup

### 1. Add Permissions to Info.plist

Add these keys to your `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to monitor specific regions.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs background location access to monitor regions when the app is closed.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs always location access for geofencing.</string>
```

### 2. Enable Background Modes

In Xcode, select your target → Capabilities → Background Modes, and enable:
- ✅ Location updates
- ✅ Background processing

Or add to `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>background-processing</string>
</array>
```

## Quick Start

```dart
import 'package:ag_region_monitor/ag_region_monitor.dart';

class LocationService {
  static Future<void> initializeLocationMonitoring() async {
    // 1. Initialize the plugin
    bool initialized = await AgRegionMonitor.initialize();
    
    if (!initialized) {
      print('Failed to initialize location manager');
      return;
    }

    // 2. Request permissions
    bool notificationPermission = await AgRegionMonitor.requestNotificationPermission();
    String locationPermission = await AgRegionMonitor.checkLocationPermission();
    
    print('Notification permission: $notificationPermission');
    print('Location permission: $locationPermission');

    // 3. Setup a geofence
    await AgRegionMonitor.setupGeofence(
      latitude: 37.7749,
      longitude: -122.4194,
      radius: 100,
      identifier: 'SanFranciscoOffice',
      notifyOnEntry: true,
      notifyOnExit: true,
    );

    // 4. Start monitoring
    await AgRegionMonitor.startMonitoring();

    // 5. Listen to region events
    AgRegionMonitor.regionEvents.listen((event) {
      print('Region event: $event');
    });
  }
}
```

## API Reference

### Core Methods

#### `initialize()`
Initialize the location manager and set up delegates.

```dart
Future<bool> initialize()
```

**Example:**
```dart
bool success = await AgRegionMonitor.initialize();
if (success) {
  print('Location manager initialized successfully');
}
```

#### `setupGeofence()`
Create a circular geofence region for monitoring.

```dart
Future<void> setupGeofence({
  required double latitude,
  required double longitude,
  required double radius,
  required String identifier,
  bool notifyOnEntry = true,
  bool notifyOnExit = false,
})
```

**Parameters:**
- `latitude` - Center latitude of the region
- `longitude` - Center longitude of the region  
- `radius` - Radius in meters (maximum: 1000m)
- `identifier` - Unique identifier for the region
- `notifyOnEntry` - Show notification when entering region
- `notifyOnExit` - Show notification when exiting region

**Example:**
```dart
await AgRegionMonitor.setupGeofence(
  latitude: 40.7128,
  longitude: -74.0060,
  radius: 200,
  identifier: 'NewYorkOffice',
  notifyOnEntry: true,
  notifyOnExit: true,
);
```

#### `startMonitoring()`
Start location updates and region monitoring.

```dart
Future<void> startMonitoring()
```

**Example:**
```dart
await AgRegionMonitor.startMonitoring();
print('Started monitoring all regions');
```

#### `stopMonitoring()`
Stop monitoring a specific region.

```dart
Future<void> stopMonitoring(String identifier)
```

**Example:**
```dart
await AgRegionMonitor.stopMonitoring('NewYorkOffice');
```

#### `stopAllMonitoring()`
Stop monitoring all regions and location updates.

```dart
Future<void> stopAllMonitoring()
```

**Example:**
```dart
await AgRegionMonitor.stopAllMonitoring();
print('Stopped all monitoring');
```

### Region Management Methods

#### `getActiveRegions()`
Get all currently active/monitored regions with their details.

```dart
Future<List<Map<String, dynamic>>> getActiveRegions()
```

**Returns:** List of region data with identifier, latitude, longitude, radius, notifyOnEntry, and notifyOnExit

**Example:**
```dart
List<Map<String, dynamic>> regions = await AgRegionMonitor.getActiveRegions();
for (var region in regions) {
  print('Region: ${region['identifier']} at (${region['latitude']}, ${region['longitude']})');
  print('Radius: ${region['radius']}m, Entry: ${region['notifyOnEntry']}, Exit: ${region['notifyOnExit']}');
}
```

#### `removeRegion()`
Remove a specific region by identifier.

```dart
Future<bool> removeRegion(String identifier)
```

**Returns:** `true` if the region was successfully removed, `false` if not found

**Example:**
```dart
bool success = await AgRegionMonitor.removeRegion('NewYorkOffice');
if (success) {
  print('Region removed successfully');
} else {
  print('Region not found');
}
```

#### `removeAllRegions()`
Remove all regions from monitoring.

```dart
Future<bool> removeAllRegions()
```

**Returns:** `true` if all regions were successfully removed

**Example:**
```dart
bool success = await AgRegionMonitor.removeAllRegions();
if (success) {
  print('All regions removed');
}
```

#### `getActiveRegionCount()`
Get the count of currently active regions.

```dart
Future<int> getActiveRegionCount()
```

**Example:**
```dart
int count = await AgRegionMonitor.getActiveRegionCount();
print('Currently monitoring $count regions');
```

#### `isRegionActive()`
Check if a specific region is being monitored.

```dart
Future<bool> isRegionActive(String identifier)
```

**Example:**
```dart
bool isActive = await AgRegionMonitor.isRegionActive('NewYorkOffice');
if (isActive) {
  print('Region is currently being monitored');
} else {
  print('Region is not active');
}
```

#### `getRegionById()`
Get region details by identifier.

```dart
Future<Map<String, dynamic>?> getRegionById(String identifier)
```

**Returns:** Region data map or `null` if not found

**Example:**
```dart
Map<String, dynamic>? region = await AgRegionMonitor.getRegionById('NewYorkOffice');
if (region != null) {
  print('Found region: ${region['identifier']}');
  print('Location: (${region['latitude']}, ${region['longitude']})');
  print('Radius: ${region['radius']}m');
} else {
  print('Region not found');
}
```

#### `getActiveRegionIds()`
Get all region identifiers that are currently being monitored.

```dart
Future<List<String>> getActiveRegionIds()
```

**Example:**
```dart
List<String> regionIds = await AgRegionMonitor.getActiveRegionIds();
print('Active regions: ${regionIds.join(', ')}');

// Check each region
for (String id in regionIds) {
  Map<String, dynamic>? region = await AgRegionMonitor.getRegionById(id);
  if (region != null) {
    print('$id: (${region['latitude']}, ${region['longitude']})');
  }
}
```

### Permission Methods

#### `requestNotificationPermission()`
Request permission to show local notifications.

```dart
Future<bool> requestNotificationPermission()
```

**Example:**
```dart
bool granted = await AgRegionMonitor.requestNotificationPermission();
if (granted) {
  print('Notification permission granted');
} else {
  print('Notification permission denied');
}
```

#### `checkLocationPermission()`
Check current location permission status.

```dart
Future<String> checkLocationPermission()
```

**Returns:** One of:
- `"notDetermined"` - User hasn't been asked yet
- `"denied"` - User denied permission
- `"restricted"` - Permission is restricted
- `"authorizedWhenInUse"` - Permission granted when app is in use
- `"authorizedAlways"` - Permission granted always (required for geofencing)
- `"unknown"` - Unknown state

**Example:**
```dart
String status = await AgRegionMonitor.checkLocationPermission();
switch (status) {
  case 'authorizedAlways':
    print('Perfect! Can do background monitoring');
    break;
  case 'authorizedWhenInUse':
    print('Limited permission - only when app is open');
    break;
  case 'denied':
    print('Location permission denied');
    break;
  default:
    print('Permission status: $status');
}
```

### Convenience Methods

#### `hasLocationPermission()`
Check if any location permission is granted.

```dart
Future<bool> hasLocationPermission()
```

#### `hasAlwaysLocationPermission()`
Check if "Always" location permission is granted (required for background geofencing).

```dart
Future<bool> hasAlwaysLocationPermission()
```

#### `setupKarachiDangerZone()`
Pre-configured geofence for Karachi (example implementation).

```dart
Future<void> setupKarachiDangerZone()
```

**Example:**
```dart
// Check permissions before setting up geofencing
bool hasPermission = await AgRegionMonitor.hasLocationPermission();
bool hasAlwaysPermission = await AgRegionMonitor.hasAlwaysLocationPermission();

if (!hasPermission) {
  print('Need to request location permission first');
} else if (!hasAlwaysPermission) {
  print('Need "Always" permission for background monitoring');
} else {
  print('Ready for geofencing!');
}
```

### Region Management Examples

```dart
// Complete region management workflow
class RegionManagementExample {
  
  static Future<void> manageRegions() async {
    // Setup multiple regions
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7128, longitude: -74.0060, radius: 200,
      identifier: 'NewYorkOffice', notifyOnEntry: true, notifyOnExit: true,
    );
    
    await AgRegionMonitor.setupGeofence(
      latitude: 37.7749, longitude: -122.4194, radius: 150,
      identifier: 'SanFranciscoOffice', notifyOnEntry: true, notifyOnExit: false,
    );
    
    // Check what's active
    int count = await AgRegionMonitor.getActiveRegionCount();
    print('Total active regions: $count');
    
    // List all region IDs
    List<String> regionIds = await AgRegionMonitor.getActiveRegionIds();
    print('Active region IDs: ${regionIds.join(', ')}');
    
    // Get details for specific region
    Map<String, dynamic>? nyOffice = await AgRegionMonitor.getRegionById('NewYorkOffice');
    if (nyOffice != null) {
      print('NY Office radius: ${nyOffice['radius']}m');
    }
    
    // Check if specific region is active
    bool isNYActive = await AgRegionMonitor.isRegionActive('NewYorkOffice');
    print('NY Office active: $isNYActive');
    
    // Remove specific region
    bool removed = await AgRegionMonitor.removeRegion('SanFranciscoOffice');
    print('SF Office removed: $removed');
    
    // Final count
    count = await AgRegionMonitor.getActiveRegionCount();
    print('Remaining regions: $count');
    
    // Remove all regions
    await AgRegionMonitor.removeAllRegions();
    print('All regions removed');
  }
}
```

### Event Streams

#### `regionEvents`
Stream of region enter/exit events.

```dart
Stream<Map<String, dynamic>> get regionEvents
```

**Event Structure:**
```dart
{
  "event": "didEnterRegion" | "didExitRegion" | "monitoringDidFail",
  "identifier": "region_identifier",
  "timestamp": 1234567890.123,
  "error": "error_message" // only for monitoringDidFail
}
```

**Example:**
```dart
late StreamSubscription regionSubscription;

void startListening() {
  regionSubscription = AgRegionMonitor.regionEvents.listen((event) {
    String eventType = event['event'];
    String identifier = event['identifier'];
    double timestamp = event['timestamp'];
    
    switch (eventType) {
      case 'didEnterRegion':
        print('Entered region: $identifier at ${DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt())}');
        // Handle entry logic
        break;
        
      case 'didExitRegion':
        print('Exited region: $identifier');
        // Handle exit logic
        break;
        
      case 'monitoringDidFail':
        String error = event['error'];
        print('Monitoring failed for $identifier: $error');
        break;
    }
  });
}

void stopListening() {
  regionSubscription.cancel();
}
```

#### `locationUpdates`
Stream of location coordinate updates.

```dart
Stream<Map<String, dynamic>> get locationUpdates
```

**Event Structure:**
```dart
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "timestamp": 1234567890.123
}
```

**Example:**
```dart
AgRegionMonitor.locationUpdates.listen((location) {
  double lat = location['latitude'];
  double lng = location['longitude'];
  double timestamp = location['timestamp'];
  
  print('Current location: $lat, $lng');
  
  // Update your map or location display
  updateMapLocation(lat, lng);
});
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:ag_region_monitor/ag_region_monitor.dart';
import 'dart:async';

class GeofenceDemo extends StatefulWidget {
  @override
  _GeofenceDemoState createState() => _GeofenceDemoState();
}

class _GeofenceDemoState extends State<GeofenceDemo> {
  String _status = 'Not initialized';
  String _locationPermission = 'Unknown';
  String _lastEvent = 'None';
  int _activeRegionCount = 0;
  List<String> _regionIds = [];
  StreamSubscription? _regionSubscription;
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    try {
      // Initialize
      bool initialized = await AgRegionMonitor.initialize();
      if (!initialized) {
        setState(() => _status = 'Failed to initialize');
        return;
      }

      // Check permissions
      String locationPermission = await AgRegionMonitor.checkLocationPermission();
      bool notificationGranted = await AgRegionMonitor.requestNotificationPermission();

      setState(() {
        _status = 'Initialized';
        _locationPermission = locationPermission;
      });

      // Setup geofence
      await AgRegionMonitor.setupGeofence(
        latitude: 37.7749,
        longitude: -122.4194,
        radius: 100,
        identifier: 'TestOffice',
        notifyOnEntry: true,
        notifyOnExit: true,
      );

      // Start monitoring
      await AgRegionMonitor.startMonitoring();
      
      // Update region info
      await _updateRegionInfo();
      
      // Listen to events
      _regionSubscription = AgRegionMonitor.regionEvents.listen((event) {
        setState(() {
          _lastEvent = '${event['event']} - ${event['identifier']}';
        });
        _updateRegionInfo(); // Refresh region info on events
      });

      _locationSubscription = AgRegionMonitor.locationUpdates.listen((location) {
        print('Location: ${location['latitude']}, ${location['longitude']}');
      });

    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _updateRegionInfo() async {
    int count = await AgRegionMonitor.getActiveRegionCount();
    List<String> ids = await AgRegionMonitor.getActiveRegionIds();
    
    setState(() {
      _activeRegionCount = count;
      _regionIds = ids;
    });
  }

  @override
  void dispose() {
    _regionSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geofence Demo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status'),
            SizedBox(height: 10),
            Text('Location Permission: $_locationPermission'),
            SizedBox(height: 10),
            Text('Last Event: $_lastEvent'),
            SizedBox(height: 10),
            Text('Active Regions: $_activeRegionCount'),
            SizedBox(height: 10),
            Text('Region IDs: ${_regionIds.join(', ')}'),
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () async {
                String permission = await AgRegionMonitor.checkLocationPermission();
                setState(() => _locationPermission = permission);
              },
              child: Text('Check Permission'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                await AgRegionMonitor.setupKarachiDangerZone();
                await _updateRegionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Karachi danger zone setup!')),
                );
              },
              child: Text('Setup Karachi Zone'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> regions = await AgRegionMonitor.getActiveRegions();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Active Regions'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: regions.map((region) => 
                          Text('${region['identifier']}: (${region['latitude']}, ${region['longitude']}) - ${region['radius']}m')
                        ).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Show Region Details'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                bool success = await AgRegionMonitor.removeAllRegions();
                await _updateRegionInfo();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All regions removed: $success')),
                );
              },
              child: Text('Remove All Regions'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. Permission Handling
```dart
Future<bool> ensurePermissions() async {
  // Check current status
  String locationStatus = await AgRegionMonitor.checkLocationPermission();
  
  if (locationStatus == 'denied') {
    // Show dialog explaining why permission is needed
    _showPermissionDialog();
    return false;
  }
  
  if (locationStatus != 'authorizedAlways') {
    // Guide user to settings to enable "Always" permission
    _showAlwaysPermissionGuide();
    return false;
  }
  
  // Request notification permission
  bool notificationGranted = await AgRegionMonitor.requestNotificationPermission();
  
  return notificationGranted;
}
```

### 2. Error Handling
```dart
Future<void> setupGeofenceWithRetry(double lat, double lng, String id) async {
  try {
    await AgRegionMonitor.setupGeofence(
      latitude: lat,
      longitude: lng,
      radius: 100,
      identifier: id,
    );
  } catch (e) {
    print('Failed to setup geofence: $e');
    // Implement retry logic or show user-friendly error
  }
}
```

### 3. Resource Management
```dart
class LocationManager {
  StreamSubscription? _regionSub;
  StreamSubscription? _locationSub;
  
  void startListening() {
    _regionSub = AgRegionMonitor.regionEvents.listen(_handleRegionEvent);
    _locationSub = AgRegionMonitor.locationUpdates.listen(_handleLocationUpdate);
  }
  
  void dispose() {
    _regionSub?.cancel();
    _locationSub?.cancel();
    AgRegionMonitor.stopAllMonitoring();
  }
}
```

### 4. Region Management Best Practices
```dart
class RegionManager {
  
  // Setup regions with validation
  static Future<bool> setupRegionSafely({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  }) async {
    // Check if region already exists
    bool exists = await AgRegionMonitor.isRegionActive(identifier);
    if (exists) {
      print('Region $identifier already exists');
      return false;
    }
    
    // Check region count limit (iOS supports ~20 regions)
    int count = await AgRegionMonitor.getActiveRegionCount();
    if (count >= 19) {
      print('Too many regions active. Current: $count');
      return false;
    }
    
    try {
      await AgRegionMonitor.setupGeofence(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        identifier: identifier,
        notifyOnEntry: notifyOnEntry,
        notifyOnExit: notifyOnExit,
      );
      return true;
    } catch (e) {
      print('Failed to setup region: $e');
      return false;
    }
  }
  
  // Clean up specific regions
  static Future<void> cleanupOldRegions(List<String> regionsToKeep) async {
    List<String> activeIds = await AgRegionMonitor.getActiveRegionIds();
    
    for (String id in activeIds) {
      if (!regionsToKeep.contains(id)) {
        bool removed = await AgRegionMonitor.removeRegion(id);
        print('Removed old region $id: $removed');
      }
    }
  }
}
```

## Limitations

- **iOS Only**: Currently only supports iOS. Android support is planned.
- **Maximum Radius**: iOS limits geofence radius to 1000 meters.
- **Region Limit**: iOS typically supports monitoring up to 20 regions simultaneously.
- **Background Processing**: Requires "Always" location permission for background monitoring.
- **Battery Impact**: Continuous location monitoring may impact battery life.

## Troubleshooting

### Common Issues

1. **Geofencing not working in background**
   - Ensure "Always" location permission is granted
   - Check that Background Modes are enabled in Xcode

2. **Notifications not showing**
   - Verify notification permissions are granted
   - Check that the app is not in Do Not Disturb mode

3. **Permission dialogs not appearing**
   - Make sure Info.plist contains the required usage descriptions
   - Check that you're calling initialize() before other methods

4. **Events not firing**
   - Verify the device has good GPS signal
   - Test with larger radius first (200m+)
   - Check that you're listening to the event stream

5. **Region management issues**
   - Use `getActiveRegionCount()` to check region limits
   - Use `isRegionActive()` to avoid duplicate regions
   - Use `getActiveRegionIds()` to debug what's currently monitored

### Debug Tips

```dart
// Enable verbose logging
AgRegionMonitor.regionEvents.listen((event) {
  print('DEBUG - Region Event: $event');
});

AgRegionMonitor.locationUpdates.listen((location) {
  print('DEBUG - Location: ${location['latitude']}, ${location['longitude']}');
});

// Check permission status regularly
Timer.periodic(Duration(seconds: 30), (timer) async {
  String status = await AgRegionMonitor.checkLocationPermission();
  print('Permission status: $status');
});

// Debug region management
Future<void> debugRegions() async {
  int count = await AgRegionMonitor.getActiveRegionCount();
  List<String> ids = await AgRegionMonitor.getActiveRegionIds();
  List<Map<String, dynamic>> regions = await AgRegionMonitor.getActiveRegions();
  
  print('=== REGION DEBUG ===');
  print('Active count: $count');
  print('Active IDs: ${ids.join(', ')}');
  
  for (var region in regions) {
    print('${region['identifier']}: (${region['latitude']}, ${region['longitude']}) radius: ${region['radius']}m');
    print('  Entry: ${region['notifyOnEntry']}, Exit: ${region['notifyOnExit']}');
  }
  print('==================');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
