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

  /// Stream of region enter/exit events
  static Stream<Map<String, dynamic>> get regionEvents => _platform.regionEvents;

  /// Stream of location updates
  static Stream<Map<String, dynamic>> get locationUpdates => _platform.locationUpdates;

  /// Convenience method to setup Karachi danger zone (matching your Swift code)
  static Future<void> setupKarachiDangerZone() async {
    await setupGeofence(latitude: 24.8615, longitude: 67.0099, radius: 200, identifier: "KarachiDangerZone", notifyOnEntry: true, notifyOnExit: false);
  }
}
