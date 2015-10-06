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
				if (error == nil){
					print(result)
					self.dismissViewControllerAnimated(true, completion: nil)
					
				}
			})
		}
	}
}