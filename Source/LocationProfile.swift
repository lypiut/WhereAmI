// WhereAmI.swift
//
// Copyright (c) 2016 Romain Rivollier
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
 *  The locationProfil protocol allows you to create custom precision profil
 */
public protocol LocationProfile {
    
    var distanceFilter : CLLocationDistance { get }
    var desiredAccuracy : CLLocationAccuracy { get }
    var horizontalAccuracy : CLLocationDistance { get }
}

/**
 These profils represent different location parameters (accuracy, distance update, ...).
 
 - Default: This profil can be used for most of your usage
 - Low:     Low accuracy profil
 - Medium:  Medium accuracy profil
 - High:    High accuracy profil, when you need the best location
 */
public enum WAILocationProfile {
    case `default`
    case low
    case medium
    case high
}

extension WAILocationProfile : LocationProfile {
    
    public var distanceFilter: CLLocationDistance {
        
        switch self {
        case .default:
            return 50.0
        case .low:
            return 500.0
        case .medium:
            return 100.0
        case .high:
            return 10.0
        }
    }
    
    public var desiredAccuracy: CLLocationAccuracy {
        
        switch self {
        case .default:
            return kCLLocationAccuracyNearestTenMeters
        case .low:
            return kCLLocationAccuracyKilometer
        case .medium:
            return kCLLocationAccuracyHundredMeters
        case .high:
            return kCLLocationAccuracyBestForNavigation
        }
    }
    
    public var horizontalAccuracy: CLLocationDistance {
        
        switch self {
        case .default:
            return 500.0
        case .low:
            return 2000.0
        case .medium:
            return 1000.0
        case .high:
            return 200.0
        }
    }
}
