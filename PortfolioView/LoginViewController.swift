//
//  LoginViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/31/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.underlined(color: UIColor.lightGray)
        userNameTextField.addIcon(imageName: "username")
        passwordTextField.underlined(color: UIColor.lightGray)
        passwordTextField.addIcon(imageName: "password")
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
    }

    @IBAction func loginButtonClicked(_ sender: Any) {

        self.performSegue(withIdentifier: "loginToPasscodeStagingSegue", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
        
    }
    
    
}
