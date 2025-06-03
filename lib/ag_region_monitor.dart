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

  /// Get all active/monitored regions
  /// Returns a list of region data with identifier, latitude, longitude, radius, notifyOnEntry, and notifyOnExit
  static Future<List<Map<String, dynamic>>> getActiveRegions() => _platform.getActiveRegions();

  /// Remove a specific region by identifier
  /// Returns true if the region was successfully removed, false if not found
  static Future<bool> removeRegion(String identifier) => _platform.removeRegion(identifier);

  /// Remove all regions
  /// Returns true if all regions were successfully removed
  static Future<bool> removeAllRegions() => _platform.removeAllRegions();

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

  /// Get the count of active regions
  static Future<int> getActiveRegionCount() async {
    final regions = await getActiveRegions();
    return regions.length;
  }

  /// Check if a specific region is being monitored
  static Future<bool> isRegionActive(String identifier) async {
    final regions = await getActiveRegions();
    return regions.any((region) => region['identifier'] == identifier);
  }

  /// Get region details by identifier
  static Future<Map<String, dynamic>?> getRegionById(String identifier) async {
    final regions = await getActiveRegions();
    try {
      return regions.firstWhere((region) => region['identifier'] == identifier);
    } catch (e) {
      return null;
    }
  }

  /// Get all region identifiers
  static Future<List<String>> getActiveRegionIds() async {
    final regions = await getActiveRegions();
    return regions.map((region) => region['identifier'] as String).toList();
  }
}
