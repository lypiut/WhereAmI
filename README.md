# WhereAmI

An easy to use Core Location library in Swift, with few lines of code you can obtain
- The current location
- The current address


##Requirement

- Xcode 6
- iOS 7.0+

## Installation

###Cocoa Pods

WhereAmI is available through [CocoaPods](http://cocoapods.org).  
(WARNING: The Swift support is only available in the 0.36 beta 1)

To install add the following line to your Podfile:

```
pod 'WhereAmI'
```

###Manual Installation

Just drop the class file *WhereAmI.swift* located in the Source folder into your project.

##How to use

###Request access to location service

WhereAmI automatically handles permission request to access location services.

Don't forget to set the key `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` in your app's `Info.plist`.  

By default WhereAmI requests the "When in use" permission but you have the possibility to set the "Always" permission by changing the `locationAuthorization` variable.

```swift
WhereAmI.sharedInstance.locationAuthorization = WAILocationAuthorization.AlwaysAuthorization;
```

###Set accuracy profil

WhereAmI provides 4 location profiles which influencing the accuracy of the location:

```swift
Default 	// Good mix between precision, location speed. 200m of accuracy
Low 		// Low precision, fast location speed 2000m of accuracy	
Medium		// Medium precision. 500m of accuracy
High		// High precision, the location update can take several time to obtain data for the desired accuracy 10m accuracy
```

These profiles are basic for the moment but they will evolve in future release.

###Get current location
 
The location request is executed once by default. If you want a continuous updates of the location set the `continuousUpdate` at true.

```swift
//If you want continuous update
WhereAmI.sharedInstance.continuousUpdate = true;

//Request the current location
WhereAmI.sharedInstance.whereAmI({ (location) -> Void in
            
    //Use the location data        
    }, locationRefusedHandler: {(locationIsAuthorized) -> Void in
                
        if (!locationIsAuthorized) {
            //The location authorization is refused
        }
});
```

###Get current address 

```swift
WhereAmI.sharedInstance.whatIsThisPlace({ (placemark) -> Void in
            
    	if (placemark != nil) {
        	//Do your stuff
    	} 
    }, locationRefusedHandler: {(locationIsAuthorized) -> Void in
                
        if (!locationIsAuthorized) {
            //The location authorization is refused
        }
});
```
##Example project

More examples are available in the demo project.

##Issues & Contributions

For any bug or suggestion open an issue on GitHub.

##License

WhereAmI is available under the MIT license. See the LICENSE file for more info.