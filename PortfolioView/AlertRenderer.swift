//
//  AlertRenderer.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/2/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import Foundation

protocol AlertRenderer {
    func showAlert(title: String, message: String, autoDismiss: Bool, dismissAfterSeconds: Int, okButtonText: String, okHandler: (() -> Void)?) -> UIAlertController
    func showConfirm(title: String, message: String, yesButtonText: String, noButtonText: String, yesHandler: (() -> Void)?, noHandler: (() -> Void)?)
    func showActionSheet(title: String, message: String, anchor: AnyObject?, actions: UIAlertAction...)
}

extension UIViewController: AlertRenderer {
    
    func showAlert(title: String = "", message: String, autoDismiss: Bool = false, dismissAfterSeconds: Int = 2, okButtonText: String = "OK", okHandler: (() -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if !autoDismiss {
            alert.addAction(UIAlertAction(title: okButtonText, style: .default, handler: { (alertAction: UIAlertAction!) in okHandler?() }))
        }
        else {
            autoExecuteAfter(seconds: dismissAfterSeconds){
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(alert, animated: true,completion: nil)
        return alert
    }
    
    func showConfirm(title: String = "", message: String, yesButtonText: String = "Yes", noButtonText: String = "No", yesHandler: (() -> Void)?, noHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: yesButtonText, style: .default, handler: {(alertAction: UIAlertAction!) in yesHandler?()}))
        alert.addAction(UIAlertAction(title: noButtonText, style: .default, handler: {(alertAction: UIAlertAction!) in noHandler?()}))
        
        self.present(alert, animated: true,completion: nil)
    }
    
    func showActionSheet(title: String, message: String, anchor: AnyObject? = nil, actions: UIAlertAction...) {
        
        //when sender is nil - the actionsheet cannot be anchored
        let alertStyle:UIAlertControllerStyle = anchor != nil ? .actionSheet : .alert
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for action in actions {
            alert.addAction(action)
        }
        
        //anchor on the sender for ipad
        if anchor != nil {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = (anchor as! UIView)
                popoverController.sourceRect = anchor!.bounds
            }
        }
        
        self.present(alert, animated: true,completion: nil)
    }
}
