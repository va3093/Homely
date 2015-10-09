//
//  LoginViewController.swift
//  Homely
//
//  Created by Wilhelm Van Der Walt on 10/3/15.
//  Copyright © 2015 ysterslot. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

var facebookId: String = ""

class LoginViewController: UIViewController {
	
	@IBAction func loginWithFacebook(sender: AnyObject) {
	 let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
		fbLoginManager.loginBehavior = FBSDKLoginBehavior.Native
		fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
			if (error == nil){
				let fbloginresult : FBSDKLoginManagerLoginResult = result
				if(fbloginresult.grantedPermissions.contains("email"))
				{
					self.getFBUserData()
//					fbLoginManager.logOut()
				}
			}
		})
	
	}
	
	
	func getFBUserData(){
		if((FBSDKAccessToken.currentAccessToken()) != nil){
			FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
				if let resultDict = result as? [String: AnyObject] where (error == nil){
					
					facebookId = resultDict["id"] as? String ?? ""
					
					print(result)
					let jsonData: NSData?
					do {
						jsonData = try NSJSONSerialization.dataWithJSONObject(resultDict, options: .PrettyPrinted)
					} catch _ {
						jsonData = nil
					}
					let request = NSMutableURLRequest(URL: NSURL(string: "http://homely-webapi.herokuapp.com/api/givers")!)
					request.HTTPMethod = "POST"
					request.HTTPBody = jsonData
					let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
						data, response, error in
						
						if error != nil {
							print("error=\(error)")
							return
						}
						
						print("response = \(response)")
						
						let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
						print("responseString = \(responseString)")
					}
					task.resume()
					self.dismissViewControllerAnimated(true, completion: nil)
					
				}
			})
		}
	}
}