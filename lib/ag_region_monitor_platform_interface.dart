import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ag_region_monitor_method_channel.dart';

abstract class AgRegionMonitorPlatform extends PlatformInterface {
  /// Constructs a AgRegionMonitorPlatform.
  AgRegionMonitorPlatform() : super(token: _token);

  static final Object _token = Object();

  static AgRegionMonitorPlatform _instance = MethodChannelAgRegionMonitor();

  /// The default instance of [AgRegionMonitorPlatform] to use.
  ///
  /// Defaults to [MethodChannelAgRegionMonitor].
  static AgRegionMonitorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AgRegionMonitorPlatform] when
  /// they register themselves.
  static set instance(AgRegionMonitorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize location manager and request permissions
  Future<bool> initialize();

  /// Setup geofence for a specific location
  Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  });

  /// Start monitoring for all registered regions
  Future<void> startMonitoring();

  /// Stop monitoring for a specific region
  Future<void> stopMonitoring(String identifier);

  /// Stop monitoring for all regions
  Future<void> stopAllMonitoring();

  /// Request notification permissions
  Future<bool> requestNotificationPermission();

  /// Check current location permission status
  Future<String> checkLocationPermission();

  /// Get all active/monitored regions
  Future<List<Map<String, dynamic>>> getActiveRegions();

  /// Remove a specific region by identifier
  Future<bool> removeRegion(String identifier);

  /// Remove all regions
  Future<bool> removeAllRegions();

  /// Stream of region events (enter/exit)
  Stream<Map<String, dynamic>> get regionEvents;

  /// Stream of location updates
  Stream<Map<String, dynamic>> get locationUpdates;
}
