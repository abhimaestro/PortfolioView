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

        userNameTextField.underlined()
        userNameTextField.addIcon(imageName: "username")
        passwordTextField.underlined()
        passwordTextField.addIcon(imageName: "password")
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
        
    }
}
