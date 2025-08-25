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
    bool notifyOnExit = true,
    String? notificationTitleEnter,
    String? notificationBodyEnter,
    String? notificationTitleExit,
    String? notificationBodyExit,
  }) =>
      _platform.setupGeofence(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        identifier: identifier,
        notifyOnEntry: notifyOnEntry,
        notifyOnExit: notifyOnExit,
        notificationTitleEnter: notificationTitleEnter,
        notificationBodyEnter: notificationBodyEnter,
        notificationTitleExit: notificationTitleExit,
        notificationBodyExit: notificationBodyExit,
      );

  static Future<void> startMonitoring() => _platform.startMonitoring();

  static Future<void> stopMonitoring(String identifier) => _platform.stopMonitoring(identifier);

  static Future<void> stopAllMonitoring() => _platform.stopAllMonitoring();

  static Future<bool> requestNotificationPermission() => _platform.requestNotificationPermission();

  static Future<String> checkLocationPermission() => _platform.checkLocationPermission();

  static Future<List<Map<String, dynamic>>> getActiveRegions() => _platform.getActiveRegions();

  static Future<bool> removeRegion(String identifier) => _platform.removeRegion(identifier);

  static Future<bool> removeAllRegions() => _platform.removeAllRegions();

  static Future<void> setNotificationsEnabled(bool enabled) => _platform.setNotificationsEnabled(enabled);

  static Future<void> setNotificationsRepeatEnabled(bool enabled) => _platform.setNotificationsRepeatEnabled(enabled);

  static Future<void> setNotificationsRepeatTimer(int timer) => _platform.setNotificationsRepeatTimer(timer);

  /// Checks if a manual location (latitude, longitude) falls within any active geofence regions
  /// Returns a list of regions that contain the specified location
  /// Also sends notifications for matching regions
  static Future<List<Map<String, dynamic>>> checkManualLocation({
    required double latitude,
    required double longitude,
  }) =>
      _platform.checkManualLocation(latitude: latitude, longitude: longitude);

  static Stream<Map<String, dynamic>> get regionEvents => _platform.regionEvents;

  static Stream<Map<String, dynamic>> get locationUpdates => _platform.locationUpdates;

  static Future<void> setupKarachiDangerZone() async {
    await setupGeofence(
      latitude: 24.8615,
      longitude: 67.0099,
      radius: 200,
      identifier: "KarachiDangerZone",
      notifyOnEntry: true,
      notifyOnExit: true,
      notificationTitleEnter: "⚠️ Danger Zone",
      notificationBodyEnter: "You've entered a danger zone in Karachi!",
      notificationTitleExit: "✅ Safe Zone",
      notificationBodyExit: "You've left the danger zone. Stay safe!",
    );
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

  /// Checks if a location is within any active regions and returns matching regions
  /// This is a convenience method that wraps checkManualLocation
  static Future<bool> isLocationInAnyRegion({
    required double latitude,
    required double longitude,
  }) async {
    final matchingRegions = await checkManualLocation(
      latitude: latitude,
      longitude: longitude,
    );
    return matchingRegions.isNotEmpty;
  }

  /// Gets all regions that contain the specified location without triggering notifications
  /// This could be implemented in the future for read-only location checks
  static Future<List<Map<String, dynamic>>> getRegionsContainingLocation({
    required double latitude,
    required double longitude,
  }) async {
    // For now, this uses the same method as checkManualLocation
    // In the future, you could add a separate native method that doesn't trigger notifications
    return await checkManualLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Setup a custom geofence with separate enter and exit notifications
  static Future<void> setupCustomGeofenceWithSeparateNotifications({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = true,
    String? enterTitle,
    String? enterBody,
    String? exitTitle,
    String? exitBody,
  }) async {
    await setupGeofence(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      identifier: identifier,
      notifyOnEntry: notifyOnEntry,
      notifyOnExit: notifyOnExit,
      notificationTitleEnter: enterTitle,
      notificationBodyEnter: enterBody,
      notificationTitleExit: exitTitle,
      notificationBodyExit: exitBody,
    );
  }

  /// Get enter notification details for a specific region
  static Future<Map<String, String>?> getEnterNotificationForRegion(String identifier) async {
    final region = await getRegionById(identifier);
    if (region != null && region['notificationTitleEnter'] != null && region['notificationBodyEnter'] != null) {
      return {
        'title': region['notificationTitleEnter'] as String,
        'body': region['notificationBodyEnter'] as String,
      };
    }
    return null;
  }

  /// Get exit notification details for a specific region
  static Future<Map<String, String>?> getExitNotificationForRegion(String identifier) async {
    final region = await getRegionById(identifier);
    if (region != null && region['notificationTitleExit'] != null && region['notificationBodyExit'] != null) {
      return {
        'title': region['notificationTitleExit'] as String,
        'body': region['notificationBodyExit'] as String,
      };
    }
    return null;
  }
}
