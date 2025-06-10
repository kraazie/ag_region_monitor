# AgRegionMonitor Plugin

A Flutter plugin for iOS that provides geofencing and region monitoring capabilities using CoreLocation. This plugin allows you to monitor when users enter or exit specific geographic regions, with support for customizable local notifications and real-time location updates.

## Features

- ✅ **Geofencing** - Monitor circular geographic regions
- ✅ **Background Monitoring** - Works when app is in background (with proper permissions)
- ✅ **Custom Local Notifications** - Personalized notifications with custom titles and messages
- ✅ **Persistent Notification Settings** - Notification preferences saved across app sessions
- ✅ **Real-time Location Updates** - Stream of location changes
- ✅ **Permission Management** - Handle location and notification permissions
- ✅ **Multiple Regions** - Monitor multiple geofences simultaneously
- ✅ **Flexible Entry/Exit Monitoring** - Configure notifications per region for entry and/or exit
- ✅ **Region Management** - Add, remove, and query active regions

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅      |
| Android  | ❌ (Coming Soon) |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ag_region_monitor: ^1.0.3
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

    // 3. Setup a geofence with custom notification
    await AgRegionMonitor.setupGeofence(
      latitude: 37.7749,
      longitude: -122.4194,
      radius: 100,
      identifier: 'SanFranciscoOffice',
      notifyOnEntry: true,
      notifyOnExit: true,
      notificationTitle: '🏢 Welcome to the Office!',
      notificationBody: 'You have entered the San Francisco office area. Check in to start your workday.',
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
Create a circular geofence region for monitoring with customizable notifications.

```dart
Future<void> setupGeofence({
  required double latitude,
  required double longitude,
  required double radius,
  required String identifier,
  bool notifyOnEntry = true,
  bool notifyOnExit = false,
  String? notificationTitle,
  String? notificationBody,
})
```

**Parameters:**
- `latitude` - Center latitude of the region
- `longitude` - Center longitude of the region  
- `radius` - Radius in meters (maximum: 1000m)
- `identifier` - Unique identifier for the region
- `notifyOnEntry` - Show notification when entering region
- `notifyOnExit` - Show notification when exiting region
- `notificationTitle` - **NEW!** Custom title for the notification (persisted across app sessions)
- `notificationBody` - **NEW!** Custom body text for the notification (persisted across app sessions)

**Example:**
```dart
await AgRegionMonitor.setupGeofence(
  latitude: 40.7128,
  longitude: -74.0060,
  radius: 200,
  identifier: 'NewYorkOffice',
  notifyOnEntry: true,
  notifyOnExit: true,
  notificationTitle: '🏙️ NYC Office Zone',
  notificationBody: 'Welcome to the New York office. Tap to check your schedule and meetings.',
);
```

**Custom Notification Examples:**
```dart
// Home geofence
await AgRegionMonitor.setupGeofence(
  latitude: 40.7589,
  longitude: -73.9851,
  radius: 50,
  identifier: 'Home',
  notifyOnEntry: true,
  notificationTitle: '🏠 Welcome Home',
  notificationBody: 'You\'ve arrived home safely. Time to relax!',
);

// Gym geofence
await AgRegionMonitor.setupGeofence(
  latitude: 40.7505,
  longitude: -73.9934,
  radius: 75,
  identifier: 'Gym',
  notifyOnEntry: true,
  notificationTitle: '💪 Workout Time!',
  notificationBody: 'Ready to crush your fitness goals? Let\'s go!',
);

// School pickup zone
await AgRegionMonitor.setupGeofence(
  latitude: 40.7282,
  longitude: -73.7949,
  radius: 100,
  identifier: 'School',
  notifyOnEntry: true,
  notifyOnExit: true,
  notificationTitle: '🎒 School Zone',
  notificationBody: 'You\'re at the school pickup area.',
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
Get all currently active/monitored regions with their details, including custom notification settings.

```dart
Future<List<Map<String, dynamic>>> getActiveRegions()
```

**Returns:** List of region data with identifier, latitude, longitude, radius, notifyOnEntry, notifyOnExit, and custom notification content

**Example:**
```dart
List<Map<String, dynamic>> regions = await AgRegionMonitor.getActiveRegions();
for (var region in regions) {
  print('Region: ${region['identifier']} at (${region['latitude']}, ${region['longitude']})');
  print('Radius: ${region['radius']}m, Entry: ${region['notifyOnEntry']}, Exit: ${region['notifyOnExit']}');
  
  // Check for custom notification content
  if (region.containsKey('notificationTitle')) {
    print('Custom notification: ${region['notificationTitle']} - ${region['notificationBody']}');
  }
}
```

#### `removeRegion()`
Remove a specific region by identifier and clean up its notification settings.

```dart
Future<bool> removeRegion(String identifier)
```

**Returns:** `true` if the region was successfully removed, `false` if not found

**Example:**
```dart
bool success = await AgRegionMonitor.removeRegion('NewYorkOffice');
if (success) {
  print('Region and its notification settings removed successfully');
} else {
  print('Region not found');
}
```

#### `removeAllRegions()`
Remove all regions from monitoring and clear all notification settings.

```dart
Future<bool> removeAllRegions()
```

**Returns:** `true` if all regions were successfully removed

**Example:**
```dart
bool success = await AgRegionMonitor.removeAllRegions();
if (success) {
  print('All regions and notification settings removed');
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
Get region details by identifier, including custom notification settings.

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
  
  // Check for custom notifications
  if (region['notificationTitle'] != null) {
    print('Custom notification: "${region['notificationTitle']}" - "${region['notificationBody']}"');
  }
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

// Check each region with its notification settings
for (String id in regionIds) {
  Map<String, dynamic>? region = await AgRegionMonitor.getRegionById(id);
  if (region != null) {
    print('$id: (${region['latitude']}, ${region['longitude']})');
    if (region['notificationTitle'] != null) {
      print('  Notification: ${region['notificationTitle']}');
    }
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
Pre-configured geofence for Karachi with custom danger zone notification (example implementation).

```dart
Future<void> setupKarachiDangerZone()
```

**Example:**
```dart
// This sets up a danger zone in Karachi with custom notification
await AgRegionMonitor.setupKarachiDangerZone();
// Equivalent to:
// await AgRegionMonitor.setupGeofence(
//   latitude: 24.8615,
//   longitude: 67.0099,
//   radius: 200,
//   identifier: "KarachiDangerZone",
//   notifyOnEntry: true,
//   notifyOnExit: false,
//   notificationTitle: "⚠️ Danger Zone",
//   notificationBody: "You've entered a danger zone in Karachi!"
// );
```

**Permission checking:**
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

### Advanced Region Management

#### Custom Notification Management
```dart
class NotificationManager {
  
  // Setup regions with themed notifications
  static Future<void> setupLocationBasedNotifications() async {
    // Work locations
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7589, longitude: -73.9851, radius: 100,
      identifier: 'MainOffice',
      notificationTitle: '💼 Work Mode Activated',
      notificationBody: 'Welcome to the office! Your meetings and tasks are ready.',
    );
    
    // Personal locations
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7505, longitude: -73.9934, radius: 75,
      identifier: 'Gym',
      notificationTitle: '🏃‍♂️ Workout Time!',
      notificationBody: 'Time to achieve your fitness goals. You\'ve got this!',
    );
    
    // Family locations
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7282, longitude: -73.7949, radius: 50,
      identifier: 'Home',
      notifyOnEntry: true,
      notifyOnExit: true,
      notificationTitle: '🏠 Home Sweet Home',
      notificationBody: 'Welcome home! Time to relax and unwind.',
    );
    
    // Important places with exit notifications
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7614, longitude: -73.9776, radius: 200,
      identifier: 'Hospital',
      notifyOnEntry: true,
      notifyOnExit: true,
      notificationTitle: '🏥 Hospital Area',
      notificationBody: 'You are near the hospital. Drive carefully and keep quiet.',
    );
  }
  
  // Update notification for existing region
  static Future<void> updateRegionNotification(String identifier, String title, String body) async {
    // Get current region details
    Map<String, dynamic>? region = await AgRegionMonitor.getRegionById(identifier);
    if (region != null) {
      // Remove old region
      await AgRegionMonitor.removeRegion(identifier);
      
      // Re-create with new notification
      await AgRegionMonitor.setupGeofence(
        latitude: region['latitude'],
        longitude: region['longitude'],
        radius: region['radius'],
        identifier: identifier,
        notifyOnEntry: region['notifyOnEntry'],
        notifyOnExit: region['notifyOnExit'],
        notificationTitle: title,
        notificationBody: body,
      );
    }
  }
}
```

### Region Management Examples

```dart
// Complete region management workflow
class RegionManagementExample {
  
  static Future<void> manageRegions() async {
    // Setup multiple regions with custom notifications
    await AgRegionMonitor.setupGeofence(
      latitude: 40.7128, longitude: -74.0060, radius: 200,
      identifier: 'NewYorkOffice',
      notifyOnEntry: true, notifyOnExit: true,
      notificationTitle: '🗽 NYC Office',
      notificationBody: 'You\'ve arrived at the New York office!',
    );
    
    await AgRegionMonitor.setupGeofence(
      latitude: 37.7749, longitude: -122.4194, radius: 150,
      identifier: 'SanFranciscoOffice',
      notifyOnEntry: true, notifyOnExit: false,
      notificationTitle: '🌉 SF Office',
      notificationBody: 'Welcome to San Francisco office!',
    );
    
    // Check what's active
    int count = await AgRegionMonitor.getActiveRegionCount();
    print('Total active regions: $count');
    
    // List all region IDs
    List<String> regionIds = await AgRegionMonitor.getActiveRegionIds();
    print('Active region IDs: ${regionIds.join(', ')}');
    
    // Get details for specific region including notifications
    Map<String, dynamic>? nyOffice = await AgRegionMonitor.getRegionById('NewYorkOffice');
    if (nyOffice != null) {
      print('NY Office radius: ${nyOffice['radius']}m');
      print('Notification: ${nyOffice['notificationTitle']} - ${nyOffice['notificationBody']}');
    }
    
    // Check if specific region is active
    bool isNYActive = await AgRegionMonitor.isRegionActive('NewYorkOffice');
    print('NY Office active: $isNYActive');
    
    // Remove specific region (also removes its notification settings)
    bool removed = await AgRegionMonitor.removeRegion('SanFranciscoOffice');
    print('SF Office removed: $removed');
    
    // Final count
    count = await AgRegionMonitor.getActiveRegionCount();
    print('Remaining regions: $count');
    
    // Remove all regions and notification settings
    await AgRegionMonitor.removeAllRegions();
    print('All regions and notifications removed');
  }
}
```

### Event Streams

#### `regionEvents`
Stream of region enter/exit events and monitoring failures.

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
    DateTime eventTime = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    
    switch (eventType) {
      case 'didEnterRegion':
        print('Entered region: $identifier at $eventTime');
        _handleRegionEntry(identifier);
        break;
        
      case 'didExitRegion':
        print('Exited region: $identifier at $eventTime');
        _handleRegionExit(identifier);
        break;
        
      case 'monitoringDidFail':
        String error = event['error'];
        print('Monitoring failed for $identifier: $error');
        _handleMonitoringError(identifier, error);
        break;
    }
  });
}

void _handleRegionEntry(String identifier) {
  // Custom logic for when user enters a region
  // The notification is automatically shown by the plugin
  switch (identifier) {
    case 'Office':
      // Start work mode, open productivity apps
      break;
    case 'Home':
      // Enable home automation, set evening mood
      break;
    case 'Gym':
      // Start workout tracking, play energetic music
      break;
  }
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
  DateTime updateTime = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
  
  print('Current location: $lat, $lng at $updateTime');
  
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

      // Setup geofence with custom notification
      await AgRegionMonitor.setupGeofence(
        latitude: 37.7749,
        longitude: -122.4194,
        radius: 100,
        identifier: 'TestOffice',
        notifyOnEntry: true,
        notifyOnExit: true,
        notificationTitle: '🏢 Test Office',
        notificationBody: 'Welcome to the test office area! This is a custom notification.',
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
