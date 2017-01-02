//
//  LoginViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/31/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import VENTouchLock

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    private var _userName: String?
    private var _password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaultValues.isUserLoggedIn = false
        UserDefaultValues.loggedInUserName = ""
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.underlined(color: UIColor.lightGray)
        userNameTextField.addIcon(imageName: "username")
        passwordTextField.underlined(color: UIColor.lightGray)
        passwordTextField.addIcon(imageName: "password")
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userNameTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        login()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
        UserDefaultValues.isUserLoggedIn = false
        UserDefaultValues.loggedInUserName = ""
        
        VENTouchLock.sharedInstance().deletePasscode()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //submit for password field only
        if (textField == userNameTextField || textField == passwordTextField) && (textField.returnKeyType == .go || textField.returnKeyType == .done) {
            textField.resignFirstResponder()
            login()
        }
        
        return true
    }
    
    func login() {
        
        _userName = (userNameTextField.text?.trimmingCharacters(in: .whitespaces))
        _password = (passwordTextField.text?.trimmingCharacters(in: .whitespaces))
        
        if (_userName == nil || _userName?.characters.count == 0) {
            let _ = showAlert(message: "Please enter valid username")
            return
        }
        else if (_password == nil || _password?.characters.count == 0) {
            let _ = showAlert(message: "Please enter a password")
            return
        }
        
        if let userName = self._userName {
            UserDefaultValues.loggedInUserName = userName
        }
        else {
            let _ = self.showAlert(message: "Please enter a valid username")
        }
        
        UserDefaultValues.isUserLoggedIn = true
        self.performSegue(withIdentifier: "loginToPasscodeStagingSegue", sender: self)
    }
}
