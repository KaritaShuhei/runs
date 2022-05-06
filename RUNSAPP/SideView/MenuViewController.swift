//
//  MenuViewController.swift
//
//  Created by 刈田修平 on 2020/11/21.
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
import UserNotifications

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var menuArray = ["プロフィール情報","ミーティング情報","利用規約","プライバシーポリシー","通知設定"]
    var purchaseExpiresDate: Int?
    var adminStatus: String?

    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    @IBOutlet var menuView: UIView!
    @IBOutlet var TableView: UITableView!
    @IBOutlet var userName: UILabel!
//    @IBOutlet weak var purchaseStatusLabel: UILabel!

//    @IBOutlet var purchaseStatus: UILabel!
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let Ref = Database.database().reference()

    override func viewDidLoad() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        initilize()
        loadData_profile()
        TableView.dataSource = self
        TableView.delegate = self
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fcmStatus()
        self.TableView.reloadData()
        super.viewWillAppear(animated)
        
    }
    func fcmStatus(){

        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                self.menuArray[4] = "通知設定：現在ON"

                let data:[String:AnyObject]=["fcmTokenStatus":"1"] as [String : AnyObject]
                let dbRef = Database.database().reference()
                dbRef.child("user").child(self.currentUid).child("profile").updateChildValues(data)
                print("許可")
            }
            else {
                self.menuArray[4] = "通知設定：現在OFF"
 
                let data:[String:AnyObject]=["fcmTokenStatus":"0"] as [String : AnyObject]
                let dbRef = Database.database().reference()
                dbRef.child("user").child(self.currentUid).child("profile").updateChildValues(data)
                print("未許可")
            }
        })
    }

    func initilize(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .white
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.color = .gray
        ActivityIndicator.startAnimating()

        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true

        //Viewに追加
        initilizedView.addSubview(ActivityIndicator)
        view.addSubview(initilizedView)
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
                                self.adminStatus = "1"
                                break
                            }else if snap == snapdata[snapdata.keys.sorted().last!]{
                                self.adminStatus = "0"
                            }
                        }
                    }else{
                    }
                })
            }else{
            }
        })
    }

    func loadData(){

        
        let ref = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["userName"] as? String ?? ""
            self.userName.text = "ようこそ、 "+"\(key1)"+" さん"
        })
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["coachingPlan"] as? String
            if key != nil{
//                self.purchaseStatusLabel.text = key

            }else{
//                self.purchaseStatusLabel.text = "未認証"
            }
            
        })
        self.initilizedView.removeFromSuperview()

    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
                
       
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath as IndexPath) as? MenuTableViewCell
        cell!.menu.text = self.menuArray[indexPath.row]
        if indexPath.row == 0{
            cell!.menuIconImageView.image = UIImage(systemName:"person.crop.square")
        }else if indexPath.row == 1{
            cell!.menuIconImageView.image = UIImage(systemName:"calendar")
        }else if indexPath.row == 2{
            cell!.menuIconImageView.image = UIImage(systemName:"doc.plaintext")
        }else if indexPath.row == 3{
            cell!.menuIconImageView.image = UIImage(systemName:"square.and.at.rectangle")
        }else{
            cell!.menuIconImageView.image = UIImage(systemName:"envelope.badge")
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "myProfile", sender: nil)
        }else if indexPath.row == 1{
            if adminStatus == "1"{
                performSegue(withIdentifier: "toMeetingInfoView", sender: nil)
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "コーチ専用のメニューです。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    
                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }else if indexPath.row == 2{
            performSegue(withIdentifier: "appRule", sender: nil)
        }else if indexPath.row == 3{
            performSegue(withIdentifier: "privacyPolicy", sender: nil)
        }else{
            // OSの通知設定画面へ遷移
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    // iOS10以降
                    UIApplication.shared.open(url, options: [: ], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}