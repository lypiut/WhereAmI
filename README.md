# WhereAmI

[![Version](http://cocoapod-badges.herokuapp.com/v/WhereAmI/badge.png)](http://cocoadocs.org/docsets/WhereAmI)
[![Platform](http://cocoapod-badges.herokuapp.com/p/WhereAmI/badge.png)](http://cocoadocs.org/docsets/WhereAmI)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/lypiut/WhereAmI.svg?branch=master)](https://travis-ci.org/lypiut/WhereAmI)

An easy to use Core Location library in Swift with few lines of code you can obtain:
- the current location
- the current address


## Requirement

- Swift 4
- Xcode 9
- iOS 8.0+
- watchOS 2.0
- tvOS 9.0

## Installation

### CocoaPods

WhereAmI is available through [CocoaPods](http://cocoapods.org).  

You can install it with the following command:

```
$ gem install cocoapods
```

To integrate WhereAmI, add the following line to your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'WhereAmI', '~> 4.0'
```

### Carthage

Carthage is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate WhereAmI into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "lypiut/WhereAmI" >= 4.0
```

### Manual Installation

Just drop the *.swift* files, located in the `Source` folder, into your project.

## How to use

### Request access to Location Services

WhereAmI automatically handles permission requests to access location services.

Don't forget to set the key `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` in your app's `Info.plist`.  

By default WhereAmI requests the "When in use" permission but you have the possibility to set the "Always" permission by changing the `locationAuthorization` variable.

```swift
WhereAmI.sharedInstance.locationAuthorization = .AlwaysAuthorization
```

### Set accuracy profile

WhereAmI provides 4 location profiles which affect the accuracy of the location:

```swift
Default 	// Good mix between precision and location speed with an accuracy of ~200m
Low 		// Low precision and fast location speed with an accuracy of ~2000m
Medium		// Medium precision and an accuracy of ~500m
High		// High precision and low location speed with an accuracy of ~10m
```

You can also create your own location profile with the `LocationProfile` protocol.

### Get current location

To obtain the current location use the `whereAmI` method.
The location request is executed once by default. If you want a continuous update of the location set the `continuousUpdate` to true.

```swift
//If you want continuous update
WhereAmI.sharedInstance.continuousUpdate = true;

//Request the current location
whereAmI { response in

  switch response {
  case .locationUpdated(let location):
    //location updated
  case .locationFail(let error):
    //An error occurred
  case .unauthorized:
    //The location authorization has been refused
  }
}
```

### Get current address

You have the possibility to retrieve informations about the current location (street, city, etc.) with the `whatIsThisPlace` method.

```swift
whatIsThisPlace { (response) -> Void in

  switch response {
  case .success(let placemark):
    //reverse geocoding succeed
  case .placeNotFound:
    // no place found
  case .failure(let error):
    // an error occurred
  case .unauthorized:
    //The location authorization has been refused
  }
}
```
## Example project

More examples are available in the `Example` folder.

## Issues & Contributions

For any bug or suggestion open an issue on GitHub.

## License

WhereAmI is available under the MIT license. See the LICENSE file for more info.
