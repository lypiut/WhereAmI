# WhereAmI

[![Version](http://cocoapod-badges.herokuapp.com/v/WhereAmI/badge.png)](http://cocoadocs.org/docsets/WhereAmI)
[![Platform](http://cocoapod-badges.herokuapp.com/p/WhereAmI/badge.png)](http://cocoadocs.org/docsets/WhereAmI)
[![Build Status](https://travis-ci.org/lypiut/WhereAmI.svg?branch=master)](https://travis-ci.org/lypiut/WhereAmI)

An easy to use Core Location library in Swift with few lines of code you can obtain:
- the current location
- the current address


##Requirement

- Xcode 6
- iOS 7.0+

## Installation

###Cocoa Pods

WhereAmI is available through [CocoaPods](http://cocoapods.org).  
(WARNING: Swift support for cocoapods is starting since 0.36 beta 1)

To install WhereAmI, add the following line to your Podfile:

```
pod 'WhereAmI', '~> 1.1'
```

###Manual Installation

Just drop the class file *WhereAmI.swift*, located in the `Source` folder, into your project.

##How to use

###Request access to Location Services

WhereAmI automatically handles permission requests to access location services.

Don't forget to set the key `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` in your app's `Info.plist`.  

By default WhereAmI requests the "When in use" permission but you have the possibility to set the "Always" permission by changing the `locationAuthorization` variable.

```swift
WhereAmI.sharedInstance.locationAuthorization = WAILocationAuthorization.AlwaysAuthorization
```

###Set accuracy profile

WhereAmI provides 4 location profiles which affect the accuracy of the location:

```swift
Default 	// Good mix between precision and location speed with an accuracy of ~200m
Low 		// Low precision and fast location speed with an accuracy of ~2000m	
Medium		// Medium precision and an accuracy of ~500m
High		// High precision and low location speed with an accuracy of ~10m
```

These profiles are basic for the moment but they will evolve in future releases.

###Get current location

To obtain the current location use the `whereAmI` method.
The location request is executed once by default. If you want a continuous update of the location set the `continuousUpdate` to true.

```swift
//If you want continuous update
WhereAmI.sharedInstance.continuousUpdate = true;

//Request the current location
WhereAmI.sharedInstance.whereAmI({ (location) -> Void in
            
        //Use the location data        
    }, locationRefusedHandler: {() -> Void in
                
        //The location authorization has been refused
});
```

###Get current address 

You have the possibility to retrieve informations about the current location (street, city, etc.) with the `whatIsThisPlace` method.

```swift
WhereAmI.sharedInstance.whatIsThisPlace({ (placemark) -> Void in
            
    	if (placemark != nil) {
        	//Do your stuff
    	} 
    }, locationRefusedHandler: {() -> Void in
                
        //The location authorization has been refused
});
```
##Example project

More examples are available in the `Example` folder.

##Issues & Contributions

For any bug or suggestion open an issue on GitHub.

##License

WhereAmI is available under the MIT license. See the LICENSE file for more info.
