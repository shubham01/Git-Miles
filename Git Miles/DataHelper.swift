//
//  DataHelper.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 28/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import KeychainAccess

class DataHelper {
    
    static let keychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    static let KEY_TOKEN = "OAuthToken"
    static let KEY_TOKEN_ID = "OAuthTokenID"
    static let KEY_USERNAME = "UserName"
    
    static var oAuthToken: String? {
        set {
            keychain[KEY_TOKEN] = newValue
        }
        get { return keychain[KEY_TOKEN] }
    }
    
    static var oAuthTokenID: String? {
        set {
            keychain[KEY_TOKEN_ID] = newValue
        }
        get { return keychain[KEY_TOKEN_ID] }
    }
    
    static var username: String? {
        set {
            keychain[KEY_USERNAME] = newValue
        }
        get { return keychain[KEY_USERNAME] }
    }
    
    static func hasOAuthToken() -> Bool {
//        return false
//        oAuthToken = nil
//        oAuthTokenID = nil
//        username = nil
        print("has token: \(oAuthToken)")
        return oAuthToken != nil
    }
    
    static func storeOAuthToken(token: String, id: String, forUsername: String) {
        oAuthToken = token
        print(oAuthToken!)
        oAuthTokenID = id
        username = forUsername
    }
    
}
