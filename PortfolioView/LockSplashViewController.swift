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
    
    deinit {
        self.touchLock.backgroundLockVisible = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "LockSplashViewController", bundle: nil)
        
        self.didFinishWithSuccess = {(_ success: Bool, _ unlockType: VENTouchLockSplashViewControllerUnlockType) -> Void in
            if success {
                
                self.touchLock.backgroundLockVisible = false
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        VENTouchLock.sharedInstance().appearance().cancelBarButtonItemTitle = "Cancel"
        
        self.touchIdButton.isHidden = !VENTouchLock.shouldUseTouchID()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showTouchID()
    }
    
    @IBAction func showTouchIdClicked(_ sender: Any) {
        self.showTouchID()
    }

    @IBAction func showPasscodeClicked(_ sender: Any) {
        self.showPasscode(animated: true)
    }

}
