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
        
        whereAmIButton.addTarget(self, action: "tapOnWhereAmI", forControlEvents: .PrimaryActionTriggered)
        whatIsThisPlaceButton.addTarget(self, action: "tapOnWhatIsThisPlace", forControlEvents: .PrimaryActionTriggered)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tapOnWhereAmI() {
        whereAmI({ [unowned self] (location) -> Void in
            
                self.resultLabel.text = String(format: "lat: %.5f lng: %.5f acc: %2.f", arguments:[location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy])
            
            }) { [unowned self] in
                self.resultLabel.text = "The app is not allowed to retreive your current location"
        }
    }

    func tapOnWhatIsThisPlace() {
        whatIsThisPlace({ (placemark) -> Void in
            
            if let place = placemark {
                self.resultLabel.text = "\(place.name) \(place.locality) \(place.country)"
            }
            
            }) { [unowned self] in
                self.resultLabel.text = "The app is not allowed to retreive your current location"
        }
    }
}

