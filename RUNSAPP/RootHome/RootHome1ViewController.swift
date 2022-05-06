//
//  rootHome2ViewController.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/15.
//

import UIKit
import Firebase
//import FirebaseAuthUI
import FirebaseAuth
import AVFoundation
import AVKit
import Messages
import UserNotifications
import StoreKit

class RootHome1ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    var purchaseStatus:String?
    var purchaseExpiresDate: Int?

    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    override func viewDidLoad() {
        button.isHidden = true

        loadData_profile()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func loadData_profile(){
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["teamID"] as? String
            if key1 != ""{
                let ref1 = Ref.child("team").child("\(key1!)").child("admin")
                ref1.observeSingleEvent(of: .value, with: { [self]
                    (snapshot) in
                    if let snapdata = snapshot.value as? [String:NSDictionary]{
                        for key in snapdata.keys.sorted(){
                            let snap = snapdata[key]
                            let data = snap!["uid"] ?? ""
                            if data as! String == currentUid{
                                break
                            }
                            if snap == snapdata[snapdata.keys.sorted().last!]{
                                button.isHidden = false
                            }
                        }
                    }
                })
            }else{
                
                fetchPurchaseStatus()
                
            }
        })
    }
    func fetchPurchaseStatus(){
        let ref = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key0 = value?["purchaseStatus"] as? String
            let key1 = value?["purchaseExpiresDate"] as? Int
            self.purchaseExpiresDate = key1
            let timeInterval = NSDate().timeIntervalSince1970
            
            if key0 == "課金なし" || key0 == nil{
                self.purchaseStatus = "0"
            }else if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                self.purchaseStatus = "0"
            }else{
                self.purchaseStatus = "1"
                button.isHidden = false
            }
            //            }
        })
        
        ref.observe(.childChanged, with: { (snapshot) in
            self.button.isHidden = false
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
