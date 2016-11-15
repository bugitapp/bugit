//
//  EditorNavigationController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import INTULocationManager

class EditorNavigationController: UINavigationController {
    
    let locMgr: INTULocationManager = INTULocationManager.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        // Default the location to San Francisco
        defaults.set([
            "lat": 37.785771,
            "lng": -122.406165
            ], forKey: "bugit_user_location")
        defaults.synchronize()
        
        // Do any additional setup after loading the view.
        getCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentLocation() {
        let defaults = UserDefaults.standard
        locMgr.requestLocation(withDesiredAccuracy: INTULocationAccuracy.block,
                               timeout: 10.0,
                               delayUntilAuthorized: true,
                               block: {(currentLocation: CLLocation?, achievedAccuracy: INTULocationAccuracy, status: INTULocationStatus) -> Void in
                                
                                if status == INTULocationStatus.success {
                                    // got location successfully
                                    print("currentLocation = \(currentLocation)")
                                    
                                    defaults.set([
                                        "lat": currentLocation!.coordinate.latitude,
                                        "lng": currentLocation!.coordinate.longitude
                                        ], forKey: "bugit_user_location")
                                    
                                } else {
                                    // error, this happens often
                                    
                                    // Default the location to San Francisco
                                    defaults.set([
                                        "lat": 37.785771,
                                        "lng": -122.406165
                                        ], forKey: "bugit_user_location")
                                }
                                defaults.synchronize()
        })
    }
    
}
