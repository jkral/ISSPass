//
//  AppDelegate.swift
//  ISSPass
//
//  Created by Jeff Kral on 2/15/18.
//  Copyright © 2018 Jeff Kral. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let homeTableViewController = HomeTableViewController()
        window?.rootViewController = homeTableViewController
        
        return true
    }
}

