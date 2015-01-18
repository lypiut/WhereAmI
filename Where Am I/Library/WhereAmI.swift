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
    These profils define different location parameters (accuracy, distance update, ...).

    - Default: Default profil, good profil for general use case
    - Low:     Low accuracy profil
    - Medium:  Medium accuracy profil
    - High:    High accuracy profil, when you need the best location informations
*/
public enum WAILocationProfil : Int {
    case Default
    case Low
    case Medium
    case High
}

typealias WAIAuthorizationResult = (locationIsAuthorized : Bool) -> Void;
typealias WAILocationUpdate = (location : CLLocation) -> Void;
typealias WAIReversGeocodedLocationResult = (placemark : CLPlacemark?) -> Void;

// MARK: - Class Implementation

class WhereAmI : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager();
    /// Max location validity in seconds
    let locationValidity : NSTimeInterval = 15.0;
    var horizontalAccuracy : CLLocationDistance = 500.0;
    var continuousUpdate : Bool = false;
    var locationType : WAILocationAuthorization = WAILocationAuthorization.InUseAuthorization;
    var locationPrecision : WAILocationProfil {
        didSet {
            switch locationPrecision {
            case .Low:
                self.locationManager.distanceFilter = 500.0;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                self.horizontalAccuracy = 1000.0;
            case .Medium:
                self.locationManager.distanceFilter = 100.0;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                self.horizontalAccuracy = 200.0;
            case .High:
                self.locationManager.distanceFilter = 10.0;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                self.horizontalAccuracy = 50.0;
            case .Default:
                self.locationManager.distanceFilter = 50.0;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                self.horizontalAccuracy = 500.0;
            }
        }
    };
    
    var authorizationHandler : WAIAuthorizationResult?;
    var locationUpdateHandler : WAILocationUpdate?;
    
    // MARK: - Class methods
    
    class var sharedInstance: WhereAmI {
        struct Singleton {
            static let instance : WhereAmI = WhereAmI();
        }
        
        return Singleton.instance;
    }
    
    /**
        Check if the location authorization has been asked
    
        :returns: return false if the authorization is not determined, otherwise true
    */
    class func userHasBeenPromptedForLocationUse() -> Bool {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            return false;
        }
        
        return true;
    }
    
    /**
        Check if the localization is authorized
    
        :returns: false if the user's location was denied, otherwise true
    */
    class func locationIsAuthorized() -> Bool {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted) {
            return false;
        }
        
        if (!CLLocationManager.locationServicesEnabled()) {
            return false;
        }
        
        return true;
    }
    
    // MARK: - Object methods
    
    override init() {
        
        self.locationPrecision = WAILocationProfil.Default;
        
        super.init();
        
        self.locationManager.delegate = self;
    }
    
    /**
        All in one method, the easiest way to obtain the user's GPS coordinate
    
        :param: locationHandler        The closure return the latest valid user's positon
        :param: locationRefusedHandler When the user refuse location, this closure is called.
    */
    func whereAmI(locationHandler : WAILocationUpdate, locationRefusedHandler : WAIAuthorizationResult) {
        
        self.askLocationAuthorization({ [unowned self] (locationIsAuthorized) -> Void in
            
            if (locationIsAuthorized) {
                self.startUpdatingLocation(locationHandler);
            } else {
                locationRefusedHandler(locationIsAuthorized: locationIsAuthorized);
            }
        });
    }
    
    /**
        All in one methods, the easiest way to obtain the user's location (street, city, etc.)
    
        :param: geocoderHandler        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
        :param: locationRefusedHandler When the user refuse location, this closure is called.
    */
    func whatIsThisPlace(geocoderHandler : WAIReversGeocodedLocationResult, locationRefusedHandler : WAIAuthorizationResult) {
        
        self.whereAmI({ (location) -> Void in
            
            let geocoder = CLGeocoder();
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placesmark, error) -> Void in
                
                if (placesmark != nil && placesmark.count > 0) {
                    var placemark = placesmark.first as CLPlacemark;
                    geocoderHandler(placemark: placemark);
                } else {
                    geocoderHandler(placemark: nil);
                }
                
            });
            
            }, locationRefusedHandler: locationRefusedHandler);
    }
    
    /**
        Start the location update. If the continuousUpdate is at true the locationHandler will be used for each postion update.
    
        :param: locationHandler The closure returns an updated location conforms to the accuracy filters
    */
    func startUpdatingLocation(locationHandler : WAILocationUpdate?) {
        
        self.locationUpdateHandler = locationHandler;
        self.locationManager.startUpdatingLocation();
    }
    
    /**
        Stop the location update and release the location handler.
    */
    func stopUpdatingLocation() {
        
        self.locationManager.stopUpdatingLocation();
        self.locationUpdateHandler = nil;
    }
    
    /**
        Request location authorization
    
        :param: resultHandler The closure return if the authorization is granted or not
    */
    func askLocationAuthorization(resultHandler : WAIAuthorizationResult) {
        
        // if the authorization was already asked we return the result
        if (WhereAmI.userHasBeenPromptedForLocationUse()) {
            
            resultHandler(locationIsAuthorized: WhereAmI.locationIsAuthorized());
            return;
        }
        
        self.authorizationHandler = resultHandler;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            
            if (self.locationType == WAILocationAuthorization.AlwaysAuthorization) {
                self.locationManager.requestAlwaysAuthorization();
            } else {
                self.locationManager.requestWhenInUseAuthorization();
            }
        } else if (!CLLocationManager.locationServicesEnabled()) {
            //In order to prompt the authorization alert view
            self.startUpdatingLocation(nil);
        }
    }
    
    deinit {
        //Cleaning closure
        self.locationUpdateHandler = nil;
        self.authorizationHandler = nil;
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (self.authorizationHandler != nil) {
            
            if (status == CLAuthorizationStatus.Authorized || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
                self.authorizationHandler!(locationIsAuthorized: true);
                self.authorizationHandler = nil;
            }
            else if (status != CLAuthorizationStatus.NotDetermined){
                self.authorizationHandler!(locationIsAuthorized: false);
                self.authorizationHandler = nil;
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if (locations.count > 0) {
            
            let latestPosition = locations.first as CLLocation;
            let locationAge = -latestPosition.timestamp.timeIntervalSinceNow;
            
            //Check if the location data is valid for the accuracy profil selected
            if (locationAge < self.locationValidity && CLLocationCoordinate2DIsValid(latestPosition.coordinate) && latestPosition.horizontalAccuracy < self.horizontalAccuracy) {
                
                if (self.locationUpdateHandler != nil) {
                    self.locationUpdateHandler!(location : latestPosition);
                }
                
                if (!self.continuousUpdate) {
                    self.stopUpdatingLocation();
                    self.locationUpdateHandler = nil;
                }
            }
        }
    }
}
