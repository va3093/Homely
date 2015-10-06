//
//  GiveViewController.swift
//  Homely
//
//  Created by Wilhelm Van Der Walt on 10/3/15.
//  Copyright © 2015 ysterslot. All rights reserved.
//

import Foundation
import UIKit
import PassKit
import Stripe

class GiveViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
	
	@IBOutlet weak var ProfileImage: UIImageView!
	
	@IBOutlet weak var name: UILabel!
	
	@IBOutlet weak var Charity: UILabel!
	
	@IBOutlet weak var fundingGoal: UILabel!
	
	@IBOutlet weak var giveButton: UIButton!
	
	@IBOutlet weak var amountToGive: UILabel!
	
	@IBOutlet weak var slider: UISlider!
	
	@IBOutlet weak var sliderWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var sliderBottom: UIView!
	
	@IBOutlet weak var thankyouView: UIView!
	
	@IBOutlet weak var sliderTop: UIView!
	
	@IBOutlet weak var okButton: UIButton!
	
	@IBOutlet weak var shareButton: UIButton!
	
	let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.ProfileImage.image = UIImage(named: "profile")
		self.slider.value = 0.0
		
		self.sliderBottom.layer.cornerRadius = self.sliderBottom.frame.height/2
		self.sliderBottom.clipsToBounds = true
		self.sliderTop.layer.cornerRadius = self.sliderTop.frame.height/2
		self.sliderTop.clipsToBounds = true
		
		self.giveButton.tintColor = UIColor(red: 102/255.0, green: 221/255.0, blue: 179/255.0, alpha: 1.0)
		self.giveButton.layer.borderWidth = 1.0
		self.giveButton.layer.borderColor = UIColor(red: 102/255.0, green: 221/255.0, blue: 179/255.0, alpha: 1.0).CGColor
		self.giveButton.layer.cornerRadius = 3.0
		self.giveButton.layer.masksToBounds = true
		
		self.okButton.layer.borderWidth = 1.0
		self.okButton.layer.borderColor = UIColor.whiteColor().CGColor
		self.okButton.layer.cornerRadius = 3.0
		self.okButton.layer.masksToBounds = true

		
		self.shareButton.layer.borderWidth = 1.0
		self.shareButton.layer.borderColor = UIColor.whiteColor().CGColor
		self.shareButton.layer.cornerRadius = 3.0
		self.shareButton.layer.masksToBounds = true

		self.thankyouView.hidden = true
		
	}
	
	
	@IBAction func giveButtonTapped(sender: AnyObject) {
//		if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks) {
			let request = PKPaymentRequest()
			request.supportedNetworks = SupportedPaymentNetworks
			request.merchantCapabilities = .Capability3DS
			request.countryCode = "UK"
			request.currencyCode = "USD"
			
			let label : String = "Amount to give"
			let amount = NSDecimalNumber(string: "\(Int(self.slider.value * 100))")
			request.paymentSummaryItems = [PKPaymentSummaryItem(label: label, amount: amount)]
			
//			let payController = PKPaymentAuthorizationViewController(paymentRequest: request)
			let payController = STPTestPaymentAuthorizationViewController(paymentRequest: request)
			payController.delegate = self
			presentViewController(payController, animated: true, completion: nil)

//			if Stripe.canSubmitPaymentRequest(request) {
//					let payController = PKPaymentAuthorizationViewController(paymentRequest: request)
//				payController.delegate = self
//				presentViewController(payController, animated: true, completion: nil)
//			}
//			else {
//				
//			}
//		}
//		else {
//			
//		}
	
	
		
	}
	
	func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
		completion(PKPaymentAuthorizationStatus.Success)
		
	}
	
	func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
		self.dismissViewControllerAnimated(true, completion: nil)
		self.thankyouView.hidden = false
	}
	@IBAction func sliderValueChanged(sender: AnyObject) {
		self.amountToGive.text = "£" + "\(Int(self.slider.value * 100))"
	}
}