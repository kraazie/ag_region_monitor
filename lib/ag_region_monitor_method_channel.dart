import 'package:flutter/services.dart';
import 'ag_region_monitor_platform_interface.dart';

class MethodChannelAgRegionMonitor extends AgRegionMonitorPlatform {
  static const MethodChannel _channel = MethodChannel('ag_region_monitor');
  static const EventChannel _regionEventChannel = EventChannel('ag_region_monitor/region_events');
  static const EventChannel _locationEventChannel = EventChannel('ag_region_monitor/location_updates');

  @override
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } catch (e) {
      print('Error initializing location manager: $e');
      return false;
    }
  }

  @override
  Future<void> setupGeofence({
    required double latitude,
    required double longitude,
    required double radius,
    required String identifier,
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  }) async {
    try {
      await _channel.invokeMethod('setupGeofence', {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'identifier': identifier,
        'notifyOnEntry': notifyOnEntry,
        'notifyOnExit': notifyOnExit,
      });
    } catch (e) {
      print('Error setting up geofence: $e');
      rethrow;
    }
  }

  @override
  Future<void> startMonitoring() async {
    try {
      await _channel.invokeMethod('startMonitoring');
    } catch (e) {
      print('Error starting monitoring: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopMonitoring(String identifier) async {
    try {
      await _channel.invokeMethod('stopMonitoring', {'identifier': identifier});
    } catch (e) {
      print('Error stopping monitoring: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopAllMonitoring() async {
    try {
      await _channel.invokeMethod('stopAllMonitoring');
    } catch (e) {
      print('Error stopping all monitoring: $e');
      rethrow;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  @override
  Future<String> checkLocationPermission() async {
    try {
      final result = await _channel.invokeMethod<String>('checkLocationPermission');
      return result ?? 'unknown';
    } catch (e) {
      print('Error checking location permission: $e');
      return 'unknown';
    }
  }

  @override
  Stream<Map<String, dynamic>> get regionEvents {
    return _regionEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Stream<Map<String, dynamic>> get locationUpdates {
    return _locationEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }
}
