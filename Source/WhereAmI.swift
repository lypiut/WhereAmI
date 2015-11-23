// WhereAmI.swift
//
// Copyright (c) 2014 Romain Rivollier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CoreLocation

/**
Location authorization type

- AlwaysAuthorization: The location is updated even if the application is in background
- InUseAuthorization:  The location is updated when the application is running
*/
public enum WAILocationAuthorization : Int {
    case AlwaysAuthorization
    case InUseAuthorization
}

/**
These profils represent different location parameters (accuracy, distance update, ...).
Look at the didSet method of the locationPrecision variable for more informations

- Default: This profil can be used for most of your usage
- Low:     Low accuracy profil
- Medium:  Medium accuracy profil
- High:    High accuracy profil, when you need the best location
*/
public enum WAILocationProfil : Int {
    case Default
    case Low
    case Medium
    case High
}

public typealias WAIAuthorizationResult = (locationIsAuthorized : Bool) -> Void
public typealias WAILocationUpdate = (location : CLLocation) -> Void
public typealias WAIReversGeocodedLocationResult = (placemark : CLPlacemark?) -> Void
public typealias WAILocationAuthorizationRefused = () -> Void

// MARK: - Class Implementation

public class WhereAmI : NSObject, CLLocationManagerDelegate {
    
    // Singleton
    public static let sharedInstance = WhereAmI()
    
    public let locationManager = CLLocationManager()
    /// Max location validity in seconds
    public let locationValidity : NSTimeInterval = 15.0
    public var horizontalAccuracy : CLLocationDistance = 500.0
    public var continuousUpdate : Bool = false
    public var locationAuthorization : WAILocationAuthorization = .InUseAuthorization
    public var locationPrecision : WAILocationProfil {
        didSet {
            switch locationPrecision {
            case .Low:
                self.locationManager.distanceFilter = 500.0
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                self.horizontalAccuracy = 2000.0
            case .Medium:
                self.locationManager.distanceFilter = 100.0
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.horizontalAccuracy = 1000.0
            case .High:
                self.locationManager.distanceFilter = 10.0
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.horizontalAccuracy = 200.0
            case .Default:
                self.locationManager.distanceFilter = 50.0
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.horizontalAccuracy = 500.0
            }
        }
    }
    
    var authorizationHandler : WAIAuthorizationResult?;
    var locationUpdateHandler : WAILocationUpdate?;
    
    // MARK: - Class methods
    
    /**
    Check if the location authorization has been asked
    
    - returns: return false if the authorization has not been asked, otherwise true
    */
    public class func userHasBeenPromptedForLocationUse() -> Bool {
        
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            return false
        }
        
