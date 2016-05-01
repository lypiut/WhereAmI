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

import CoreLocation

/**
Location authorization type

- AlwaysAuthorization: The location is updated even if the application is in background
- InUseAuthorization:  The location is updated when the application is running
*/
public enum WAILocationAuthorization {
    @available(iOS 7, watchOS 2, *)
    case AlwaysAuthorization 
    case InUseAuthorization
}

/**
 Represent responses returned when you call the whereAmI method
 
 - LocationUpdated: Location retrieved with success, contains a CLLocation object
 - LocationFail:    The CLLocationManager fails to retreive the current location
 - Unauthorized:    The user unauthorized the geolocation
 */
public enum WAILocationResponse {
    case LocationUpdated(CLLocation)
    case LocationFail(NSError)
    case Unauthorized
}

/**
 Represent responses returned when you call the whatIsThisPlace method
 
 - Success:         The reverse geocoding retrieve the current place
 - Failure:         An error occured during the reverse geocoding
 - PlaceNotFound:   No place was found for the given coordinate
 - Unauthorized:    The user unauthorized the geolocation
 */
public enum WAIGeocoderResponse {
    case Success(CLPlacemark)
    case Failure(NSError)
    case PlaceNotFound
    case Unauthorized
}

public typealias WAIAuthorizationResult = (locationIsAuthorized : Bool) -> Void
public typealias WAILocationUpdate = (response : WAILocationResponse) -> Void
public typealias WAIReversGeocodedLocationResult = (response : WAIGeocoderResponse) -> Void

// MARK: - Class Implementation

public class WhereAmI : NSObject {
    
    // Singleton
    public static let sharedInstance = WhereAmI()
    
    public let locationManager = CLLocationManager()
    /// Max location validity in seconds
    public var locationValidity : NSTimeInterval = 40.0
    public var horizontalAccuracy : CLLocationDistance = 500.0
    public var continuousUpdate : Bool = false
    public var locationAuthorization : WAILocationAuthorization = .InUseAuthorization
    public var locationPrecision : LocationProfile {
        didSet {
            self.locationManager.distanceFilter = locationPrecision.distanceFilter
            self.locationManager.desiredAccuracy = locationPrecision.desiredAccuracy
            self.horizontalAccuracy = locationPrecision.horizontalAccuracy
        }
    }
    
    var authorizationHandler : WAIAuthorizationResult?;
    var locationUpdateHandler : WAILocationUpdate?;
    
    private lazy var geocoder : CLGeocoder = {
        return CLGeocoder()
    }()
    
    // MARK: - Class methods
    
    /**
    Check if the location authorization has been asked
    
    - returns: return false if the authorization has not been asked, otherwise true
    */
    public class func userHasBeenPromptedForLocationUse() -> Bool {
        
        return CLLocationManager.authorizationStatus() != .NotDetermined
    }
    
    /**
    Check if the localization is authorized
    
    - returns: false if the user's location was denied, otherwise true
    */
    public class func locationIsAuthorized() -> Bool {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        
        if authorizationStatus == .Denied || authorizationStatus == .Restricted || locationServicesEnabled == false {
            return false
        }
        
        return true
    }
    
    // MARK: - Object methods
    
