## 1.0.0

* Initial release for Region Monitoring in iOS.

## 1.0.1

* Changed minimum flutter version to ^3.29.0 and dart version to ^3.4.0

## 1.0.3

* Local notifications title and body can be customized for each region.
* Enable or Dislable local notifications.

## 1.0.4

* Added support for repeating notifications when the user enters a region
* Added ability to enable or disable repeating notifications
* Added option to configure repeat interval for notifications

## 1.0.5

### Added
- `checkManualLocation()` function to manually check if coordinates fall within active geofence regions
- `isLocationInAnyRegion()` convenience function for boolean location checks
- `getRegionsContainingLocation()` semantic alias for location queries
- Distance calculation and reporting for manual location checks
- Automatic notification triggering for manual location matches

### Enhanced
- Improved location validation with detailed region information
- Added comprehensive region data including distance from center