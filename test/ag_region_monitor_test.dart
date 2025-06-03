import 'package:flutter_test/flutter_test.dart';
import 'package:ag_region_monitor/ag_region_monitor.dart';
import 'package:ag_region_monitor/ag_region_monitor_platform_interface.dart';
import 'package:ag_region_monitor/ag_region_monitor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAgRegionMonitorPlatform with MockPlatformInterfaceMixin implements AgRegionMonitorPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  // TODO: implement locationUpdates
  Stream<Map<String, dynamic>> get locationUpdates => throw UnimplementedError();

  @override
  // TODO: implement regionEvents
  Stream<Map<String, dynamic>> get regionEvents => throw UnimplementedError();

  @override
  Future<bool> requestNotificationPermission() {
    // TODO: implement requestNotificationPermission
    throw UnimplementedError();
  }

  @override
  Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  }) {
    // TODO: implement setupGeofence
    throw UnimplementedError();
  }

  @override
  Future<void> startMonitoring() {
    // TODO: implement startMonitoring
    throw UnimplementedError();
  }

  @override
  Future<void> stopAllMonitoring() {
    // TODO: implement stopAllMonitoring
    throw UnimplementedError();
  }

  @override
  Future<void> stopMonitoring(String identifier) {
    // TODO: implement stopMonitoring
    throw UnimplementedError();
  }

  @override
  Future<String> checkLocationPermission() {
    // TODO: implement checkLocationPermission
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveRegions() {
    // TODO: implement getActiveRegions
    throw UnimplementedError();
  }

  @override
  Future<bool> removeAllRegions() {
    // TODO: implement removeAllRegions
    throw UnimplementedError();
  }

  @override
  Future<bool> removeRegion(String identifier) {
    // TODO: implement removeRegion
    throw UnimplementedError();
  }
}

void main() {
  final AgRegionMonitorPlatform initialPlatform = AgRegionMonitorPlatform.instance;

  test('$MethodChannelAgRegionMonitor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAgRegionMonitor>());
  });

  test('getPlatformVersion', () async {
    AgRegionMonitor agRegionMonitorPlugin = AgRegionMonitor();
    MockAgRegionMonitorPlatform fakePlatform = MockAgRegionMonitorPlatform();
    AgRegionMonitorPlatform.instance = fakePlatform;

    expect(await agRegionMonitorPlugin.getPlatformVersion(), '42');
  });
}
