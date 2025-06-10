import Flutter
import UIKit
import CoreLocation
import UserNotifications

public class AgRegionMonitorPlugin: NSObject, FlutterPlugin {
    private var locationManager: LocationManager?
    private var regionEventSink: FlutterEventSink?
    private var locationEventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ag_region_monitor", binaryMessenger: registrar.messenger())
        let regionEventChannel = FlutterEventChannel(name: "ag_region_monitor/region_events", binaryMessenger: registrar.messenger())
        let locationEventChannel = FlutterEventChannel(name: "ag_region_monitor/location_updates", binaryMessenger: registrar.messenger())
        
        let instance = AgRegionMonitorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        regionEventChannel.setStreamHandler(RegionEventStreamHandler(plugin: instance))
        locationEventChannel.setStreamHandler(LocationEventStreamHandler(plugin: instance))
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "setupGeofence":
            setupGeofence(call: call, result: result)
        case "startMonitoring":
            startMonitoring(result: result)
        case "stopMonitoring":
            stopMonitoring(call: call, result: result)
        case "stopAllMonitoring":
            stopAllMonitoring(result: result)
        case "requestNotificationPermission":
            requestNotificationPermission(result: result)
        case "checkLocationPermission":
            checkLocationPermission(result: result)
        case "getActiveRegions":
            getActiveRegions(result: result)
        case "removeRegion":
            removeRegion(call: call, result: result)
        case "removeAllRegions":
            removeAllRegions(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(result: @escaping FlutterResult) {
        locationManager = LocationManager()
        locationManager?.delegate = self
        result(true)
    }
    
    private func setupGeofence(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double,
              let radius = args["radius"] as? Double,
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let notifyOnEntry = args["notifyOnEntry"] as? Bool ?? true
        let notifyOnExit = args["notifyOnExit"] as? Bool ?? false
        let notificationTitle = args["notificationTitle"] as? String
        let notificationBody = args["notificationBody"] as? String
        
        locationManager?.setupCustomGeofence(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            identifier: identifier,
            notifyOnEntry: notifyOnEntry,
            notifyOnExit: notifyOnExit,
            notificationTitle: notificationTitle,
            notificationBody: notificationBody
        )
        
        result(nil)
    }
    
    private func startMonitoring(result: @escaping FlutterResult) {
        locationManager?.startLocationUpdates()
        result(nil)
    }
    
    private func stopMonitoring(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        locationManager?.stopMonitoring(identifier: identifier)
        result(nil)
    }
    
    private func stopAllMonitoring(result: @escaping FlutterResult) {
        locationManager?.stopAllMonitoring()
        result(nil)
    }
    
    private func requestNotificationPermission(result: @escaping FlutterResult) {
        locationManager?.requestNotificationPermission { granted in
            DispatchQueue.main.async {
                result(granted)
            }
        }
    }
    
    private func checkLocationPermission(result: @escaping FlutterResult) {
        guard let locationManager = locationManager else {
            result(FlutterError(code: "LOCATION_MANAGER_NOT_INITIALIZED", message: "Location manager not initialized", details: nil))
            return
        }
        
        let permissionStatus = locationManager.getLocationPermissionStatus()
        result(permissionStatus)
    }
    
    private func getActiveRegions(result: @escaping FlutterResult) {
        guard let locationManager = locationManager else {
            result(FlutterError(code: "LOCATION_MANAGER_NOT_INITIALIZED", message: "Location manager not initialized", details: nil))
            return
        }
        
        let activeRegions = locationManager.getActiveRegions()
        result(activeRegions)
    }
    
    private func removeRegion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let locationManager = locationManager else {
            result(FlutterError(code: "LOCATION_MANAGER_NOT_INITIALIZED", message: "Location manager not initialized", details: nil))
            return
        }
        
        let success = locationManager.removeRegion(identifier: identifier)
        result(success)
    }
    
    private func removeAllRegions(result: @escaping FlutterResult) {
        guard let locationManager = locationManager else {
            result(FlutterError(code: "LOCATION_MANAGER_NOT_INITIALIZED", message: "Location manager not initialized", details: nil))
            return
        }
        
        locationManager.removeAllRegions()
        result(true)
    }
    
    func setRegionEventSink(_ eventSink: FlutterEventSink?) {
        self.regionEventSink = eventSink
    }
    
    func setLocationEventSink(_ eventSink: FlutterEventSink?) {
        self.locationEventSink = eventSink
    }
}

extension AgRegionMonitorPlugin: LocationManagerDelegate {
    func didEnterRegion(_ identifier: String) {
        let eventData: [String: Any] = [
            "event": "didEnterRegion",
            "identifier": identifier,
            "timestamp": Date().timeIntervalSince1970
        ]
        regionEventSink?(eventData)
    }
    
    func didExitRegion(_ identifier: String) {
        let eventData: [String: Any] = [
            "event": "didExitRegion", 
            "identifier": identifier,
            "timestamp": Date().timeIntervalSince1970
        ]
        regionEventSink?(eventData)
    }
    
    func didUpdateLocation(_ latitude: Double, _ longitude: Double) {
        let locationData: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Date().timeIntervalSince1970
        ]
        locationEventSink?(locationData)
    }
    
    func monitoringDidFail(_ identifier: String?, _ error: String) {
        let errorData: [String: Any] = [
            "event": "monitoringDidFail",
            "identifier": identifier ?? "",
            "error": error,
            "timestamp": Date().timeIntervalSince1970
        ]
        regionEventSink?(errorData)
    }
}

class RegionEventStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: AgRegionMonitorPlugin?
    
    init(plugin: AgRegionMonitorPlugin) {
        self.plugin = plugin
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.setRegionEventSink(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.setRegionEventSink(nil)
        return nil
    }
}

class LocationEventStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: AgRegionMonitorPlugin?
    
    init(plugin: AgRegionMonitorPlugin) {
        self.plugin = plugin
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.setLocationEventSink(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.setLocationEventSink(nil)
        return nil
    }
}