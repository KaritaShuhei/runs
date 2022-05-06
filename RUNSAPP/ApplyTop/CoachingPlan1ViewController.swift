//
//  inviteViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/02/28.
//

import UIKit
import Firebase
import FirebaseStorage
import StoreKit

class CoachingPlan1ViewController: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    var purchaseStatus:String?
    var childChangedStatus:String = "0"
    
    let Ref = Database.database().reference()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    
    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    
    var window: UIWindow?
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    
    override func viewDidLoad() {
        initilize()
        fetchPurchaseStatus()
        fetchProducts()
        loadData()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    //    override func viewWillAppear(_ animated: Bool) {
    //        fetchPurchaseStatus()
    //        super.viewWillAppear(animated)
    //    }
        
    func initilize(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .clear
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.color = .white
        ActivityIndicator.backgroundColor = .darkGray
        ActivityIndicator.startAnimating()
        
        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true
        
        //Viewに追加
        initilizedView.addSubview(ActivityIndicator)
        view.addSubview(initilizedView)
    }
    func loadData(){
        let ref0 = Database.database().reference().child("user").child("\(currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int ?? 0
            purchaseExpiresDate = key
        })

    }
    func fetchProducts(){
        let productIdentifier:Set = ["com.runs.AutoRenewingSubscription_basic"]
        // 製品ID
        let productsRequest: SKProductsRequest = SKProductsRequest.init(productIdentifiers: productIdentifier)
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            myProduct = product
            print(myProduct)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
                self.purchaseButton.isEnabled = true
                self.purchaseButton.setTitle("申し込む", for: .normal)
                purchaseButton.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                purchaseButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                initilizedView.removeFromSuperview()
            case .purchased:
                self.purchaseButton.isEnabled = true
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction purchased: \(transaction)")

            case .restored:
                self.purchaseButton.isEnabled = true
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction restored: \(transaction)")
                //                self.performSegue(withIdentifier: "applyFormNavigationSegue", sender: nil)
            case .deferred, .purchasing:
                self.purchaseButton.isEnabled = false
//                self.purchaseButton.setTitle("支払処理中", for: .normal)
//                purchaseButton.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                purchaseButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

                print("Transaction in progress: \(transaction)")
            @unknown default:
                self.purchaseButton.isEnabled = true
                self.purchaseButton.setTitle("申し込む", for: .normal)
                purchaseButton.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                purchaseButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                initilizedView.removeFromSuperview()
                break
            }
        }
    }
    
    func fetchPurchaseStatus(){
        let ref = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int
            if key != nil{
                self.purchaseExpiresDate = key
                let timeInterval = NSDate().timeIntervalSince1970
                if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                    self.purchaseStatus = "0"
                    self.receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                }else{
                    self.purchaseStatus = "1"
                }
            }
            self.initilizedView.removeFromSuperview()
        })
        ref.observe(.childChanged, with: { (snapshot) in
            print("purchaseExpiresDate_1")

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["purchaseExpiresDate"] as? Int
                let timeInterval = NSDate().timeIntervalSince1970
                if key ?? 0 > Int(timeInterval){
                    if self.childChangedStatus == "1"{
                        print("purchaseExpiresDate_2")
                        self.childChangedStatus = "2"
                        self.initilizedView.removeFromSuperview()
                        self.performSegue(withIdentifier: "toRootHomeView1", sender: nil)
                    }
                }
            })
            
        })

    }
    
    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptUrl!) else {
            print("error")
            initilizedView.removeFromSuperview()
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
                self.initilizedView.removeFromSuperview()
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
//画面遷移用childChangeのトリガーとして”１”をセット
        self.childChangedStatus = "1"
        if Int(timeInterval) < latestExpireDate {
            self.purchaseStatus = "1"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金中","coachingPlan":"個人プラン","purchaseExpiresDate_yyyyMMdd":"\(purchaseExpiresDate_yyyyMMdd)"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)

//            self.purchaseButton.setTitle("さっそくはじめる", for: .normal)
//            self.purchaseButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//            self.purchaseButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        }else{
            self.purchaseStatus = "0"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金なし"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }
        //        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func closeButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAppRule") {
            if #available(iOS 13.0, *) {
                //                let nextData: applyFormViewController = segue.destination as! applyFormViewController
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    @IBAction func tappedButton(_ sender: Any) {
        
        if self.purchaseStatus == "1"{
            performSegue(withIdentifier: "toApplyList", sender: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "個人プランに加入しますか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                initilize()
                self.purchaseButton.isEnabled = false
//                self.purchaseButton.setTitle("支払処理中", for: .normal)
//                purchaseButton.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                purchaseButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                
                guard  let myProduct = self.myProduct else {
                    return
                }
                if SKPaymentQueue.canMakePayments(){
                    let payment = SKPayment(product: myProduct)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                self.purchaseButton.isEnabled = true
//                self.purchaseButton.setTitle("申し込む", for: .normal)
//                self.purchaseButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                self.purchaseButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func logoutView(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "ログアウトしていいですか？", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
            do{
                try Auth.auth().signOut()
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
            }catch let error as NSError{
                print(error)
            }
            print("OK")
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        
    }
    @IBAction func restore(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "以前購入した情報を復元しますか？", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
            (action: UIAlertAction!) -> Void in
            initilize()
            let timeInterval = NSDate().timeIntervalSince1970
            if Int(timeInterval) < self.purchaseExpiresDate ?? 0{
                let request = SKReceiptRefreshRequest()
                request.delegate = self
                request.start()
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "有効な購入履歴はありません。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    initilizedView.removeFromSuperview()

                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
