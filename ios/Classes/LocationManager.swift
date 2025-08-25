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
    private var notificationsRepeatEnabled = true
    private var notificationsRepeatTimer = 300 // 5 minutes in seconds
    
    // Key for UserDefaults persistence
    private let kNotificationContentKey = "ag_region_monitor_notification_content"
    private let kNotificationsEnabledKey = "ag_region_monitor_notifications_enabled"
    private let kNotificationsRepeatEnabled = "ag_region_monitor_repeat_enabled"
    private let kNotificationsRepeatTimer = "ag_region_monitor_notifications_timer"
    private let notificationIdentifierPrefix = "DangerZoneNotification"

    override init() {
        super.init()
        locationManager.delegate = self
        
        // 🔑 Set self as notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Load any saved notification content from previous sessions
        loadNotificationContent()
        loadNotificationEnable()
        loadNotificationsRepeatTimer()
        
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

        if let isRepeatEnabled = UserDefaults.standard.bool(forKey: kNotificationsRepeatEnabled) as? Bool {
            notificationsRepeatEnabled = isRepeatEnabled
            print("Successfully loaded notification repeat enable from UserDefaults.")
        }
    }

    private func loadNotificationsRepeatTimer() {
         if let timer = UserDefaults.standard.integer(forKey: kNotificationsRepeatTimer) as? Int {
            notificationsRepeatTimer = timer
            print("Successfully loaded notification timer from UserDefaults.")
        }
    }
    
    // MARK: - Public Methods

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: kNotificationsEnabledKey)
    }

    func setNotificationsRepeatEnabled(_ enabled: Bool) {
        notificationsRepeatEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: kNotificationsRepeatEnabled)
    }

    func setNotificationsRepeatTimer(_ timer: Int) {
        notificationsRepeatTimer = timer
        UserDefaults.standard.set(notificationsRepeatTimer, forKey: kNotificationsRepeatTimer)
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
        notifyOnExit: Bool = true,
        notificationTitle: String? = nil,
        notificationBody: String? = nil
    ) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = true
        
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
        cancelScheduledNotifications()
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
        cancelScheduledNotifications()
        print("Removed all \(regionCount) regions")
    }
    
    // MARK: - Manual Location Check
    
    func checkManualLocation(latitude: Double, longitude: Double) -> [[String: Any]] {
        let inputLocation = CLLocation(latitude: latitude, longitude: longitude)
        var matchingRegions: [[String: Any]] = []
        
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                let regionCenter = CLLocation(
                    latitude: circularRegion.center.latitude,
                    longitude: circularRegion.center.longitude
                )
                
                let distance = inputLocation.distance(from: regionCenter)
                
                if distance <= circularRegion.radius {
                    // Location is within this region
                    var regionData: [String: Any] = [
                        "identifier": region.identifier,
                        "latitude": circularRegion.center.latitude,
                        "longitude": circularRegion.center.longitude,
                        "radius": circularRegion.radius,
                        "notifyOnEntry": region.notifyOnEntry,
                        "notifyOnExit": region.notifyOnExit,
                        "distance": distance
                    ]
                    
                    if let content = notificationContent[region.identifier] {
                        regionData["notificationTitle"] = content["title"]
                        regionData["notificationBody"] = content["body"]
                    }
                    
                    matchingRegions.append(regionData)
                    
                    // Send notification for this region
                    sendLocalNotification(for: region.identifier)
                    
                    print("Manual location check: Found match in region \(region.identifier), distance: \(distance)m")
                }
            }
        }
        
        print("Manual location check: Found \(matchingRegions.count) matching regions for location (\(latitude), \(longitude))")
        
        return matchingRegions
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
        scheduleRepeatingNotifications(for: region.identifier)
        delegate?.didEnterRegion(region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        cancelScheduledNotifications(for: region.identifier)
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

    private func scheduleRepeatingNotifications(for regionIdentifier: String) {

        
        // Send immediate local notification
        sendLocalNotification(for: regionIdentifier)

        guard notificationsRepeatEnabled else { return }

        // Cancel any existing scheduled notifications first
        cancelScheduledNotifications()

        
        // Schedule notifications for the next 24 hours (288 notifications every 5 minutes)
        // iOS allows up to 64 scheduled notifications, so we'll schedule for the next 5 hours
        let maxNotifications = 60 // 5 hours worth of 5-minute intervals
        
        for i in 1...maxNotifications {
            let content = UNMutableNotificationContent()
            // content.title = "⚠️ Danger Zone"
            // content.body = "You are still in the danger zone in Karachi!"
            content.sound = .default

            if let notification = notificationContent[regionIdentifier],
               let title = notification["title"],
               let body = notification["body"] {
                content.title = title
                content.body = body
            } else {
                content.title = "📍 Region Alert"
                content.body = "You've entered region: \(regionIdentifier)"
            }
            
            // Schedule notification every 5 minutes (300 seconds)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i * notificationsRepeatTimer), repeats: false)
            let identifier = "\(notificationIdentifierPrefix)_\(regionIdentifier)_\(i)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification \(i): \(error.localizedDescription)")
                }
            }
        }
        
        print("Scheduled \(maxNotifications) background notifications every 5 minutes")
    }
    
    private func cancelScheduledNotifications() {
        // Get all pending notification identifiers that match our prefix
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(self.notificationIdentifierPrefix) }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            print("Cancelled \(identifiersToCancel.count) scheduled notifications")
        }
    }
    
    private func cancelScheduledNotifications(for regionIdentifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("\(self.notificationIdentifierPrefix)_\(regionIdentifier)_") }
            
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            
            print("Cancelled \(identifiersToCancel.count) scheduled notifications for region \(regionIdentifier)")
        }
    }
}

extension LocationManager: UNUserNotificationCenterDelegate {
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
