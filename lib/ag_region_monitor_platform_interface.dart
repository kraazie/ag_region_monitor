import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'ag_region_monitor_method_channel.dart';

abstract class AgRegionMonitorPlatform extends PlatformInterface {
  AgRegionMonitorPlatform() : super(token: _token);

  static final Object _token = Object();

  static AgRegionMonitorPlatform _instance = MethodChannelAgRegionMonitor();

  static AgRegionMonitorPlatform get instance => _instance;

  static set instance(AgRegionMonitorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initialize();

  Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
    String? notificationTitle,
    String? notificationBody,
  });

  Future<void> startMonitoring();

  Future<void> stopMonitoring(String identifier);

  Future<void> stopAllMonitoring();

  Future<bool> requestNotificationPermission();

  Future<String> checkLocationPermission();

  Future<List<Map<String, dynamic>>> getActiveRegions();

  Future<bool> removeRegion(String identifier);

  Future<bool> removeAllRegions();

  Stream<Map<String, dynamic>> get regionEvents;

  Stream<Map<String, dynamic>> get locationUpdates;
}
