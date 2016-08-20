//
//  ViewController.swift
//  Where Am I
//
//  Created by Romain Rivollier on 23/12/14.
//  Copyright (c) 2014 Romain Rivollier. All rights reserved.
//

import UIKit
import WhereAmI

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func WhereAmITap(_ sender: AnyObject) {
        
        self.textView.text = nil;
        
        whereAmI { [unowned self] (response) -> Void in
            
            switch response {
            case let .locationUpdated(location):
                let textUpdated = self.textView.text
                self.textView.text = String(format: "lat: %.5f lng: %.5f acc: %2.f", arguments:[location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy]) + "\n" + textUpdated!
            case let .locationFail(error):
                self.textView.text = "An Error occurs \(error.localizedDescription)"
            case .unauthorized:
                self.showAlertView()
            }
        }
    }
    
    @IBAction func WhatIsThisPlaceTap(_ sender: AnyObject) {
        
        self.textView.text = nil;
        
        whatIsThisPlace { [unowned self] (response) -> Void in
            
            switch response {
            case let .success(placemark):
                self.textView.text = "\(placemark.name) \(placemark.locality) \(placemark.country)"
            case .placeNotFound:
                self.textView.text = "Place not found"
            case let .failure(error):
                self.textView.text = "An Error occurs \(error.localizedDescription)"
            case .unauthorized:
                self.showAlertView()
            }
        }
    }
    
    func fullControlWay() {
        
        if (!WhereAmI.userHasBeenPromptedForLocationUse()) {
            
            WhereAmI.sharedInstance.askLocationAuthorization({ [unowned self] (locationIsAuthorized) -> Void in
                
                if !locationIsAuthorized {
                    self.showAlertView()
                } else {
                    self.startLocationUpdate()
                }
                });
        }
        else if (!WhereAmI.locationIsAuthorized()) {
            self.showAlertView()
        }
        else {
            self.startLocationUpdate()
        }
    }
    
    fileprivate func startLocationUpdate() {
        
        WhereAmI.sharedInstance.continuousUpdate = true;
        WhereAmI.sharedInstance.startUpdatingLocation({ [unowned self]  (response) -> Void in
            
            switch response {
            case let .locationUpdated(location):
                self.textView.text = location.description
            case let .locationFail(error):
                self.textView.text = "An Error occurs \(error.localizedDescription)"
            case .unauthorized:
                self.showAlertView()
            }
        })
    }
    
    func showAlertView() {
        
        let alertView = UIAlertView(title: "Location Refused",
                                    message: "The app is not allowed to retreive your current location",
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
        
        alertView.show()
    }
}

