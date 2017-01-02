//
//  LockSplashViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/1/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import VENTouchLock

class LockSplashViewController: VENTouchLockSplashViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        
        self.didFinishWithSuccess = {(_ success: Bool, _ unlockType: VENTouchLockSplashViewControllerUnlockType) -> Void in
            if success {
                var logString = "Sample App Unlocked"
                switch unlockType {
                case .touchID:
                    logString = logString.appending(" with Touch ID.")
                    
                case .passcode:
                    logString = logString.appending(" with Passcode.")
                    
                default:
                    break
                }
                
                print("\(logString)")
            }
            else {
                UIAlertView(title: "Limit Exceeded", message: "You have exceeded the maximum number of passcode attempts", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
            }
        }

    }
    
    convenience init() {
        self.init(nibName: "LockSplashViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
