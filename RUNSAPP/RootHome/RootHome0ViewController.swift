//
//  rootHomeViewController.swift
//  coachingApp1
//
//  Created by 原井川　千夏 on 2022/02/03.
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

class RootHome0ViewController: UIViewController {
    
    var purchaseStatus:String?
    var purchaseExpiresDate: Int?
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    @IBOutlet weak var applyButton: UIButton!
    
    override func viewDidLoad() {
        
        applyButton.isHidden = true
//        fetchPurchaseStatus()
        fcmStatus()
        loadData_profile()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func buttonTapped(_ sender: Any) {
        print("buttonTapped")
        if purchaseStatus == "1"{
            performSegue(withIdentifier: "toApplyForm", sender: nil)
        }else{
            performSegue(withIdentifier: "toCoachingPlan1View", sender: nil)
        }
        
    }
    func fcmStatus(){
        let currentUid:AnyObject = Auth.auth().currentUser!.uid as AnyObject
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                print("許可")
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("Error fetching FCM registration token: \(error)")
                    } else if let token = token {
                        print("FCM registration token: \(token)")
                        let data1 = ["fcmStatus":"1","fcmToken":token as Any]
                        let dbRef = Database.database().reference()
                        dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
                    }
                }
            } else {
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("Error fetching FCM registration token: \(error)")
                    } else if let token = token {
                        let data1 = ["fcmStatus":"0","fcmToken":token as Any]
                        let dbRef = Database.database().reference()
                        dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
                        print("FCM registration token: \(token)")
                    }
                }
                print("未許可")
            }
        })
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
                                applyButton.isHidden = true
                                break
                            }
                            if snap == snapdata[snapdata.keys.sorted().last!]{
                                self.purchaseStatus = "1"
                                applyButton.isHidden = false
                            }
                        }
                    }
                })
            }else{
                print("fetchPurchaseStatus")
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
                applyButton.isHidden = false
            }else if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                self.purchaseStatus = "0"
                print("receiptValidation")
                self.receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
            }else{
                self.purchaseStatus = "1"
                applyButton.isHidden = false
            }
            //            }
        })
        
        ref.observe(.childChanged, with: { (snapshot) in
            self.applyButton.isHidden = false
        })
    }
    
    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptUrl!) else {
            self.purchaseStatus = "0"
            print("error")
            return
        }
        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "3d79281ef5f3451bb31cd4a9f481a4c0" // appstoreconnectからApp 用共有シークレットを取得しておきます
        ]
        //        print(requestContents)
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.timeoutInterval = 5.0
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            guard let jsonData = data else {
                return
            }
            
            do {
                let json:Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: jsonData, options: .init(rawValue: 0)) as! Dictionary<String, AnyObject>
                
                let status:Int = json["status"] as! Int
                if status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                    self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                }
                
                guard let receipts:Array<Dictionary<String, AnyObject>> = json["latest_receipt_info"] as? Array<Dictionary<String, AnyObject>> else {
                    return
                }
                
                // 機能開放
                self.provideFunctions(receipts: receipts)
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
            }
        })
        task.resume()
    }
    enum receiptErrorStatus: Int {
        case invalidJson = 21000
        case invalidReceiptDataProperty = 21002
        case authenticationError = 21003
        case commonSecretKeyMisMatch = 21004
        case receiptServerNotWorking = 21005
        case invalidReceiptForProduction = 21007
        case invalidReceiptForSandbox = 21008
        case unknownError = 21010
    }
    func provideFunctions(receipts:Array<Dictionary<String, AnyObject>>) {
        //        let in_apps = receipts["latest_receipt_info"] as! Array<Dictionary<String, AnyObject>>
        
        var latestExpireDate:Int = 0
        for receipt in receipts {
            let receiptExpireDateMs = Int(receipt["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
                print(latestExpireDate)
            }
            let demodata = receipt["expires_date"] as? String ?? ""
            print("demodata:\(demodata)")
        }
        UserDefaults.standard.set(latestExpireDate, forKey: "expireDate")
        let timeInterval = NSDate().timeIntervalSince1970
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let purchaseExpiresDate_yyyyMMdd = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(latestExpireDate)))
        
        self.purchaseExpiresDate = latestExpireDate
        print("latestExpireDate\(latestExpireDate)")
        if Int(timeInterval) < latestExpireDate {
            self.purchaseStatus = "1"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金あり","purchaseExpiresDate_yyyyMMdd":"\(purchaseExpiresDate_yyyyMMdd)"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }else{
            self.purchaseStatus = "0"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金なし"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }
        //        self.dismiss(animated: true, completion: nil)
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
