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
        
        whereAmIButton.addTarget(self, action: #selector(ViewController.tapOnWhereAmI), forControlEvents: .PrimaryActionTriggered)
        whatIsThisPlaceButton.addTarget(self, action: #selector(ViewController.tapOnWhatIsThisPlace), forControlEvents: .PrimaryActionTriggered)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tapOnWhereAmI() {
        
        whereAmI { [unowned self] (response) -> Void in
            
            switch response {
            case let .LocationUpdated(location):
                self.resultLabel.text = String(format: "lat: %.5f lng: %.5f acc: %2.f", arguments:[location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy])
            case let .LocationFail(error):
                self.resultLabel.text = "An Error occurs \(error.localizedDescription)"
            case .Unauthorized:
                self.resultLabel.text = "The app is not allowed to retreive your current location"
            }
        }
    }

    func tapOnWhatIsThisPlace() {
        
        whatIsThisPlace { [unowned self] (response) -> Void in
            
            switch response {
            case let .Success(placemark):
                self.resultLabel.text = "\(placemark.name) \(placemark.locality) \(placemark.country)"
            case .PlaceNotFound:
                self.resultLabel.text = "Place not found"
            case let .Failure(error):
                self.resultLabel.text = "An Error occurs \(error.localizedDescription)"
            case .Unauthorized:
                self.resultLabel.text = "The app is not allowed to retreive your current location"
            }
        }
    }
}

