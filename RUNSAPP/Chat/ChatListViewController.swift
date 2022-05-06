//
//  ChatListViewController.swift
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

class ChatListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var TableView: UITableView!
    @IBOutlet weak var coachingPlan: UILabel!
    @IBOutlet weak var authStatus: UIButton!
    @IBOutlet weak var adminStatus: UILabel!

    var twoDimArray:[[Any]] = []
    var twoDimArray_re:[[Any]] = []
    var dicArray = [String:NSDictionary]()
    
    var chatIDArray = [String]()
    var dateArray = [String]()
    var chatTitleArray = [String]()
    var chatContentArray = [String]()
    
    var chatIDArray_re = [String]()
    var dateArray_re = [String]()
    var chatTitleArray_re = [String]()
    var chatContentArray_re = [String]()
    
    var selectedChatID: String?
    var selectedTeamID: String?
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
    var noApplyMessage = UILabel()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    let Ref = Database.database().reference()
    
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
        super.viewWillAppear(animated)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
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
                let ref1 = Ref.child("team").child("\(key1 ?? "-")").child("admin")
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
                                loadData_chat()
                                break
                            }else if snap == snapdata[snapdata.keys.sorted().last!]{
                                loadData_chat()
                            }
                        }
                    }
                })
            }else{
                loadData_chat()
            }
            
        })
    }
    func loadData_chat(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        noApplyMessage.text = "チャット履歴が\nありません"
        noApplyMessage.numberOfLines = 0
        noApplyMessage.frame = CGRect(x: viewWidth/4, y: 30, width: viewWidth/2, height: 100)
        noApplyMessage.textColor = .gray
        noApplyMessage.textAlignment = NSTextAlignment.center
        //Viewに追加
        TableView.addSubview(noApplyMessage)
        
        chatIDArray.removeAll()
        dateArray.removeAll()
        chatTitleArray.removeAll()
        chatContentArray.removeAll()
        dicArray.removeAll()
        twoDimArray.removeAll()
        twoDimArray_re.removeAll()
        
        var array = [Any]()
        let ref = Ref.child("chat").queryOrdered(byChild: "teamID").queryEqual(toValue: "\(selectedTeamID ?? "")")
        ref.observeSingleEvent(of: .value, with: { [self]
            (snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    array.removeAll()
                    let snap = snapdata[key]
                    
                    let searchData0 = snap!["date_yyyy"] ?? ""
                    let searchData1 = snap!["date"] ?? ""
                    let searchData2 = snap!["gameFlag"] ?? ""
                    
                    let data0 = snap!["chatID"]
                    let data1 = snap!["date_yyyyMMddHHmm"] ?? ""
                    let data2 = snap!["chatTitle"] ?? ""
                    let data3 = snap!["chatContent"] ?? ""
                    let data4 = snap!["replyedUid"] ?? ""
                    let data5 = snap!["uid"] ?? ""
                    let data6 = snap!["teamID"] ?? ""

                    chatIDArray.append(data0 as! String)
                    dateArray.append(data1 as! String)
                    chatTitleArray.append(data2 as! String)
                    chatContentArray.append(data3 as! String)
                    
                    if data4 as! String == ""{
                        if self.adminStatus.text == "コーチ"{
                            array = [data0 as Any,data1 as Any]
                            twoDimArray.append(array)
                            self.dicArray.updateValue(snapdata[key]! as NSDictionary, forKey: data0 as! String)

                        }else{
                            if data5 as! String == currentUid{
                                array = [data0 as Any,data1 as Any]
                                twoDimArray.append(array)
                                self.dicArray.updateValue(snapdata[key]! as NSDictionary, forKey: data0 as! String)
                            }
                        }
                    }
                    twoDimArray_re = twoDimArray.sorted{$0[1] as! String > $1[1] as! String}
                    

                    TableView.reloadData()
                    if key == snapdata.keys.sorted().last{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                            initilizedView.removeFromSuperview()
                           return
                        }
                    }
                }
            }else{
                print("早い！")
                self.initilizedView.removeFromSuperview()
                
            }
        })
        
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

        let cell = self.TableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath as IndexPath) as? ChatListTableViewCell
        
        cell!.chatTitle.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatTitle"] as? String
        cell!.date.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["date_yyyyMMddHHmm"] as? String
        cell!.chatText.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatContent"] as? String
        let answerFlag = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["answerFlag"] as? String
        
        if adminStatus.text != "コーチ" {
            cell!.userName.text = ""
            cell!.personImageview.isHidden = true

            if dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["status0"] as? String == "0"{

//                ０＝未読、１＝既読
                cell!.answerFlagImageView.image = UIImage(systemName:"envelope.badge")
                cell!.answerFlagImageView.tintColor = .systemRed

            }else{
                
                cell!.answerFlagImageView.image = UIImage(systemName:"envelope.open")
                cell!.answerFlagImageView.tintColor = .black

            }
        }else{
            cell!.userName.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["userName"] as? String

            if dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["status1"] as? String == "0"{

                cell!.answerFlagImageView.image = UIImage(systemName:"envelope.badge")
                cell!.answerFlagImageView.tintColor = .systemRed

            }else{
                
                cell!.answerFlagImageView.image = UIImage(systemName:"envelope.open")
                cell!.answerFlagImageView.tintColor = .black

            }

        }

        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatID = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatID"] as? String
        performSegue(withIdentifier: "toSelectedChat", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSelectedChat") {
            if #available(iOS 13.0, *) {
                let nextData: SelectedChatListViewController = segue.destination as! SelectedChatListViewController
                nextData.selectedChatID = self.selectedChatID ?? ""
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadData_chat()
    }
}
