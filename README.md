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
      
      // Listen to events
      _regionSubscription = AgRegionMonitor.regionEvents.listen((event) {
        setState(() {
          _lastEvent = '${event['event']} - ${event['identifier']}';
        });
      });

      _locationSubscription = AgRegionMonitor.locationUpdates.listen((location) {
        print('Location: ${location['latitude']}, ${location['longitude']}');
      });

    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Karachi danger zone setup!')),
                );
              },
              child: Text('Setup Karachi Zone'),
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
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