        return true;
    }
    
    /**
    Check if the localization is authorized
    
    - returns: false if the user's location was denied, otherwise true
    */
    public class func locationIsAuthorized() -> Bool {
        
        if (CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted) {
            return false
        }
        
        if (!CLLocationManager.locationServicesEnabled()) {
            return false
        }
        
        return true
    }
    
    // MARK: - Object methods
    
    override init() {
        
        self.locationPrecision = WAILocationProfil.Default
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    /**
    All in one method, the easiest way to obtain the user's GPS coordinate
    
    - parameter locationHandler:        The closure return the latest valid user's positon
    - parameter locationRefusedHandler: When the user refuse location, this closure is called.
    */
    public func whereAmI(locationHandler : WAILocationUpdate, locationRefusedHandler : WAILocationAuthorizationRefused) {
        
        self.askLocationAuthorization({ [unowned self] (locationIsAuthorized) -> Void in
            
            if (locationIsAuthorized) {
                self.startUpdatingLocation(locationHandler)
            } else {
                locationRefusedHandler()
            }
            });
    }
    
    /**
    All in one method, the easiest way to obtain the user's location (street, city, etc.)
    
    - parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
    - parameter locationRefusedHandler: When the user refuse location, this closure is called.
    */
    public func whatIsThisPlace(geocoderHandler : WAIReversGeocodedLocationResult, locationRefusedHandler : WAILocationAuthorizationRefused) {
        
        self.whereAmI({ (location) -> Void in
            
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placesmark, error) -> Void in
                
                if let anError = error {
                    #if DEBUG
                        print("[WHERE AM I]Reverse geocode fail: \(anError.localizedDescription)")
                    #endif
                    geocoderHandler(placemark: nil)
                    return
                }
                
                if let aPlacesmark = placesmark where aPlacesmark.count > 0 {
                    
                    if let placemark = aPlacesmark.first {
                        geocoderHandler(placemark: placemark)
                    }
                } else {
                    geocoderHandler(placemark: nil)
                }
                
            });
            
            }, locationRefusedHandler: locationRefusedHandler)
    }
    
    /**
    Start the location update. If the continuousUpdate is at true the locationHandler will be used for each postion update.
    
    - parameter locationHandler: The closure returns an updated location conforms to the accuracy filters
    */
    public func startUpdatingLocation(locationHandler : WAILocationUpdate?) {
        
        self.locationUpdateHandler = locationHandler
        
        if #available(iOS 9, *) {
            if self.continuousUpdate == false {
                self.locationManager.allowsBackgroundLocationUpdates = true;
                 self.locationManager.requestLocation()
            } else {
                self.locationManager.startUpdatingLocation()
            }
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    /**
    Stop the location update and release the location handler.
    */
    public func stopUpdatingLocation() {
        
        self.locationManager.stopUpdatingLocation()
        self.locationUpdateHandler = nil
    }
    
    /**
    Request location authorization
    
    - parameter resultHandler: The closure return if the authorization is granted or not
    */
    public func askLocationAuthorization(resultHandler : WAIAuthorizationResult) {
        
        // if the authorization was already asked we return the result
        if (WhereAmI.userHasBeenPromptedForLocationUse()) {
            
            resultHandler(locationIsAuthorized: WhereAmI.locationIsAuthorized())
            return
        }
        
        self.authorizationHandler = resultHandler
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            
            if (self.locationAuthorization == WAILocationAuthorization.AlwaysAuthorization) {
                self.locationManager.requestAlwaysAuthorization()
            } else {
                self.locationManager.requestWhenInUseAuthorization()
            }
        } else {
            //In order to prompt the authorization alert view
            self.startUpdatingLocation(nil)
        }
    }
    
    deinit {
        //Cleaning closure
        self.locationUpdateHandler = nil
        self.authorizationHandler = nil
    }
    
    // MARK: - CLLocationManager Delegate
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
            self.authorizationHandler?(locationIsAuthorized: true);
            self.authorizationHandler = nil;
        }
        else if (status != .NotDetermined){
            self.authorizationHandler?(locationIsAuthorized: false)
            self.authorizationHandler = nil
        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        #if DEBUG
            print("[WHERE AM I]locationManager fail: \(error.localizedDescription)")
        #endif
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get the latest location data
        guard let latestPosition = locations.last else {
            //No location data
            return
        }
        
        let locationAge = -latestPosition.timestamp.timeIntervalSinceNow
        
        //Check if the location is valid for the accuracy profil selected
        if (locationAge < self.locationValidity && CLLocationCoordinate2DIsValid(latestPosition.coordinate) && latestPosition.horizontalAccuracy < self.horizontalAccuracy) {
            
            self.locationUpdateHandler?(location : latestPosition)
            
            if (!self.continuousUpdate) {
                self.stopUpdatingLocation()
            }
        }
    }
}

/**
Out of the box function, the easiest way to obtain the user's GPS coordinate

- parameter locationHandler:        The closure return the latest valid user's positon
- parameter locationRefusedHandler: When the user refuse location, this closure is called.
*/
public func whereAmI(locationHandler : WAILocationUpdate, locationRefusedHandler : WAILocationAuthorizationRefused) {
    WhereAmI.sharedInstance.whereAmI(locationHandler, locationRefusedHandler : locationRefusedHandler)
}

/**
Out of the box function, the easiest way to obtain the user's location (street, city, etc.)

- parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
- parameter locationRefusedHandler: When the user refuse location, this closure is called.
*/
public func whatIsThisPlace(geocoderHandler : WAIReversGeocodedLocationResult, locationRefusedHandler : WAILocationAuthorizationRefused) {
    WhereAmI.sharedInstance.whatIsThisPlace(geocoderHandler, locationRefusedHandler : locationRefusedHandler);
}

