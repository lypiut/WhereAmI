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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        whereAmI({ [unowned self] (location) -> Void in
    
                self.locationLabel.setText(String(format: "lat: %.5f\nlng: %.5f", arguments:[location.coordinate.latitude, location.coordinate.longitude]))
            
            }) { [unowned self]() -> Void in
                 self.locationLabel.setText("Location refused 😢")
            }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
