//
//  ViewController.swift
//  Homely
//
//  Created by Wilhelm Van Der Walt on 10/3/15.
//  Copyright © 2015 ysterslot. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
	var haveFoundReciever: Bool = false
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	var userModels: [UserModel] = [
//		UserModel(name: "David", lastDonated: "Last Donated £20, 3 Days ago", image: UIImage(named: "david") ?? UIImage()),
//		UserModel(name: "Judith", lastDonated: "Last Donated £15, a week ago", image: UIImage(named: "judith") ?? UIImage()),
//		UserModel(name: "Gordan", lastDonated: "Last Donated £20, 1 month ago", image: UIImage(named: "profile") ?? UIImage()),
	]
	
	var userModel: UserModel?
	
	var locationManager: CLLocationManager = CLLocationManager()

	@IBOutlet weak var tableview: UITableView!
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		haveFoundReciever = false
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLogin", name: "kDidLogin", object: nil)

		
		UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil))
		
		self.navigationController?.navigationBar.barTintColor = UIColor(red: 102/255.0, green: 221/255.0, blue: 179/255.0, alpha: 1.0)
		self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

		
		self.tableview?.dataSource = self
		self.tableview?.delegate = self
		locationManager = CLLocationManager()
		
		locationManager.requestAlwaysAuthorization()
		
		locationManager.delegate = self
		locationManager.pausesLocationUpdatesAutomatically = false

		let uuidString = "EBEFD083-70A2-47C8-9837-E7B5634DF524"
		let beaconIdentifier = "testRegion"
		
		if let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString) {
			let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
				identifier: beaconIdentifier)
			//			beaconRegion.notifyEntryStateOnDisplay = true
			beaconRegion.notifyOnEntry = true
			beaconRegion.notifyOnExit = true
			
			locationManager.startMonitoringForRegion(beaconRegion)
			//			locationManager.startRangingBeaconsInRegion(beaconRegion)
			
			
			
		}
		
		locationManager.startUpdatingLocation()
		let fbId: String = NSUserDefaults.standardUserDefaults().valueForKey("kFacebookId") as? String ?? ""
		let urlString = "http://homely-webapi.herokuapp.com/api/donations/?giver=\(fbId)"
		
		
		if let url = NSURL(string: urlString) {
			let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
				if let nData = data {
					let json = JSON(data: nData)
					let userDictArray = json["results"].arrayValue
						for userDict in userDictArray {
							let user = UserModel(name: userDict["reciever"]["name"].stringValue ?? "", lastDonated: userDict["donation_date"].stringValue ?? "", image: nil, imageURL: userDict["reciever"]["photo"].stringValue ?? "", beaconId: userDict["reciever"]["beacon_id"].stringValue ?? "", charityURLString: userDict["reciever"]["charity"].stringValue ?? "", targetPercentage: userDict["reciever"]["target_percentage"].floatValue ?? 0)
							let userModelsCopy = self.userModels
							self.userModels = userModelsCopy + [user]
							dispatch_async(dispatch_get_main_queue(),{
								
								self.tableview.reloadData()
								
							})

						}
						
					
					
					
				}
			}
			task.resume()
		}
