//
//  GitHubAPIManager.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 17/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class GitHubAPIManager {
    static let sharedInstance = GitHubAPIManager()
    
    let API_URL = "https://api.github.com/"
    let CLIENT_ID = "8c253e8f25e9cdb33ee2"
    let CLIENT_SECRET = "23e343ae2c255f87ce680cc0a561063d3cf973e7"
    
    func authorize(username: String, password: String, otp: String, completionHandler: (response: Response<AnyObject,NSError>) -> ()) {
        let credentials = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let credBase64 = credentials.base64EncodedStringWithOptions([])
        let headers = ["Authorization": "Basic \(credBase64)", "X-GitHub-OTP":otp]
        
        let parameters : [String : AnyObject] = [
            "scope": ["repo", "user"],
            "note": "Git Miles",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET
        ]
        
        Alamofire.request(.POST, API_URL + "authorizations", parameters: parameters, encoding: .JSON, headers: headers)
            .responseJSON { response in
                completionHandler(response: response)
            }
        DataHelper.basicAuth = credBase64
    }
    
    func getRepositories(completionHandler: (response: Response<AnyObject, NSError>) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let headers = ["Authorization": "token \(DataHelper.oAuthToken!)"]
        Alamofire.request(.GET, API_URL + "user/repos", headers: headers)
            .responseJSON { response in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(response: response)
        }
    }
    
    func getMilestones(url: String, completionHandler: (response: Response<AnyObject, NSError>) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let headers = ["Authorization": "token \(DataHelper.oAuthToken!)"]
        Alamofire.request(.GET, url, headers: headers)
            .responseJSON { response in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(response: response)
        }
    }
    
    func getPullRequestsForMilestone(repoUrl: String, number: NSNumber, state: String, completionHandler: (response: Response<AnyObject, NSError>) -> ()) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let headers = ["Authorization": "token \(DataHelper.oAuthToken!)"]
        let url = repoUrl + "/issues"
        
        let parameters: [String : AnyObject] = [
            "milestone": number,
            "state": state,
        ]
        
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .responseJSON { response in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(response: response)
        }
    }
    
    func logout(completionHandler: (response: Response<AnyObject, NSError>) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let URL = API_URL + "applications/\(CLIENT_ID)/tokens/\(DataHelper.oAuthToken!)"
        
        let credentials = "\(CLIENT_ID):\(CLIENT_SECRET)".dataUsingEncoding(NSUTF8StringEncoding)!
        let credBase64 = credentials.base64EncodedStringWithOptions([])
        let headers = ["Authorization": "Basic \(credBase64)"]
        
        Alamofire.request(.DELETE, URL, headers: headers)
            .responseJSON() { response in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completionHandler(response: response)
        }
    }
    
    
}