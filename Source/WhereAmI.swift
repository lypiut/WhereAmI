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
    case alwaysAuthorization
    case inUseAuthorization
}

/**
 Represent responses returned when you call the whereAmI method
 
 - LocationUpdated: Location retrieved with success, contains a CLLocation object
 - LocationFail:    The CLLocationManager fails to retreive the current location
 - Unauthorized:    The user unauthorized the geolocation
 */
public enum WAILocationResponse {
    case locationUpdated(CLLocation)
    case locationFail(NSError)
    case unauthorized
}

/**
 Represent responses returned when you call the whatIsThisPlace method
 
 - Success:         The reverse geocoding retrieve the current place
 - Failure:         An error occured during the reverse geocoding
 - PlaceNotFound:   No place was found for the given coordinate
 - Unauthorized:    The user unauthorized the geolocation
 */
public enum WAIGeocoderResponse {
    case success(CLPlacemark)
    case failure(NSError)
    case placeNotFound
    case unauthorized
}

public typealias WAIAuthorizationResult = (_ locationIsAuthorized : Bool) -> Void
public typealias WAILocationUpdate = (_ response : WAILocationResponse) -> Void
public typealias WAIReversGeocodedLocationResult = (_ response : WAIGeocoderResponse) -> Void

// MARK: - Class Implementation

public final class WhereAmI : NSObject {
    
    // Singleton
    public static let sharedInstance = WhereAmI()
    
    open let locationManager = CLLocationManager()
    /// Max location validity in seconds
    open var locationValidity : TimeInterval = 40.0
    open var horizontalAccuracy : CLLocationDistance = 500.0
    open var continuousUpdate : Bool = false
    open var locationAuthorization : WAILocationAuthorization = .inUseAuthorization
    open var locationPrecision : LocationProfile {
        didSet {
            self.locationManager.distanceFilter = locationPrecision.distanceFilter
            self.locationManager.desiredAccuracy = locationPrecision.desiredAccuracy
            self.horizontalAccuracy = locationPrecision.horizontalAccuracy
        }
    }
    
    var authorizationHandler : WAIAuthorizationResult?;
    var locationUpdateHandler : WAILocationUpdate?;
    
    fileprivate lazy var geocoder : CLGeocoder = CLGeocoder()
    
    // MARK: - Class methods
    
    /**
     Check if the location authorization has been asked
     
     - returns: return false if the authorization has not been asked, otherwise true
     */
    open class func userHasBeenPromptedForLocationUse() -> Bool {
        
        return CLLocationManager.authorizationStatus() != .notDetermined
    }
    
    /**
     Check if the localization is authorized
     
     - returns: false if the user's location was denied, otherwise true
     */
    open class func locationIsAuthorized() -> Bool {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        
        if authorizationStatus == .denied || authorizationStatus == .restricted || locationServicesEnabled == false {
            return false
        }
        
        return true
    }
    
    // MARK: - Object methods
    
    override init() {
        
        self.locationPrecision = WAILocationProfile.default
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    /**
     All in one method, the easiest way to obtain the user's GPS coordinate
     
     - parameter locationHandler:        The closure return the latest valid user's positon
     */
    open func whereAmI(_ locationHandler : @escaping WAILocationUpdate) {
        
        self.askLocationAuthorization{ [weak self] (locationIsAuthorized) -> Void in
            
            if locationIsAuthorized {
                self?.startUpdatingLocation(locationHandler)
            } else {
                locationHandler(.unauthorized)
            }
        }
    }
    
    /**
     All in one method, the easiest way to obtain the user's location (street, city, etc.)
     
     - parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
     - parameter locationRefusedHandler: When the user refuse location, this closure is called.
     */
    open func whatIsThisPlace(_ geocoderHandler : @escaping WAIReversGeocodedLocationResult) {
        
        self.whereAmI({ [weak self] (location) -> Void in
            
            switch location {
            case let .locationUpdated(location):
                self?.geocoder.cancelGeocode()
                self?.geocoder.reverseGeocodeLocation(location, completionHandler: { (placesmark, error) -> Void in
                    
                    if let anError = error {
                        geocoderHandler(.failure(anError as NSError))
                        return
                    }
                    
                    if let placemark = placesmark?.first {
                        geocoderHandler(.success(placemark))
                    } else {
                        geocoderHandler(.placeNotFound)
                    }
                })
            case let .locationFail(error):
                geocoderHandler(.failure(error))
            case .unauthorized:
                geocoderHandler(.unauthorized)
            }
            })
    }
    
    /**
     Start the location update. If the continuousUpdate is at true the locationHandler will be used for each postion update.
     
     - parameter locationHandler: The closure returns an updated location conforms to the accuracy filters
     */
    open func startUpdatingLocation(_ locationHandler : WAILocationUpdate?) {
        
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
                
                if locationAuthorization == .alwaysAuthorization {
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
    open func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
        locationUpdateHandler = nil
    }
    
    /**
     Request location authorization
     
     - parameter resultHandler: The closure return if the authorization is granted or not
     */
    open func askLocationAuthorization(_ resultHandler : @escaping WAIAuthorizationResult) {
        
        // if the authorization was already asked we return the result
        if WhereAmI.userHasBeenPromptedForLocationUse() {
            
            resultHandler(WhereAmI.locationIsAuthorized())
            return
        }
        
        self.authorizationHandler = resultHandler
        
        #if os(iOS)
            if locationAuthorization == .alwaysAuthorization {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        #elseif os(watchOS)
            if self.locationAuthorization == .alwaysAuthorization {
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
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationHandler?(true);
        case .notDetermined, .denied, .restricted:
            authorizationHandler?(false)
        }
        
        authorizationHandler = nil;
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationUpdateHandler?(.locationFail(error as NSError))
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get the latest location data
        guard let latestPosition = locations.first else { return }
        
        let locationAge = -latestPosition.timestamp.timeIntervalSinceNow
        
        //Check if the location is valid for the accuracy profil selected
        if locationAge < locationValidity && CLLocationCoordinate2DIsValid(latestPosition.coordinate) && latestPosition.horizontalAccuracy < horizontalAccuracy {
            
            locationUpdateHandler?(.locationUpdated(latestPosition))
            
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
public func whereAmI(_ locationHandler : @escaping WAILocationUpdate) {
    WhereAmI.sharedInstance.whereAmI(locationHandler)
}

/**
 Out of the box function, the easiest way to obtain the user's location (street, city, etc.)
 
 - parameter geocoderHandler:        The closure return a placemark corresponding to the current user's location. If an error occured it return nil
 - parameter locationRefusedHandler: When the user refuse location, this closure is called.
 */
public func whatIsThisPlace(_ geocoderHandler : @escaping WAIReversGeocodedLocationResult) {
    WhereAmI.sharedInstance.whatIsThisPlace(geocoderHandler);
}

