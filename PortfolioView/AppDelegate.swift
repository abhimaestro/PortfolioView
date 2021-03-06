//
//  AppDelegate.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import VENTouchLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shouldRotate = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navBarAppearance = UINavigationBar.appearance()
        
       // let whiteBackground = UIImage(color: , size: CGSize(width: 200, height: 20))
        
        let color = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
        navBarAppearance.tintColor = color
        navBarAppearance.barTintColor =  UIColor.white
        //navBarAppearance.setBackgroundImage(whiteBackground, for: .default)
        navBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName : color, NSFontAttributeName: FontHelper.getDefaultFont(size: 18.0)]
        
        //if UserDefaultValues.isUserLoggedIn {
            VENTouchLock.sharedInstance().setKeychainService("PortfolioView", keychainAccount: "account@portfolioView", touchIDReason: "Scan your fingerprint to unlock", passcodeAttemptLimit: 3, splashViewControllerClass: LockSplashViewController.self)
        //}
        
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldRotate {
            return .allButUpsideDown
        }
        else {
            return .portrait
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

