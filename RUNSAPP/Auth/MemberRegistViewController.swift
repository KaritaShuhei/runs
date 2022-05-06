//
//  MemberRegist2ViewController.swift
//  clubsupApp
//
//  Created by 原井川　千夏 on 2022/01/02.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseEmailAuthUI

class MemberRegistViewController: UIViewController,FUIAuthDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    var selectedTeamID:String?
    
    let Ref = Database.database().reference()
    
    let providers: [FUIAuthProvider] = [
        FUIEmailAuth()
    ]
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    
    var pickerview0: UIPickerView = UIPickerView()
    var yyyyArray = [String]()
    var mmArray = [String]()
    var ddArray = [String]()
    var yyyyRow:String = "1990"
    var mmRow:String = "1"
    var ddRow:String = "1"
    
    override func viewDidLoad() {
        //        loadData()
        birthPickerViewData()
        self.authUI.delegate = self
        self.authUI.providers = providers
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func birthPickerViewData(){
        for i in 1980..<2022{
            yyyyArray.append(String(i))
        }
        for i in 1..<12{
            mmArray.append(String(i))
        }
        for i in 1..<31{
            ddArray.append(String(i))
        }
        pickerview0.delegate = self
        pickerview0.dataSource = self
        pickerview0.tag = 0
        pickerview0.selectRow(0, inComponent: 0, animated: false)
        pickerview0.selectRow(0, inComponent: 1, animated: false)
        pickerview0.selectRow(0, inComponent: 2, animated: false)
        // インプットビュー設定
        birthdayTextField.inputView = pickerview0
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return yyyyArray.count
        case 1:
            return mmArray.count
        case 2:
            return ddArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return yyyyArray[row]
        case 1:
            return mmArray[row]
        case 2:
            return ddArray[row]
        default:
            return "error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            yyyyRow = yyyyArray[row]
            birthdayTextField.text = "\(yyyyRow)/" + "\(mmRow)/" + "\(ddRow)"
        case 1:
            mmRow = mmArray[row]
            birthdayTextField.text = "\(yyyyRow)/" + "\(mmRow)/" + "\(ddRow)"
        case 2:
            ddRow = ddArray[row]
            birthdayTextField.text = "\(yyyyRow)/" + "\(mmRow)/" + "\(ddRow)"
        default:
            break
        }
    }
    func keyboardDismiss(){
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
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
    //    func loadData(){
    //        let ref = Ref.child("team")
    //        ref.child("\(selectedTeamID!)").child("profile").observeSingleEvent(of: .value, with: { snapshot in
    //            // Get user value
    //            let value = snapshot.value as? NSDictionary
    //            let data = value?["teamName"] as? String ?? ""
    //            self.teamNameTextField.text = data
    //
    //        }) { error in
    //            print(error.localizedDescription)
    //        }
    //    }
    @IBAction func registButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if nameTextField.text == "" || emailTextField.text == "" || passTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            initilize()
            Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passTextField.text ?? "") { authResult, error in
                
                if authResult?.user == nil {
                    let alert: UIAlertController = UIAlertController(title: "確認", message: "会員情報に不備があります。再度入力してください。", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.initilizedView.removeFromSuperview()
                    
                }else{
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.nameTextField.text ?? ""
                    changeRequest?.commitChanges { error in
                        let currentUid:AnyObject = Auth.auth().currentUser!.uid as AnyObject
                        let currentName:AnyObject = Auth.auth().currentUser!.displayName! as AnyObject
                        let currentEmail:AnyObject = Auth.auth().currentUser!.email! as AnyObject
                        let data0:[String:AnyObject]=["uid":"\(currentUid)","userName":"\(currentName)","adminUserFlag":"0","teamID":"\(self.selectedTeamID ?? "")","birthday":"\(self.birthdayTextField.text!)","email":"\(currentEmail)","userRuleChecked":"0","purchaseExpiresDate":0,"purchaseExpiresDate_ms":0,"purchaseStatus":"課金なし"] as [String : AnyObject]
                        
                        self.Ref.child("user").child(currentUid as! String).child("profile").updateChildValues(data0)
                        //                    self.Ref.child("team").child(self.selectedTeamID!).child("userList").child(currentUid as! String).updateChildValues(data0)
                        self.performSegue(withIdentifier: "toAppRule", sender: nil)
                        self.initilizedView.removeFromSuperview()
                        
                    }
                }
            }
        }
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