    override init() {
        
        self.locationPrecision = WAILocationProfile.Default
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    /**
    All in one method, the easiest way to obtain the user's GPS coordinate
    
    - parameter locationHandler:        The closure return the latest valid user's positon
    */
    public func whereAmI(locationHandler : WAILocationUpdate) {
        
        self.askLocationAuthorization{ [weak self] (locationIsAuthorized) -> Void in
            
            if locationIsAuthorized {
                self?.startUpdatingLocation(locationHandler)
            } else {
                locationHandler(response: .Unauthorized)
            }
        }
    }
    
    /**
    All in one method, the easiest way to obtain the user's location (street, city, etc.)
    
    - parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
    - parameter locationRefusedHandler: When the user refuse location, this closure is called.
    */
    public func whatIsThisPlace(geocoderHandler : WAIReversGeocodedLocationResult) {
        
        self.whereAmI({ [weak self] (location) -> Void in
            
            switch location {
            case let .LocationUpdated(location):
                self?.geocoder.cancelGeocode()
                self?.geocoder.reverseGeocodeLocation(location, completionHandler: { (placesmark, error) -> Void in
                    
                    if let anError = error {
                        geocoderHandler(response: .Failure(anError))
                        return
                    }
                    
                    if let placemark = placesmark?.first {
                        geocoderHandler(response: .Success(placemark))
                    } else {
                        geocoderHandler(response: .PlaceNotFound)
                    }
                })
            case let .LocationFail(error):
                geocoderHandler(response: .Failure(error))
            case .Unauthorized:
                geocoderHandler(response: .Unauthorized)
            }
        })
    }
    
    /**
    Start the location update. If the continuousUpdate is at true the locationHandler will be used for each postion update.
    
    - parameter locationHandler: The closure returns an updated location conforms to the accuracy filters
    */
    public func startUpdatingLocation(locationHandler : WAILocationUpdate?) {
        
        self.locationUpdateHandler = locationHandler
        
        #if os(watchOS) || os(tvOS)
            locationManager.requestLocation()
        #elseif os(iOS)
            if #available(iOS 9, *) {
                if continuousUpdate == false {
                    locationManager.requestLocation()
                } else {
                    locationManager.startUpdatingLocation()
                }
                
                if locationAuthorization == .AlwaysAuthorization {
                    locationManager.allowsBackgroundLocationUpdates = true
                }
                
            } else {
                locationManager.startUpdatingLocation()
            }
        #endif
    }
    
    /**
    Stop the location update and release the location handler.
    */
    public func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
        locationUpdateHandler = nil
    }
    
    /**
    Request location authorization
    
    - parameter resultHandler: The closure return if the authorization is granted or not
    */
    public func askLocationAuthorization(resultHandler : WAIAuthorizationResult) {
        
        // if the authorization was already asked we return the result
        if WhereAmI.userHasBeenPromptedForLocationUse() {
            
            resultHandler(locationIsAuthorized: WhereAmI.locationIsAuthorized())
            return
        }
        
        self.authorizationHandler = resultHandler
        
        #if os(iOS)
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
    
                if locationAuthorization == .AlwaysAuthorization {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            } else {
                //In order to prompt the authorization alert view
                startUpdatingLocation(nil)
            }
        #elseif os(watchOS)
            if self.locationAuthorization == .AlwaysAuthorization {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        #elseif os(tvOS)
            locationManager.requestWhenInUseAuthorization()
        #endif
    }
    
    deinit {
        //Cleaning closure
        locationUpdateHandler = nil
        authorizationHandler = nil
    }
}

extension WhereAmI : CLLocationManagerDelegate {
    
    // MARK: - CLLocationManager Delegate
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            authorizationHandler?(locationIsAuthorized: true);
        case .NotDetermined, .Denied, .Restricted:
            authorizationHandler?(locationIsAuthorized: false)
        }
        
        authorizationHandler = nil;
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.locationUpdateHandler?(response: .LocationFail(error))
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get the latest location data
        guard let latestPosition = locations.first else { return }
        
        let locationAge = -latestPosition.timestamp.timeIntervalSinceNow
        
        //Check if the location is valid for the accuracy profil selected
        if locationAge < locationValidity && CLLocationCoordinate2DIsValid(latestPosition.coordinate) && latestPosition.horizontalAccuracy < horizontalAccuracy {
            
            locationUpdateHandler?(response : .LocationUpdated(latestPosition))
            
            if continuousUpdate == false {
                stopUpdatingLocation()
            }
        }
    }
}

/**
Out of the box function, the easiest way to obtain the user's GPS coordinate

- parameter locationHandler:        The closure return the latest valid user's positon
- parameter locationRefusedHandler: When the user refuse location, this closure is called.
*/
public func whereAmI(locationHandler : WAILocationUpdate) {
    WhereAmI.sharedInstance.whereAmI(locationHandler)
}

/**
Out of the box function, the easiest way to obtain the user's location (street, city, etc.)

- parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
- parameter locationRefusedHandler: When the user refuse location, this closure is called.
*/
public func whatIsThisPlace(geocoderHandler : WAIReversGeocodedLocationResult) {
    WhereAmI.sharedInstance.whatIsThisPlace(geocoderHandler);
}

