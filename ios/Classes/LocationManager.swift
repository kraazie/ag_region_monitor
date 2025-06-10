import Foundation
import CoreLocation
import UserNotifications

protocol LocationManagerDelegate: AnyObject {
    func didEnterRegion(_ identifier: String)
    func didExitRegion(_ identifier: String)
    func didUpdateLocation(_ latitude: Double, _ longitude: Double)
    func monitoringDidFail(_ identifier: String?, _ error: String)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    private var notificationContent: [String: [String: String]] = [:]
    private var notificationsEnabled = true
    
    // Key for UserDefaults persistence
    private let kNotificationContentKey = "ag_region_monitor_notification_content"
    private let kNotificationsEnabledKey = "ag_region_monitor_notifications_enabled"

    override init() {
        super.init()
        locationManager.delegate = self
        
        // Load any saved notification content from previous sessions
        loadNotificationContent()
        loadNotificationEnable()
        
        requestNotificationPermission { granted in
            print("Notification permission: \(granted)")
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Persistence
    
    private func saveNotificationContent() {
        UserDefaults.standard.set(notificationContent, forKey: kNotificationContentKey)
    }
    
    private func loadNotificationContent() {
        if let savedContent = UserDefaults.standard.dictionary(forKey: kNotificationContentKey) as? [String: [String: String]] {
            notificationContent = savedContent
            print("Successfully loaded notification content from UserDefaults.")
        }
    }

      private func loadNotificationEnable() {
         if let isEnabled = UserDefaults.standard.bool(forKey: kNotificationsEnabledKey) as? Bool {
            notificationsEnabled = isEnabled
            print("Successfully loaded notification enable from UserDefaults.")
        }
    }
    
    // MARK: - Public Methods

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: kNotificationsEnabledKey)
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }
    
    func getLocationPermissionStatus() -> String {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined: return "notDetermined"
            case .denied: return "denied"
            case .restricted: return "restricted"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            @unknown default: return "unknown"
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined: return "notDetermined"
            case .denied: return "denied"
            case .restricted: return "restricted"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            @unknown default: return "unknown"
            }
        }
    }
    
    func setupCustomGeofence(
        latitude: Double,
        longitude: Double,
        radius: Double,
        identifier: String,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = false,
        notificationTitle: String? = nil,
        notificationBody: String? = nil
    ) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        
        // Store custom notification content and save it
        if let title = notificationTitle, let body = notificationBody {
            notificationContent[identifier] = ["title": title, "body": body]
            saveNotificationContent()
        }
        
        locationManager.startMonitoring(for: region)
        print("Geofence set for \(identifier) at (\(latitude), \(longitude)) with radius \(radius)m")
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func stopMonitoring(identifier: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
                // Remove the associated notification content and save changes
                if notificationContent.removeValue(forKey: identifier) != nil {
                    saveNotificationContent()
                }
                print("Stopped monitoring region: \(identifier)")
                break
            }
        }
    }
    
    func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        // Clear all notification content and save changes
        if !notificationContent.isEmpty {
            notificationContent.removeAll()
            saveNotificationContent()
        }
        locationManager.stopUpdatingLocation()
        print("Stopped all monitoring")
    }
    
    // MARK: - New Region Management Methods
    
    func getActiveRegions() -> [[String: Any]] {
        var regions: [[String: Any]] = []
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                var regionData: [String: Any] = [
                    "identifier": region.identifier,
                    "latitude": circularRegion.center.latitude,
                    "longitude": circularRegion.center.longitude,
                    "radius": circularRegion.radius,
                    "notifyOnEntry": region.notifyOnEntry,
                    "notifyOnExit": region.notifyOnExit
                ]
                if let content = notificationContent[region.identifier] {
                    regionData["notificationTitle"] = content["title"]
                    regionData["notificationBody"] = content["body"]
                }
                regions.append(regionData)
            }
        }
        return regions
    }
    
    func removeRegion(identifier: String) -> Bool {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
                // Remove notification content and save
                if notificationContent.removeValue(forKey: identifier) != nil {
                    saveNotificationContent()
                }
                print("Removed region: \(identifier)")
                return true
            }
        }
        print("Region not found: \(identifier)")
        return false
    }
    
    func removeAllRegions() {
        let regionCount = locationManager.monitoredRegions.count
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        // Clear all notification content and save
        if !notificationContent.isEmpty {
            notificationContent.removeAll()
            saveNotificationContent()
        }
        print("Removed all \(regionCount) regions")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("When In Use permission granted")
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("Always permission granted")
            startLocationUpdates()
        case .denied, .restricted:
            print("Location permission denied")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier)")
        sendLocalNotification(for: region.identifier)
        delegate?.didEnterRegion(region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        delegate?.didExitRegion(region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
        delegate?.monitoringDidFail(region?.identifier, error.localizedDescription)
    }
    
    private func sendLocalNotification(for regionIdentifier: String) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        
        if let notification = notificationContent[regionIdentifier],
           let title = notification["title"],
           let body = notification["body"] {
            content.title = title
            content.body = body
        } else {
            content.title = "📍 Region Alert"
            content.body = "You've entered region: \(regionIdentifier)"
        }
        
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
}