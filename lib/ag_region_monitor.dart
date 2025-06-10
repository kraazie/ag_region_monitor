import 'ag_region_monitor_platform_interface.dart';

class AgRegionMonitor {
  static AgRegionMonitorPlatform get _platform => AgRegionMonitorPlatform.instance;

  Future<String?> getPlatformVersion() {
    return AgRegionMonitorPlatform.instance.getPlatformVersion();
  }

  static Future<bool> initialize() => _platform.initialize();

  static Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
    String? notificationTitle,
    String? notificationBody,
  }) =>
      _platform.setupGeofence(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          identifier: identifier,
          notifyOnEntry: notifyOnEntry,
          notifyOnExit: notifyOnExit,
          notificationTitle: notificationTitle,
          notificationBody: notificationBody);

  static Future<void> startMonitoring() => _platform.startMonitoring();

  static Future<void> stopMonitoring(String identifier) => _platform.stopMonitoring(identifier);

  static Future<void> stopAllMonitoring() => _platform.stopAllMonitoring();

  static Future<bool> requestNotificationPermission() => _platform.requestNotificationPermission();

  static Future<String> checkLocationPermission() => _platform.checkLocationPermission();

  static Future<List<Map<String, dynamic>>> getActiveRegions() => _platform.getActiveRegions();

  static Future<bool> removeRegion(String identifier) => _platform.removeRegion(identifier);

  static Future<bool> removeAllRegions() => _platform.removeAllRegions();

  static Stream<Map<String, dynamic>> get regionEvents => _platform.regionEvents;

  static Stream<Map<String, dynamic>> get locationUpdates => _platform.locationUpdates;

  static Future<void> setupKarachiDangerZone() async {
    await setupGeofence(
        latitude: 24.8615,
        longitude: 67.0099,
        radius: 200,
        identifier: "KarachiDangerZone",
        notifyOnEntry: true,
        notifyOnExit: false,
        notificationTitle: "⚠️ Danger Zone",
        notificationBody: "You've entered a danger zone in Karachi!");
  }

  static Future<bool> hasLocationPermission() async {
    final status = await checkLocationPermission();
    return status == 'authorizedAlways' || status == 'authorizedWhenInUse';
  }

  static Future<bool> hasAlwaysLocationPermission() async {
    final status = await checkLocationPermission();
    return status == 'authorizedAlways';
  }

  static Future<int> getActiveRegionCount() async {
    final regions = await getActiveRegions();
    return regions.length;
  }

  static Future<bool> isRegionActive(String identifier) async {
    final regions = await getActiveRegions();
    return regions.any((region) => region['identifier'] == identifier);
  }

  static Future<Map<String, dynamic>?> getRegionById(String identifier) async {
    final regions = await getActiveRegions();
    try {
      return regions.firstWhere((region) => region['identifier'] == identifier);
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getActiveRegionIds() async {
    final regions = await getActiveRegions();
    return regions.map((region) => region['identifier'] as String).toList();
  }
}
