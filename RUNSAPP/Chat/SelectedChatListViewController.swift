//
//  SelectedChatListViewController.swift
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

class SelectedChatListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,ChatInputAccessoryViewDelegate,UIGestureRecognizerDelegate{
    
    @IBOutlet var TableView: UITableView!
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatContent: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var stayNotOpenButton: UIButton!
    
    var twoDimArray:[[Any]] = []
    var twoDimArray_re:[[Any]] = []
    var dicArray = [String:NSDictionary]()
    
    var coachUidArray = [String]()
    
    var status0:String?
    var status1:String?
    var selectedUidArray = [String]()
    
    var selectedChatID: String?
    var selectedTeamID: String?

    //    var chatTitle: String?
    //    var chatContent: String?
    //    var date: String?
    var uid: String?
    var toUid: String?
    var linkString: String?
    var adminStatus: String?

    var envelopStatus: String?

    var linkTextArray = [String]()
    var range:NSRange = NSRange()
    var notlinkText_int:Int = 0
    var linkText:String = String()
    
    var refreshParameter: String?
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var initilizedView2: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
    var noApplyMessage = UILabel()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    let Ref = Database.database().reference()
    
    override var inputAccessoryView: UIView? {
        get {
            return ChatInputAccessoryView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        //        loadData_profile()
        setting()
        initilize()
        loadData1()
        loadData2()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func setting(){
        envelopStatus = "0"
        let picture = UIImage(systemName: "envelope.open")
        stayNotOpenButton.setImage(picture, for: .normal)
        stayNotOpenButton.setTitle("", for: .normal)
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
        settingButton.addTarget(self, action: #selector(self.closePage1(_:)), for: UIControl.Event.touchUpInside)
        
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
    @objc func closePage1(_ sender: UIButton){
        
        initilizedView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
        
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
                        let data = snap!["uid"] ?? ""
                        coachUidArray.append(data as! String)
                        if currentUid == data as! String{
                            adminStatus = "1"
                            let statusData = ["status1":"1"]
                            let ref2 = self.Ref.child("chat").child("\(selectedChatID!)")
                            ref2.updateChildValues(statusData)

                        }
                        if snap == snapdata[snapdata.keys.sorted().last!]{
                            TableView.reloadData()
                            scrollToBottom()
                            
                            if adminStatus != "1"{
                                let statusData = ["status0":"1"]
                                let ref2 = self.Ref.child("chat").child("\(selectedChatID!)")
                                ref2.updateChildValues(statusData)
                            }
                        }
                    }
                }else{
                    TableView.reloadData()
                    scrollToBottom()
                    
                }
            })
            
        })
    }
    func scrollToBottom(){
        print("twoDimArray.count:\(twoDimArray.count)")
        if twoDimArray.count >= 1{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let indexPath = NSIndexPath(row: self.twoDimArray.count-1, section: 0)
                self.TableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: false)
                print("bottom")
            }
            
        }
    }
    
    func loadData1(){
        let ref0 = Ref.child("chat").child("\(self.selectedChatID ?? "-")")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key0 = value?["uid"] as? String
            let key1 = value?["chatTitle"] as? String
            let key2 = value?["chatContent"] as? String
            let key3 = value?["date_yyyyMMddHHmm"] as? String
            let key4 = value?["toUid"] as? String
            let key5 = value?["userName"] as? String
            uid = key0
            chatTitle.text = key1
            chatContent.text = key2
            date.text = key3
            toUid = key4
            userName.text = key5
        })
        
    }
    func loadData2(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        noApplyMessage.text = "返信履歴がありません"
        noApplyMessage.frame = CGRect(x: viewWidth/4, y: 200, width: viewWidth/2, height: 50)
        noApplyMessage.textColor = .gray
        noApplyMessage.textAlignment = NSTextAlignment.center
        //Viewに追加
        TableView.addSubview(noApplyMessage)
        
        dicArray.removeAll()
        twoDimArray.removeAll()
        twoDimArray_re.removeAll()
        linkTextArray.removeAll()
        
        var array = [Any]()
        let ref = Ref.child("chat").queryOrdered(byChild: "replyedChatID").queryEqual(toValue: "\(selectedChatID ?? "-")")
        ref.observeSingleEvent(of: .value, with: { [self]
            (snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                
                for key in snapdata.keys.sorted(){
                    array.removeAll()
                    let snap = snapdata[key]
                    
                    let data0 = snap!["chatID"]
                    let data1 = snap!["date_yyyyMMddHHmm"] ?? ""
                    let data2 = snap!["chatTitle"] ?? ""
                    let data3 = snap!["chatContent"] ?? ""
                    
                    
                    notlinkText_int = 0
                    let array_link = (data3 as AnyObject).components(separatedBy: .newlines)
                    if (data3 as AnyObject).contains("https://") || (data3 as AnyObject).contains("http://"){
                        for s in array_link {
                            if s.contains("https://") || s.contains("http://"){
//                                range = (s as NSString).range(of: String(s))
                                linkText = String(s)
                                linkTextArray.append(linkText)
                                break
                            }else{
                                notlinkText_int += s.count
                            }
                        }
                    }else{
                        linkTextArray.append("")
                    }
                    
                    
                    //                    if searchData0 as! String == "2022" && searchData2 as! String == "1"{
                    array = [data0 as Any,data1 as Any]
                    twoDimArray.append(array)
                    dicArray.updateValue(snapdata[key]! as NSDictionary, forKey: data0 as! String)
                    //                    }
                    twoDimArray_re = twoDimArray.sorted{$1[1] as! String > $0[1] as! String}
                    // -> true
                    if snap == snapdata[snapdata.keys.sorted().last!]{
                        loadData_profile()
                        break
                    }
                }
            }else{
                self.initilizedView.removeFromSuperview()
                loadData_profile()
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
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath as IndexPath) as? SelectedChatListTableViewCell
        cell!.userName.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["userName"] as? String
        cell!.date.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["date_yyyyMMddHHmm"] as? String
        cell!.chatText.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatContent"] as? String
        if coachUidArray.contains((dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["uid"] as? String) ?? "") == true {
            cell!.iconImageView.image = UIImage(systemName:"person.circle")
            cell!.iconImageView.tintColor = .systemPink
        }else{
            cell!.iconImageView.image = UIImage(systemName:"person.circle")
            cell!.iconImageView.tintColor = .black
        }
        if indexPath.row == twoDimArray.count-1 {
            self.initilizedView.removeFromSuperview()
        }
        
        // リンク化させる場所を青くさせる。
        let chatID = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatID"] as? String
        linkString = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["chatContent"] as? String

        cell!.linkButton.isHidden = true
        print(linkTextArray[indexPath.row])
        if linkTextArray[indexPath.row] != ""{
            cell!.linkButton.isHidden = false
            cell!.linkButton.addTarget(self, action: #selector(linkButtonTapped(_:)), for: .touchUpInside)
            cell!.linkButton.tag = indexPath.row
            cell!.linkButton.setTitle("", for: .normal)
        }
        
        
//        if cell!.chatText.gestureRecognizers?.count ?? 0 == 0{
//
//            let selectedArray = linkTextArray.filter { ($0.first as? String) == "\(chatID ?? "")" }
//            if selectedArray.isEmpty == false{
//                let notlinkText_int:Int = ((selectedArray[0][3] as? Int?) ?? 0)!
//                let linkText_range:NSRange = (selectedArray[0][2] as! NSRange?)!
//                let attributedString = NSMutableAttributedString(string: linkString ?? "")
//                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSRange(notlinkText_int...linkText_range.upperBound-1+notlinkText_int))
//                cell!.chatText.attributedText = attributedString
//
//                cell!.chatText.isUserInteractionEnabled = true
//                cell!.chatText.tag = indexPath.row
//
//                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
//                tapGestureRecognizer.delegate = self
//
//                cell!.chatText.addGestureRecognizer(tapGestureRecognizer)
//
//            }else{
//
//            }
//
//        }
        
        //
//        if linkTextArray.count >= 1{
//            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
//            tapGestureRecognizer.delegate = self
//
//            for i in 0...linkTextArray.count-1{
//                if linkTextArray[i][0] as? String == chatID{
//                    if cell!.chatText.gestureRecognizers?.count ?? 0 == 0 {
//                        print("chatID:\(chatID!)_recognizer:\(cell!.chatText.gestureRecognizers?.count ?? 0)")
//                        let notlinkText_int:Int = linkTextArray[i][3] as! Int
//                        let linkText_range:NSRange = linkTextArray[i][2] as! NSRange
//                        let attributedString = NSMutableAttributedString(string: linkString ?? "")
//                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSRange(notlinkText_int...linkText_range.upperBound-1+notlinkText_int))
//                        cell!.chatText.attributedText = attributedString
//
//                        cell!.chatText.isUserInteractionEnabled = true
//                        cell!.chatText.tag = i
//
//                        cell!.chatText.addGestureRecognizer(tapGestureRecognizer)
//                        print(cell!.chatText.text ?? "")
//                        break
//                    }
//                }
//            }
//
//        }
        
        return cell!
        
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let indexPath = NSIndexPath(row: twoDimArray.count-1, section: 0)
    //        tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    //    }
    @objc func linkButtonTapped(_ sender: UIButton) {
        
        let url_string = linkTextArray[sender.tag]
        let url = URL(string: "\(url_string)")
        if UIApplication.shared.canOpenURL(url!) {
            
            UIApplication.shared.open(url!)
            
        }
    }
//    @objc func tapGesture(gestureRecognizer: UITapGestureRecognizer) {
//        print("gestureRecognizer.view!.tag:\(gestureRecognizer.view!.tag)")
//        print("linkTextArray:\(linkTextArray[gestureRecognizer.view!.tag])")
//
//        let url_string = linkTextArray[gestureRecognizer.view!.tag][1] as! String
//        let url = URL(string: "\(url_string)")
//        if UIApplication.shared.canOpenURL(url!) {
//
//            UIApplication.shared.open(url!)
//
//        }
//
//    }
    
    private lazy var ChatInputAccessoryView: ChatInputAccessoryView = {
        let view = RUNSAPP.ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBAction func stayNotOpenButtonTapped(_ sender: Any) {
        
        if envelopStatus == "1"{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "このメッセージを既読にしますか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                
                let picture = UIImage(systemName: "envelope.open")
                stayNotOpenButton.setImage(picture, for: .normal)
                stayNotOpenButton.backgroundColor = .black
                
                if adminStatus == "1"{
    //                コーチだったらコーチ既読（1）
                    status1 = "1"
                }else{
    //                ユーザーだったらユーザー既読(1)
                    status0 = "1"
                }

                let data = ["status0":"\(status0 ?? "")","status1":"\(status1 ?? "")"]
                let ref = self.Ref.child("chat").child("\(selectedChatID!)")
                ref.updateChildValues(data)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

            
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "このメッセージを未読にしますか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                
                let picture = UIImage(systemName: "envelope.badge")
                stayNotOpenButton.setImage(picture, for: .normal)
                stayNotOpenButton.backgroundColor = .systemRed
                
                envelopStatus = "1"
                
                if adminStatus == "1"{
    //                コーチだったらコーチ未読（0）
                    status1 = "0"
                }else{
    //                ユーザーだったらユーザー未読(0)
                    status0 = "0"
                }

                let data = ["status0":"\(status0 ?? "")","status1":"\(status1 ?? "")"]
                let ref = self.Ref.child("chat").child("\(selectedChatID!)")
                ref.updateChildValues(data)
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
    
    
    func tappedSendButton(text: String) {
        view.endEditing(true)
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信していいですか？", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
            (action: UIAlertAction!) -> Void in
            
            ChatInputAccessoryView.removeText()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if self.view.contains(self.initilizedView){
                    self.timeout()
                }
                return
            }
            
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

            var coachUid_re:String
            

            if adminStatus == "1"{
//                コーチだったらユーザー未読（0）、コーチ送信済み(1)
                status0 = "0"
                status1 = "1"
                toUid = uid
            }else{
//                ユーザーだったらユーザー送信済み（1）、コーチ未読(0)
                status0 = "1"
                status1 = "0"
            }

            let data1 = ["chatID":"\(chatID)","toUid":"\(toUid ?? "")","replyedChatID":"\(selectedChatID ?? "")","selectedTeamID":"\(selectedTeamID ?? "")","uid":"\(self.currentUid)","userName":"\(self.currentUserName)","chatContent":"\(text)","answerFlag":"0","created_at":"\(date_yyyyMMddHHmmSS)","date_yyyyMMddHHmm":"\(date_yyyyMMddHHmm)","date_yyyyMMdd":"\(N_date_yyyy)"+"\(N_date_mm)"+"\(N_date_dd)" as Any] as [String : Any]
            let ref1 = self.Ref.child("chat").child("\(chatID)")
            ref1.updateChildValues(data1)
            
            print("status0:\(status0)")
            print("status1:\(status1)")
            let data2 = ["status0":"\(status0 ?? "")","status1":"\(status1 ?? "")"]
            let ref2 = self.Ref.child("chat").child("\(selectedChatID!)")
            ref2.updateChildValues(data2)



//            for uid in selectedUidArray{
//                let data3 = ["fcmTrigger":"1"]
//                let ref3 = self.Ref.child("user").child("\(uid)").child("fcmTrigger")
//                ref3.updateChildValues(data3)
//            }

            loadData2()
            if text.contains("https://") || text.contains("http://"){
                let alert: UIAlertController = UIAlertController(title: "確認", message: "リンク付きテキストは１つのメッセージにつき１つまでです。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                    (action: UIAlertAction!) -> Void in
                    
                    
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
                })
                
                alert.addAction(cancelAction)
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
