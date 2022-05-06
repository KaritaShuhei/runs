//
//  applyUserRuleViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/24.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import FirebaseMessaging
import Photos
import MobileCoreServices
import AssetsLibrary
import StoreKit

class ApplyUserRuleViewController: UIViewController {

    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    var latestExpireDate:Int = 0

    var approveFlag:Int = 0
    var backFlag:String?
    let Ref = Database.database().reference()
    let currentUid:String = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