//		self.performSegueWithIdentifier("GiverScreen", sender: self)
		
	}
	
	func didLogin() {
		let fbId: String = NSUserDefaults.standardUserDefaults().valueForKey("kFacebookId") as? String ?? ""
		let urlString = "http://homely-webapi.herokuapp.com/api/donations/?giver=\(fbId)"
		
		
		if let url = NSURL(string: urlString) {
			let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
				if let nData = data {
					let json = JSON(data: nData)
					let userDictArray = json["results"].arrayValue
					for userDict in userDictArray {
						let user = UserModel(name: userDict["reciever"]["name"].stringValue ?? "", lastDonated: userDict["donation_date"].stringValue ?? "", image: nil, imageURL: userDict["reciever"]["photo"].stringValue ?? "", beaconId: userDict["reciever"]["beacon_id"].stringValue ?? "", charityURLString: userDict["reciever"]["charity"].stringValue ?? "", targetPercentage: userDict["reciever"]["target_percentage"].floatValue ?? 0)
						let userModelsCopy = self.userModels
						self.userModels = userModelsCopy + [user]
						dispatch_async(dispatch_get_main_queue(),{
							
							self.tableview.reloadData()
							
						})
						
					}
					
					
					
					
				}
			}
			task.resume()
		}
	}
	
	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
		if state == CLRegionState.Inside {
			if let reg = region as? CLBeaconRegion {
				manager.startRangingBeaconsInRegion(reg)
				manager.startUpdatingLocation()
				
				
				
			}
		}
	
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if let reuseCell = tableView.dequeueReusableCellWithIdentifier("TimeLineCell") as? TimeLineCell {
			reuseCell.name?.text = userModels[indexPath.row].name
			reuseCell.lastDonationLabel?.text = userModels[indexPath.row].lastDonated
			reuseCell.profileImage?.image = userModels[indexPath.row].image
			reuseCell.horizontalConstraint.constant = -150 * CGFloat(userModels[indexPath.row].targetPercentage)
			
			return reuseCell
		}
		let cell = TimeLineCell()
		cell.name?.text = userModels[indexPath.row].name
		cell.lastDonationLabel?.text = userModels[indexPath.row].lastDonated
		cell.profileImage?.image = userModels[indexPath.row].image
		cell.horizontalConstraint.constant = -150 * CGFloat(userModels[indexPath.row].targetPercentage)
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.userModels.count
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		
		if FBSDKAccessToken.currentAccessToken() == nil {
			self.performSegueWithIdentifier("login", sender: self)
		}
		else {

		}
		
	
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func presentGiverScreen() {
		if !(self.navigationController?.topViewController is GiveViewController) {
			self.performSegueWithIdentifier("GiverScreen", sender: self)
		}
	}
	
	func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
		print(beacons)
		if let reg = beacons.last {
			if beacons[0].proximity == CLProximity.Near {
				
			}
			let urlString = "http://homely-webapi.herokuapp.com/api/receivers/?beacon_id=\(reg.minor)"
			
			
			if let url = NSURL(string: urlString) {
				let task = NSURLSession.sharedSession().dataTaskWithURL(url) {[weak self](data, response, error) in
					if let nData = data {
						let json = JSON(data: nData)
						if let userDict = json["results"].arrayValue.first {
							let user = UserModel(name: userDict["name"].stringValue ?? "", lastDonated: userDict["last_donated"].stringValue ?? "", image: nil, imageURL: userDict["photo"].stringValue ?? "", beaconId: userDict["beacon_id"].stringValue ?? "", charityURLString: userDict["charity"].stringValue ?? "", targetPercentage: userDict["target_percentage"].floatValue ?? 0 )
							self?.userModel = user
							dispatch_async(dispatch_get_main_queue(),{
								if let hasFound = self?.haveFoundReciever where !hasFound{
									let notification = UILocalNotification()
									notification.alertBody = "You are near \(user.name) do you want to help him out. Swipe to find out more" // text that will be displayed in the notification
									notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
									//				notification.category = "TODO_CATEGORY"
									UIApplication.sharedApplication().presentLocalNotificationNow(notification)
									self?.haveFoundReciever = true
									self?.presentGiverScreen()
								}
								
								
							})
							
						}
						
						
					}
				}
				task.resume()
			}

			

			
		}
	}
	
	func locationManager(manager: CLLocationManager,
		didEnterRegion region: CLRegion) {
			NSLog("You entered the region\n\n\n\n\n\n")
			
			if let reg = region as? CLBeaconRegion {
				manager.startRangingBeaconsInRegion(reg)
				manager.startUpdatingLocation()

			}
	}
	
	func locationManager(manager: CLLocationManager,
		didExitRegion region: CLRegion) {
			if let reg = region as? CLBeaconRegion {
				manager.stopRangingBeaconsInRegion(reg)
				manager.stopUpdatingLocation()
				
				NSLog("You exited the region")
				
			}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.presentGiverScreen()
		self.userModel = self.userModels[indexPath.row]
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "GiverScreen" {
			if let view = segue.destinationViewController as? GiveViewController {
				view.nameValue = self.userModel?.name
				view.profileImageURL = self.userModel?.imageUrl
				view.recieverId = self.userModel?.beaconId
				view.userModel = self.userModel
			}
		}
	}


}

class TimeLineCell : UITableViewCell {
	
	
	@IBOutlet weak var profileImage: UIImageView!
	
	@IBOutlet weak var name: UILabel!
	
	@IBOutlet weak var horizontalConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var lastDonationLabel: UILabel!
	
	@IBOutlet weak var progressBarTop: UIView!
	
	@IBOutlet weak var progressBarBottom: UIView!
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
		self.progressBarTop.layer.cornerRadius = self.progressBarBottom.frame.height/2
		self.progressBarTop.clipsToBounds = true
		self.profileImage.clipsToBounds = true
		self.progressBarBottom.layer.cornerRadius = self.progressBarBottom.frame.height/2
		self.progressBarBottom.clipsToBounds = true


	}
	
}

class UserModel {
	let name: String
	let lastDonated: String
	let image: UIImage?
	let imageUrl: String?
	let beaconId: String
	let targetPercentage: Float
	let charityURLString : String
	init(name: String, lastDonated: String, image: UIImage? = nil, imageURL: String?, beaconId: String, charityURLString: String, targetPercentage: Float) {
		self.name = name
		self.targetPercentage = targetPercentage
		self.imageUrl = imageURL
		self.beaconId = beaconId
		self.charityURLString = charityURLString
		self.image = image
		self.lastDonated = lastDonated
		
	}
}

class DonationModel {
	
}





