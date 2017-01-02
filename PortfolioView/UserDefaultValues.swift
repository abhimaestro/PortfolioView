//
//  NSUserDefaultValues.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/2/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import Foundation

class UserDefaultValues {
    
    static var isUserLoggedIn: Bool {
        get {
            return getValue(key: "isUserLoggedIn") ??  false
        }
        set(val) {
            setValue(key: "isUserLoggedIn", val)
        }
    }

    static var loggedInUserName: String {
        get {
            return getValue(key: "loggedInUserName") ??  ""
        }
        set(val) {
            setValue(key: "loggedInUserName", val)
        }
    }
    
    static func getValue<T>(key: String) -> T? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as? T
    }
    
    static func setValue<T>(key: String, _ val: T) {
        let defaults = UserDefaults.standard
        defaults.set(val, forKey: key)
    }
}
