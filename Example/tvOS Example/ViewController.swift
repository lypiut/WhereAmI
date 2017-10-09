//
//  ViewController.swift
//  tvOS Exampple
//
//  Created by Romain on 26/12/15.
//  Copyright © 2015 Romain Rivollier. All rights reserved.
//

import UIKit
import WhereAmI

class ViewController: UIViewController {

    @IBOutlet weak var whereAmIButton: UIButton!
    @IBOutlet weak var whatIsThisPlaceButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        whereAmIButton.addTarget(self, action: #selector(ViewController.tapOnWhereAmI), for: .primaryActionTriggered)
        whatIsThisPlaceButton.addTarget(self, action: #selector(ViewController.tapOnWhatIsThisPlace), for: .primaryActionTriggered)
    }

    @objc dynamic func tapOnWhereAmI() {
        
        whereAmI { [unowned self] (response) -> Void in
            
            switch response {
            case let .locationUpdated(location):
                self.resultLabel.text = String(format: "lat: %.5f lng: %.5f acc: %2.f", arguments:[location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy])
            case let .locationFail(error):
                self.resultLabel.text = "An Error occurs \(error.localizedDescription)"
            case .unauthorized:
                self.resultLabel.text = "The app is not allowed to retreive your current location"
            }
        }
    }

    @objc dynamic func tapOnWhatIsThisPlace() {
        
        whatIsThisPlace { [unowned self] (response) -> Void in
            
            switch response {
            case let .success(placemark):
                self.resultLabel.text = "\(String(describing: placemark.name)) \(String(describing: placemark.locality)) \(String(describing: placemark.country))"
            case .placeNotFound:
                self.resultLabel.text = "Place not found"
            case let .failure(error):
                self.resultLabel.text = "An Error occurs \(error.localizedDescription)"
            case .unauthorized:
                self.resultLabel.text = "The app is not allowed to retreive your current location"
            }
        }
    }
}

