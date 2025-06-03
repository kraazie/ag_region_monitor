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
    
    override init() {
        super.init()
        locationManager.delegate = self
        // locationManager.requestAlwaysAuthorization()
        // startLocationUpdates()
        // setupDefaultGeofence()
        requestNotificationPermission { granted in
            print("Notification permission: \(granted)")
        }
        // Start with "When In Use" permission first
        locationManager.requestWhenInUseAuthorization()

    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }
    
func getLocationPermissionStatus() -> String {
    if #available(iOS 14.0, *) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .authorizedAlways:
            return "authorizedAlways"
        @unknown default:
            return "unknown"
        }
    } else {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .authorizedAlways:
            return "authorizedAlways"
        @unknown default:
            return "unknown"
        }
    }
}

    
    private func setupDefaultGeofence() {
        setupCustomGeofence(
            latitude: 24.8615,
            longitude: 67.0099,
            radius: 200,
            identifier: "KarachiDangerZone",
            notifyOnEntry: true,
            notifyOnExit: false
        )
    }
    
    func setupCustomGeofence(
        latitude: Double,
        longitude: Double,
        radius: Double,
        identifier: String,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = false
    ) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        
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
                print("Stopped monitoring region: \(identifier)")
                break
            }
        }
    }
    
    func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        locationManager.stopUpdatingLocation()
        print("Stopped all monitoring")
    }
    
    // MARK: - New Region Management Methods
    
    func getActiveRegions() -> [[String: Any]] {
        var regions: [[String: Any]] = []
        
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                let regionData: [String: Any] = [
                    "identifier": region.identifier,
                    "latitude": circularRegion.center.latitude,
                    "longitude": circularRegion.center.longitude,
                    "radius": circularRegion.radius,
                    "notifyOnEntry": region.notifyOnEntry,
                    "notifyOnExit": region.notifyOnExit
                ]
                regions.append(regionData)
            }
        }
        
        return regions
    }
    
    func removeRegion(identifier: String) -> Bool {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
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
            setupDefaultGeofence()

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
        let content = UNMutableNotificationContent()
        
        if regionIdentifier == "KarachiDangerZone" {
            content.title = "⚠️ Danger Zone"
            content.body = "You've entered a danger zone in Karachi!"
        } else {
            content.title = "📍 Region Alert"
            content.body = "You've entered region: \(regionIdentifier)"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}