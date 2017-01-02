//
//  StagingInterfaceController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/2/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class StagingInterfaceController: WKInterfaceController , WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    let session = WCSession.default()
    
    var count = 0
    
    @IBOutlet var label: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Initialize the `WCSession`.
        session.delegate = self
        session.activate()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        
//        guard let userLoggedOut = applicationContext["userLoggedOut"] as? Bool else { return }
//        
//        if userLoggedOut  {
//            WKInterfaceController.reloadRootControllers(withNames: ["stagingIC"], contexts: nil)
//        }
//    }
}
