//
//  ViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 17/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import SwiftyJSON
import TTGSnackbar

class ViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var otpField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let apiManager = GitHubAPIManager.sharedInstance
    
    let BUNDLE_ID = NSBundle.mainBundle().bundleIdentifier!

    override func viewDidLoad() {
        super.viewDidLoad()
        otpField.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickLogin(sender: UIButton) {
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        otpField.resignFirstResponder()
        
        let username = usernameField.text!
        let password = passwordField.text!
        let otp = otpField.text!
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        apiManager.authorize(username, password: password, otp: otp) { response in
            activityIndicator.hidden = true
            let statusCode = response.response?.statusCode
            if (statusCode>=200 && statusCode<300) { //logged in
                let json = JSON(response.result.value!)
                
                let token = json["token"].stringValue
                let id = json["id"].stringValue
                let username = self.usernameField.text
                
                DataHelper.storeOAuthToken(token, id: id, forUsername: username!)
                
                self.performSegueWithIdentifier("loginToRepo", sender: self)
                
            } else if (statusCode == 401) {
                if let header = response.response?.allHeaderFields["X-GitHub-OTP"] {
                    if (header.string == nil) {
                        self.otpField.hidden = false
                        self.showDismissableSnackbar("Enter OTP", duration: .Middle)
                    }
                } else {
                    //invalid credentials
                    self.showDismissableSnackbar("Username or password is incorrect",
                                            duration: .Middle)
                }
            }
        }
    }
    
    @IBAction func onClickForgot(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/password_reset")!)
    }
    
    func showDismissableSnackbar(message: String, duration: TTGSnackbarDuration) {
        let snackbar = TTGSnackbar.init(message: message, duration: duration, actionText: "Dismiss") { snackbar in
            snackbar.dismiss()
        }
        snackbar.actionTextColor = UIColor.orangeColor()
        snackbar.show()
    }
}

