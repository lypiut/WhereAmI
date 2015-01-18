//
//  ViewController.swift
//  Where Am I
//
//  Created by Romain Rivollier on 23/12/14.
//  Copyright (c) 2014 Romain Rivollier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhereAmI.sharedInstance.whereAmI({ (location) -> Void in
            println("New Location \(location)");
        }, locationRefusedHandler: { (locationIsAuthorized) -> Void in
            if (!locationIsAuthorized) {
                println("location is not authorized");
            }
        });
        
        WhereAmI.sharedInstance.whatIsThisPlace({ (placemark) -> Void in
            println("You are \(placemark)")
        }, locationRefusedHandler: { (locationIsAuthorized) -> Void in
            if (!locationIsAuthorized) {
                println("location is not authorized");
            }
        });
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

