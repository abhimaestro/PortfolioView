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

    @IBOutlet weak var touchIdButton: UIButton!
    
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
                let _ = self.showAlert(title: "Limit Exceeded", message: "You have exceeded the maximum number of passcode attempts")
            }
        }

    }
    
    convenience init() {

        self.init(nibName: "LockSplashViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VENTouchLock.sharedInstance().appearance().passcodeViewControllerShouldEmbedInNavigationController = true
        VENTouchLock.sharedInstance().appearance().enterPasscodeInitialLabelText = "Please enter your 4-digit PIN to unlock"
        VENTouchLock.sharedInstance().appearance().enterPasscodeViewControllerTitle = "Unlock PortfolioView"
        VENTouchLock.sharedInstance().appearance().cancelBarButtonItemTitle = "Cancel"
        
        self.touchIdButton.isHidden = VENTouchLock.shouldUseTouchID()
    }

    @IBAction func showTouchIdClicked(_ sender: Any) {
        self.showTouchID()
    }

    @IBAction func showPasscodeClicked(_ sender: Any) {
        self.showPasscode(animated: true)
    }

}
