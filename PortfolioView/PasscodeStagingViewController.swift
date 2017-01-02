//
//  PasscodeStagingViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/1/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import VENTouchLock

class PasscodeStagingViewController: UIViewController {

    var _passcodeShown =  false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VENTouchLock.sharedInstance().appearance().createPasscodeViewControllerTitle = "Security PIN"
        VENTouchLock.sharedInstance().appearance().cancelBarButtonItemTitle = "Skip"
        VENTouchLock.sharedInstance().appearance().createPasscodeInitialLabelText = "Set up a new 4-digit PIN for maximum security"
        VENTouchLock.sharedInstance().appearance().passcodeViewControllerBackgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !_passcodeShown {
            
            let createPasscodeVC = VENTouchLockCreatePasscodeViewController()
            self.present(createPasscodeVC.embeddedInNavigationController(), animated: false, completion: nil)
        
            _passcodeShown = true
            createPasscodeVC.willFinishWithResult =  {
                (success: Bool) in
            
                createPasscodeVC.dismiss(animated: false, completion: {
                self.performSegue(withIdentifier: "passcodeStagingToDashboardSegue", sender: self)
            })
        }
        }
    }
}
