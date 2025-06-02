import 'ag_region_monitor_platform_interface.dart';

class AgRegionMonitor {
  static AgRegionMonitorPlatform get _platform => AgRegionMonitorPlatform.instance;

  Future<String?> getPlatformVersion() {
    return AgRegionMonitorPlatform.instance.getPlatformVersion();
  }

  /// Initialize the location manager and request permissions
  static Future<bool> initialize() => _platform.initialize();

  /// Setup a geofence for monitoring
  static Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  }) => _platform.setupGeofence(latitude: latitude, longitude: longitude, radius: radius, identifier: identifier, notifyOnEntry: notifyOnEntry, notifyOnExit: notifyOnExit);

  /// Start monitoring all registered geofences
  static Future<void> startMonitoring() => _platform.startMonitoring();

  /// Stop monitoring a specific region
  static Future<void> stopMonitoring(String identifier) => _platform.stopMonitoring(identifier);

  /// Stop monitoring all regions
  static Future<void> stopAllMonitoring() => _platform.stopAllMonitoring();

  /// Request notification permissions
  static Future<bool> requestNotificationPermission() => _platform.requestNotificationPermission();

  /// Check current location permission status
  /// Returns: 'notDetermined', 'denied', 'restricted', 'authorizedWhenInUse', 'authorizedAlways', or 'unknown'
  static Future<String> checkLocationPermission() => _platform.checkLocationPermission();

  /// Stream of region enter/exit events
  static Stream<Map<String, dynamic>> get regionEvents => _platform.regionEvents;

  /// Stream of location updates
  static Stream<Map<String, dynamic>> get locationUpdates => _platform.locationUpdates;

  /// Convenience method to setup Karachi danger zone (matching your Swift code)
  static Future<void> setupKarachiDangerZone() async {
    await setupGeofence(latitude: 24.8615, longitude: 67.0099, radius: 200, identifier: "KarachiDangerZone", notifyOnEntry: true, notifyOnExit: false);
  }

  /// Check if location permission is sufficient for geofencing
  static Future<bool> hasLocationPermission() async {
    final status = await checkLocationPermission();
    return status == 'authorizedAlways' || status == 'authorizedWhenInUse';
  }

  /// Check if location permission allows background monitoring (geofencing)
  static Future<bool> hasAlwaysLocationPermission() async {
    final status = await checkLocationPermission();
    return status == 'authorizedAlways';
  }
}
