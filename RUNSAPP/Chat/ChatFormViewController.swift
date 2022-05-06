//
//  ChatFormViewController.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/03.
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

class ChatFormViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var coachName: UITextField!
    @IBOutlet weak var chatTitle: UITextField!
    @IBOutlet weak var chatText: UITextView!
    @IBOutlet weak var coachIntro: UILabel!
    
    var selectedTeamID: String?
    var chatLimitBasic:Int?
    var chatCountArray = [String]()

    var coachUidArray = ["選択してください"]
    var coachNameArray = ["選択してください"]
    var coachIntroArray = ["選択してください"]

    var pickerview0: UIPickerView = UIPickerView()
    
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    let Ref = Database.database().reference()
    
    override func viewDidLoad() {
        loadData_profile()
        checkChatNumber()
        pickerviewData()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func checkChatNumber(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let date_yyyymm = formatter.string(from: Date())
        print(date_yyyymm)
        
        //        if self.selectedTeamID != nil{
        //            let ref = Ref.child("team").child("\(self.selectedTeamID!)").child("accountInfo")
        //            ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //                let value = snapshot.value as? NSDictionary
        //                let key = value?["applyLimitBasic"] as? Int ?? 0
        //                self.applyLimitBasic = Int(key)
        //                self.teamName = "団体利用"                //                print("団体申込制限：\(self.applyLimit)")
        //            })
        //        }else{
        let ref0 = Ref.child("team").child("runs").child("setting").child("inAppPurchase")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key0 = value?["chatLimitBasic"] as? Int ?? 0
            self.chatLimitBasic = Int(key0)
            print("個人申込制限：\(self.chatLimitBasic)")
        })
        //        }
        
        let ref = Ref.child("chat").queryOrdered(byChild: "uid").queryEqual(toValue: "\(currentUid)")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key = snap!["date_yyyyMMdd"] as? String
                    if key?.contains("\(date_yyyymm)") == true{
                        self.chatCountArray.append(key ?? "")
                    }
                }
            }
        })
    }
    func loadData_profile(){
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["teamID"] as? String
            if key1 != ""{
                selectedTeamID = key1
            }else{
                selectedTeamID = "runs"
            }
            let ref1 = Ref.child("team").child("\(selectedTeamID!)").child("admin")
            ref1.observeSingleEvent(of: .value, with: { [self]
                (snapshot) in
                if let snapdata = snapshot.value as? [String:NSDictionary]{
                    for key in snapdata.keys.sorted(){
                        let snap = snapdata[key]
                        let data0 = snap!["uid"] ?? ""
                        let data1 = snap!["userName"] ?? ""
                        let data2 = snap!["coachIntro"] ?? ""
                        coachUidArray.append(data0 as! String)
                        coachNameArray.append(data1 as! String)
                        coachIntroArray.append(data2 as! String)
                    }
                }
            })
            
        })
    }
    
    func pickerviewData(){
        coachName.text = ""
        pickerview0.delegate = self
        pickerview0.dataSource = self
        pickerview0.tag = 0
        pickerview0.showsSelectionIndicator = true
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        coachName.inputView = pickerview0
        coachName.inputAccessoryView = toolbar
        
    }
    @objc func done() {
        self.view.endEditing(true)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView{
        
        let label = (view as? UILabel) ?? UILabel()
        label.text = self.coachNameArray[row]
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return coachNameArray.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if coachName.text == "選択してください"{
            return ""
        }else{
            return coachNameArray[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        
        coachName.text = coachNameArray[row]
        coachIntro.text = coachIntroArray[row]

        if coachName.text == "選択してください"{
            coachName.text = ""
            coachIntro.text = "-"
        }
        
    }
    
    @IBAction func sendData(_ sender: Any) {
        if selectedTeamID == "runs"{
            if self.chatLimitBasic ?? 0 <= self.chatCountArray.count{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "月の申込可能回数を既に超えています。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                
                print("error")
                return
            }
        }
        if coachName.text!.isEmpty || chatText.text!.isEmpty{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }else{
            
            let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信していいですか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                
                let now = NSDate()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
                let date_yyyyMMddHHmmSS = formatter.string(from: now as Date)
                
                let formatter0 = DateFormatter()
                formatter0.dateFormat = "yyyy/MM/dd HH:mm"
                let date_yyyyMMddHHmm = formatter0.string(from: Date())
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "yyyy"
                let N_date_yyyy = formatter1.string(from: now as Date)
                
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "MM"
                let N_date_mm = formatter2.string(from: now as Date)
                
                let formatter3 = DateFormatter()
                formatter3.dateFormat = "dd"
                let N_date_dd = formatter3.string(from: now as Date)
                
                let chatID = "\(date_yyyyMMddHHmmSS)"+"_chat_"+"\(self.currentUid)"

                let index = coachNameArray.firstIndex(of: "\(coachName.text!)")
                
                let data1 = ["chatID":"\(chatID)","uid":"\(self.currentUid)","toUid":"\(coachUidArray[index!])","teamID":"\(self.selectedTeamID ?? "")","userName":"\(self.currentUserName)","chatTitle":"\(self.chatTitle.text ?? "")","chatContent":"\(self.chatText.text ?? "")","status0":"1","status1":"0","answerFlag":"0","created_at":"\(date_yyyyMMddHHmmSS)","date_yyyyMMddHHmm":"\(date_yyyyMMddHHmm)","date_yyyyMMdd":"\(N_date_yyyy)"+"\(N_date_mm)"+"\(N_date_dd)" as Any] as [String : Any]
                let ref1 = self.Ref.child("chat").child("\(chatID)")
                ref1.updateChildValues(data1)

                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
