//
//  clubPlanViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2022/03/15.
//

import UIKit
import Firebase
import FirebaseStorage

class CoachingPlan2ViewController: UIViewController {
    @IBOutlet var teamIDTextField: UITextField!
    @IBOutlet var passCodeTextField: UITextField!
    @IBOutlet var className: UITextField!
    var teamIDArray = [String]()
    var passCodeArray = [String]()
    var selectedTeamID:String?
    var purchaseStatus:String?
    let Ref = Database.database().reference()
    let currentUid:String = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func loadData(){
        let ref = Ref.child("team")
        ref.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key1 = snap!["teamID"] as? String {
                        self.teamIDArray.append(key1)
                        print(self.teamIDArray)
                    }
                    if let key2 = snap!["passcode"] as? String {
                        self.passCodeArray.append(key2)
                        print(self.passCodeArray)
                    }
                }
            }
        })
        
    }
    @IBAction func buttonTapped(_ sender: Any) {
        purchaseStatus = "課金中"
        self.view.endEditing(true)
        
        if teamIDTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDを入力してください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }else if className.text == "" || passCodeTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }else{
            let ref = Ref.child("team").child("\(teamIDTextField.text ?? "")").child("profile")
            ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key0 = value?["passcode"] as? String
                if key0 == passCodeTextField.text{
                    let key1 = value?["teamName"] as? String
                    let ref1 = Ref.child("user").child("\(currentUid)").child("profile")
                    let data = ["teamID":"\(teamIDTextField.text ?? "")","teamName":"\(key1 ?? "")","passcode":"\(passCodeTextField.text ?? "")","coachingPlan":"団体プラン","className":"\(className.text ?? "未登録")","purchaseStatus":"\(purchaseStatus ?? "")"]
                    ref1.updateChildValues(data)
                    
                    ref1.setValue(data) {
                      (error:Error?, ref:DatabaseReference) in
                      if let error = error {
                        print("Data could not be saved: \(error).")
                      } else {
                          let alert: UIAlertController = UIAlertController(title: "確認", message: "認証が完了しました。", preferredStyle:  UIAlertController.Style.alert)
                          let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                              (action: UIAlertAction!) -> Void in
                              self.performSegue(withIdentifier: "toRootHomeView2", sender: nil)

                          })
                          alert.addAction(defaultAction)
                          self.present(alert, animated: true, completion: nil)
                      }
                    }
                                        
                }else if className.text != ""{
                    let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDとパスコードが一致しません。もう一度入力して下さい。", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        
                    })
                    alert.addAction(defaultAction)
                    present(alert, animated: true, completion: nil)
                }else{
                    let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        
                    })
                    alert.addAction(defaultAction)
                    present(alert, animated: true, completion: nil)

                }
            })

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
