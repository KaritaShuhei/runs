//
//  applyListViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/04.
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
import SDWebImage
import PopupDialog

class ApplyListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var TableView: UITableView!
    @IBOutlet weak var adminStatus: UILabel!
    @IBOutlet weak var authStatus: UIButton!
    @IBOutlet weak var coachingPlan: UILabel!
    
    //    @IBOutlet weak var searchTextField1: UITextField!
    //    @IBOutlet weak var searchTextField2: UITextField!
    
    
    var array = [Any]()
    
    var twoDimArray:[[Any]] = []
    var twoDimArray_re:[[Any]] = []
    var dicArray = [String:NSDictionary]()
    
    
    var selectedApplyID: String?
    var selectedYYYYMM: String?
    var selectedTeamID: String?
    
    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoURL: URL?
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var noApplyMessage = UILabel()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
    
    var purchaseExpiresDate: Int?
    
    
    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        initilize()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        TableView.allowsSelection = false
        loadData_profile()
    }
    
    func initilize(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .white
        
        removeAllSubviews(parentView: initilizedView)
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [self] in
            if view.contains(initilizedView){
                timeout()
            }
            return
        }
    }
    func processing(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .white
        
        removeAllSubviews(parentView: initilizedView)
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.color = .gray
        ActivityIndicator.startAnimating()
        
        //        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true
        //
        //        //Viewに追加
        initilizedView.addSubview(ActivityIndicator)
        
        settingTextLabel.text = "ただいま、動画を送信中です。\nしばらくこのままでお待ちください。\n1分ほどかかる場合があります。"
        settingTextLabel.numberOfLines = 0
        settingTextLabel.frame = CGRect(x: 20, y: viewHeight/2 + 50, width: viewWidth-40, height: 100)
        settingTextLabel.textColor = .black
        settingTextLabel.textAlignment = NSTextAlignment.center
        
        initilizedView.addSubview(settingTextLabel)
        view.addSubview(initilizedView)
    }
    func timeout(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        
        removeAllSubviews(parentView: initilizedView)
        
        settingTextLabel.text = "タイムアウトにより処理が完了できませんでした。\n通信環境をご確認ください。"
        settingTextLabel.numberOfLines = 0
        settingTextLabel.frame = CGRect(x: 20, y: viewHeight/2 + 50, width: viewWidth-40, height: 100)
        settingTextLabel.textColor = .black
        settingTextLabel.textAlignment = NSTextAlignment.center
        
        settingButton.setTitle("閉じる", for: .normal)
        settingButton.frame = CGRect(x: 20, y: viewHeight/2 + 150, width: viewWidth - 40, height: 50)
        settingButton.backgroundColor = .black
        settingButton.cornerRadius = 25
        settingButton.setTitleColor(UIColor.white, for: .normal)
        settingButton.contentHorizontalAlignment = .center
        settingButton.addTarget(self, action: #selector(self.closePageByTimeout(_:)), for: UIControl.Event.touchUpInside)
        
        initilizedView.addSubview(settingTextLabel)
        initilizedView.addSubview(settingButton)
        
        view.addSubview(initilizedView)
    }
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    @objc func closePageByTimeout(_ sender: UIButton){
        
        initilizedView.removeFromSuperview()
        
    }
    
    func loadData_profile(){
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["coachingPlan"] as? String
            if self.adminStatus.text != "コーチ"{
                if key != nil{
                    self.coachingPlan.text = "現在の所属 - " + key!
                    let picture = UIImage(systemName: "doc")
                    self.authStatus.setImage(picture, for: .normal)
                    self.authStatus.isEnabled = false
                }else{
                    self.coachingPlan.text = "未認証"
                    let picture = UIImage(systemName: "plus")
                    self.authStatus.setImage(picture, for: .normal)
                    self.authStatus.isEnabled = true
                }
            }
            let key1 = value?["teamID"] as? String
            if key1 != ""{
                selectedTeamID = key1
            }else{
                selectedTeamID = "runs"
            }
            if key1 != ""{
                let ref1 = Ref.child("team").child("\(key1!)").child("admin")
                ref1.observeSingleEvent(of: .value, with: { [self]
                    (snapshot) in
                    if let snapdata = snapshot.value as? [String:NSDictionary]{
                        for key in snapdata.keys.sorted(){
                            let snap = snapdata[key]
                            let data = snap!["uid"] ?? ""
                            if data as! String == currentUid{
                                self.adminStatus.backgroundColor = .black
                                self.adminStatus.text = "コーチ"
                                self.coachingPlan.text = "現在コーチとして登録されています"
                                loadData_apply()
                                break
                            }else if snap == snapdata[snapdata.keys.sorted().last!]{
                                loadData_apply()
                            }
                        }
                    }else{
                        loadData_apply()
                    }
                })
            }else{
                loadData_apply()
            }
        })
    }
    
    func loadData_apply(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        noApplyMessage.text = "コーチング申込履歴が\nありません"
        noApplyMessage.numberOfLines = 0
        noApplyMessage.frame = CGRect(x: viewWidth/4, y: 30, width: viewWidth/2, height: 100)
        noApplyMessage.textColor = .gray
        noApplyMessage.textAlignment = NSTextAlignment.center
        //Viewに追加
        TableView.addSubview(noApplyMessage)
        
        dicArray.removeAll()
        twoDimArray.removeAll()
        twoDimArray_re.removeAll()
        
        
        let ref = Ref.child("apply").queryOrdered(byChild: "teamID").queryEqual(toValue: "\(selectedTeamID ?? "")")
        ref.observeSingleEvent(of: .value, with: { [self]
            (snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    array.removeAll()
                    let snap = snapdata[key]
                    
                    let searchData1 = snap!["date_yyyyMM"] ?? ""
                    let searchData2 = snap!["answerFlag"] ?? ""
                    
                    let data0 = snap!["applyID"] ?? ""
                    let data1 = snap!["memo"] ?? ""
                    let data2 = snap!["date_yyyyMMddHHmm"] ?? ""
                    let data3 = snap!["answerFlag"] ?? ""
                    let data4 = snap!["coachingContents"] ?? ""
                    let data5 = snap!["uid"] ?? ""
                    let data6 = snap!["teamID"] ?? ""
                    
                    if self.adminStatus.text == "コーチ" || data5 as! String == currentUid{
                        array = [data0 as Any,data2 as Any]
                        arrayDataSet(data0: data0 as! String, key: key, snapdata: snapdata)
                        
                        
                        //                        if searchTextField1.text == "" && searchTextField2.text == ""{
                        ////                            case1. 空欄の時は全データ取得
                        //                            arrayDataSet(data0: data0 as! String, key: key, snapdata: snapdata)
                        //                            print("case1???")
                        //                        }else if searchTextField1.text != "" && searchTextField2.text == ""{
                        ////                            case2. searchTextField1だけ検索されている時
                        //                            if searchTextField1.text == searchData1 as! String?{
                        //                                arrayDataSet(data0: data0 as! String, key: key, snapdata: snapdata)
                        //                            }
                        //                        }else if searchTextField1.text == "" && searchTextField2.text != ""{
                        ////                            case3. searchTextField2だけ検索されている時
                        //                            if searchTextField2.text == searchData2 as! String?{
                        //                                arrayDataSet(data0: data0 as! String, key: key, snapdata: snapdata)
                        //                            }
                        //                        }else{
                        ////                            case4. searchTextField1,2の両方が検索されているとき
                        //                            if searchTextField1.text == searchData1 as! String? && searchTextField2.text == searchData2 as! String?{
                        //                                arrayDataSet(data0: data0 as! String, key: key, snapdata: snapdata)
                        //                            }
                        //                        }
                    }
                    TableView.reloadData()
                    if key == snapdata.keys.sorted().last{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                            initilizedView.removeFromSuperview()
                            return
                        }
                    }
                }
            }else{
                self.initilizedView.removeFromSuperview()
            }
        })
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref0.updateChildValues(data)
            }
        })
        
        
    }
    func arrayDataSet(data0:String,key:String,snapdata:[String:NSDictionary]){
        twoDimArray.append(array)
        self.dicArray.updateValue(snapdata[key]! as NSDictionary, forKey: data0)
        twoDimArray_re = twoDimArray.sorted{$0[1] as! String > $1[1] as! String}
        
    }
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twoDimArray.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        noApplyMessage.isHidden = true
        TableView.allowsSelection = true
        
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "applyListCell", for: indexPath as IndexPath) as? ApplyListTableViewCell
        
        let memo = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["memo"] as? String
        if memo == ""{
            cell!.title.text = "コメントなし"
        }else{
            cell!.title.text = memo
        }
        cell!.meetingDate.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["meetingDate"] as? String ?? ""
        cell!.date.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["date_yyyyMMddHHmm"] as? String
        cell!.coachingContents.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["coachingContents"] as? String
        let answerFlag = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["answerFlag"] as? String
        
        cell!.answerFlag.backgroundColor = .systemRed
        cell!.answerFlag.borderWidth = 1
        cell!.answerFlag.borderColor = .systemRed
        cell!.answerFlag.textColor = .white
        
        
        if answerFlag == "0"{
            //            cell!.answerFlagImageView.image = UIImage(systemName:"paperplane")
            cell!.answerFlag.text = "申込中"
        }else if answerFlag == "1"{
            //            cell!.answerFlagImageView.image = UIImage(systemName:"hourglass.tophalf.filled")
            cell!.answerFlag.text = "待機中"
        }else if answerFlag == "2"{
            //            cell!.answerFlagImageView.image = UIImage(systemName:"envelope.badge")
            cell!.answerFlag.backgroundColor = .white
            cell!.answerFlag.borderWidth = 1
            cell!.answerFlag.borderColor = .systemRed
            cell!.answerFlag.textColor = .systemRed
            cell!.answerFlag.text = "完了"
        }else if answerFlag == "3"{
            //            cell!.answerFlagImageView.image = UIImage(systemName:"exclamationmark.circle")
            cell!.answerFlag.text = "エラー"
        }
        if adminStatus.text == "コーチ"{
            cell!.userName.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["userName"] as? String
        }else{
            cell!.userName.text = ""
            cell!.personImageview.isHidden = true
        }
        
        let applyID:String = (dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["applyID"] as? String)!
        let textImage:String = "\(applyID).png"
        let refImage = Storage.storage().reference().child("apply").child("\(applyID)").child("\(textImage)")
        refImage.downloadURL { url, error in
            if error != nil {
                // Handle any errors
            } else {
                cell!.ImageView.sd_setImage(with: url, placeholderImage: nil)
            }
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedApplyID = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["applyID"] as? String
        print("selectedApplyID:\(selectedApplyID ?? "")")
        performSegue(withIdentifier: "selectedApply", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectedApply") {
            if #available(iOS 13.0, *) {
                let nextData: SelectedApplyListViewController = segue.destination as! SelectedApplyListViewController
                nextData.selectedApplyID = self.selectedApplyID ?? ""
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadData_apply()
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
}
