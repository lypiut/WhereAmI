//
//  InterfaceController.swift
//  watchOS Example Extension
//
//  Created by Romain on 26/12/15.
//  Copyright © 2015 Romain Rivollier. All rights reserved.
//

import WatchKit
import Foundation
import WhereAmI

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var locationLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        whereAmI { (response) in
            switch response {
            case let .locationUpdated(location):
                self.locationLabel.setText(String(format: "lat: %.5f\nlng: %.5f", arguments:[location.coordinate.latitude, location.coordinate.longitude]))
            case let .locationFail(error):
                self.locationLabel.setText("An Error occured \(error.localizedDescription)")
            case .unauthorized:
                self.locationLabel.setText("The app is not allowed to retreive your current location")
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
