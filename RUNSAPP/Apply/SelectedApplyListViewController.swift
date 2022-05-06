//
//  selectedApplyListViewController.swift
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
import Charts
import youtube_ios_player_helper

class SelectedApplyListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, YTPlayerViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var answerFlag: UILabel!
    @IBOutlet weak var coachingContents: UILabel!
    @IBOutlet weak var coachingContentsImageView: UIImageView!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var playVideo: UIButton!
    @IBOutlet var playVideo2: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var meetingDate: UILabel!
    @IBOutlet weak var meetingInfo: UILabel!
    var meetingURL: String?
    @IBOutlet weak var buttonForMeeting: UIButton!
    
    @IBOutlet weak var coachName: UILabel!
    @IBOutlet weak var coachNameKana: UILabel!
    @IBOutlet weak var coachIntroduction: UILabel!
    @IBOutlet weak var coachIconImageView: UIImageView!

    @IBOutlet weak var scoreCriteria1: UILabel!
    @IBOutlet weak var scoreCriteria2: UILabel!
    @IBOutlet weak var scoreCriteria3: UILabel!
    @IBOutlet weak var scoreCriteria4: UILabel!
    @IBOutlet weak var scoreCriteria5: UILabel!
    @IBOutlet weak var score1: UILabel!
    @IBOutlet weak var score2: UILabel!
    @IBOutlet weak var score3: UILabel!
    @IBOutlet weak var score4: UILabel!
    @IBOutlet weak var score5: UILabel!
    
    @IBOutlet weak var adminText1: UILabel!
    @IBOutlet weak var adminText2: UILabel!
    @IBOutlet var comment: UILabel!
    @IBOutlet weak var review_star_button: UIButton!
    
    @IBOutlet weak var statusLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var angleImageView: UIView!
    @IBOutlet weak var angleView: UIView!
    
    var review_star: String?
    var x_userValue:Int?
    
    var selectedApplyID: String?
    //    var selectedYYYYMM: String?
    var selectedTeamID: String?
    //    var selectedYYYYMM_re: String?
    var selectedAnaCriteriaID: String?
    
    var adminStatus: String?
    
    
    var practiceURL: String?
    
    let imagePickerController = UIImagePickerController()
    var pickerview: UIPickerView = UIPickerView()
    var cache: String?
    var videoURL: URL?
    var playUrl:NSURL?
    var data:Data?
    var videoURL2: URL?
    var playUrl2:NSURL?
    var data2:Data?
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
        
    var transRotate1 = CGAffineTransform()
    var transRotate2 = CGAffineTransform()
    
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    var cellWitdh: CGFloat!
    var cellHeight: CGFloat!
    var cellOffset: CGFloat!
    var navHeight: CGFloat!
    
    override func viewDidLoad() {
        
        setting()
        initilize()
//        viewWidth = view.frame.width
//        viewHeight = view.frame.height
//        //        //ナビゲーションバーの高さ
//        navHeight = self.navigationController?.navigationBar.frame.size.height
        
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        loadDataApply()
        loadDataAnswer()
        download()
        loadData_profile()
        statusLabelLotation()
    }
    func setting(){
        UIApplication.shared.applicationIconBadgeNumber = 0
        coachIconImageView.image = UIImage(systemName:"person.circle")
        review_star_button.isHidden = true
    }
    //    override func viewWillAppear(_ animated: Bool) {
    //        loadDataAnswer()
    //        super.viewWillAppear(animated)
    //    }
    
    func statusLabelLotation(){
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
        statusLabelView.transform = transRotate1
    }
    func setPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 13
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        
        pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
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
        settingButton.backgroundColor = .systemOrange
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
                        if data as! String == currentUid{
                            adminStatus = "1"
                            editButton.isHidden = false
                            editButton.isEnabled = true
                            editButton.setTitle("", for: .normal)
                        }
                    }
                }
            })
            
        })
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let message = "この申込に対してコーチングを行いますか？"
        let alert: UIAlertController = UIAlertController(title: "確認", message: "\(message)", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toSelectedApplyListEdit", sender: nil)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    func loadDataApply(){
        
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
                
        let ref = Ref.child("apply").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["userName"] as? String ?? ""
            let key0 = value?["teamName"] as? String ?? ""
            let key1 = value?["teamID"] as? String ?? ""
            let key2 = value?["memo"] as? String ?? ""
            let key3 = value?["date_yyyyMMddHHmm"] as? String ?? ""
            let key4 = value?["coachingContents"] as? String ?? ""
            let key5 = value?["answerFlag"] as? String ?? ""
            let key6 = value?["review_star"] as? String ?? ""
            let key7 = value?["meetingDate"] as? String ?? ""

            self.userName.text = key
            if key0 != ""{
                self.teamName.text = "("+key0+")"
            }else{
                self.teamName.text = "(個人プラン)"
            }
            self.selectedTeamID = key1
            if key2 == ""{
                self.memo.text = "コメントなし"
            }else{
                self.memo.text = key2
            }
            self.date.text = key3

            if key4 != ""{
                self.coachingContents.text = key4
                if key4 == "解説動画"{
                    self.meetingDate.text = ""
                    self.meetingInfo.text = ""
                    self.buttonForMeeting.isHidden = true
                    self.coachingContentsImageView.image = UIImage(systemName:"video.bubble.left")
                }else if key4 == "ミーティング"{
                    self.coachingContentsImageView.image = UIImage(systemName:"person.2")
                }
            }else{
                self.coachingContents.text = ""
            }

            self.answerFlag.backgroundColor = .systemRed
            self.answerFlag.borderWidth = 1
            self.answerFlag.borderColor = .systemRed
            self.answerFlag.textColor = .white

            if key5 == "1"{
                //                self.noDataText()
                self.answerFlag.text = "待機中"
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "待機中"
            }else if key5 == "2"{
                //                loadData_ana()
//                SDImageCache.shared.clearMemory()
//                SDImageCache.shared.clearDisk()
//                coachIconImageView.image = UIImage(systemName:"myIcon2")
                self.review_star_button.isHidden = false
                self.answerFlag.text = "完了"
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "完了"
                self.answerFlag.backgroundColor = .white
                self.answerFlag.borderWidth = 1
                self.answerFlag.borderColor = .systemRed
                self.answerFlag.textColor = .systemRed
            }else if key5 == "3"{
                //                self.noDataText()
                self.answerFlag.text = "エラー"
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "エラー"
            }else if key5 == "0"{
                //                self.noDataText()
                self.answerFlag.text = "申込中"
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "申込中"
            }
            self.review_star = key6
            if self.review_star != ""{
                self.review_star_button.isHidden = true
            }
            self.meetingDate.text = key7

        })
        
        let textImage:String = self.selectedApplyID!+".png"
        let refImage = Storage.storage().reference().child("apply").child("\(self.selectedApplyID!)").child("\(textImage)")
        refImage.downloadURL { url, error in
            if error != nil {
                // Handle any errors
            } else {
                self.ImageView.sd_setImage(with: url, placeholderImage: nil)
            }
        }
        playVideo.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        
    }
    func loadDataAnswer(){
        let ref0 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("coach")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["coachName"] as? String ?? "-"
            let key2 = value?["coachNameKana"] as? String ?? ""
            let key3 = value?["coachIntro"] as? String ?? "-\n"
            self.coachName.text = key1
            if key1 == "-"{
                self.adminText1.text = "現在コーチが申込内容を確認中です。しばらくお待ちください。"
            }else{
                self.adminText1.text = ""
            }
            self.coachNameKana.text = key2
            self.coachIntroduction.text = key3
        })
        let ref1 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("deliverable")
        ref1.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["answerVideoID"] as? String ?? ""
            let key2 = value?["answerVideoURL"] as? String ?? ""
            let key3 = value?["comment"] as? String ?? ""
            let key4 = value?["meetingURL"] as? String ?? ""
            let key5 = value?["meetingInfo"] as? String ?? ""

            if key3 != ""{
                self.comment.text = key3
            }else{
                self.comment.text = "現在コーチからのコメントはありません。しばらくお待ちください。"
            }

            if key4 != ""{
                self.meetingURL = key4
            }else{
            }

            if key5 != ""{
                self.meetingInfo.text = key5
            }else{
                self.meetingInfo.text = "ミーティングIDが発行されるまでしばらくお待ちください"
            }
            
            playVideo2.removeTarget(self, action: #selector(playVideo2(_:)), for: .touchUpInside)
            playVideo2.removeTarget(self, action: #selector(playVideo2_alert(_:)), for: .touchUpInside)

            
            if key1 != ""{
                let textVideo:String = key1 + ".mp4"
                let refVideo = Storage.storage().reference().child("apply").child("\(self.selectedApplyID!)").child("\(textVideo)")
                refVideo.downloadURL{ url, error in
                    if (error != nil) {
                    } else {
                        self.playUrl2 = url as NSURL?
                        self.playVideo2.isHidden = false
                        print("download success!! URL:", url!)
                    }
                }
                playVideo2.addTarget(self, action: #selector(playVideo2(_:)), for: .touchUpInside)
            }else{
                playVideo2.addTarget(self, action: #selector(playVideo2_alert(_:)), for: .touchUpInside)
            }

        })
        let ref2 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("score")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as? NSDictionary
            let data1 = snap?["score1"] as? String ?? "-"
            let data2 = snap?["score2"] as? String ?? "-"
            let data3 = snap?["score3"] as? String ?? "-"
            let data4 = snap?["score4"] as? String ?? "-"
            let data5 = snap?["score5"] as? String ?? "-"
            let data6 = snap?["scoreCriteria1"] as? String ?? "-"
            let data7 = snap?["scoreCriteria2"] as? String ?? "-"
            let data8 = snap?["scoreCriteria3"] as? String ?? "-"
            let data9 = snap?["scoreCriteria4"] as? String ?? "-"
            let data10 = snap?["scoreCriteria5"] as? String ?? "-"
            self.score1.text = data1
            self.score2.text = data2
            self.score3.text = data3
            self.score4.text = data4
            self.score5.text = data5
            self.scoreCriteria1.text = data6
            self.scoreCriteria2.text = data7
            self.scoreCriteria3.text = data8
            self.scoreCriteria4.text = data9
            self.scoreCriteria5.text = data10
            if data1 == "-" || data1 == ""{
                self.adminText2.text = "現在コーチからの評価はありません。しばらくお待ちください。"
            }else{
                self.adminText2.text = "コーチから評価が届きました。確認しましょう。"
            }
        })
        
    }
    @IBAction func buttonTappedForMTG(_ sender: Any) {
        if coachingContents.text == "ミーティング" && answerFlag.text == "待機中"{
            let arr:[String] = meetingInfo.text!.components(separatedBy: .newlines)

            let url = URL(string: "\(arr[0])")!
            
            if UIApplication.shared.canOpenURL(url) {
            
                UIApplication.shared.open(url)

            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "有効なミーティングURLがありません。", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }
    }
    
    private func convertEnclosedNumber(num: Int) -> String? {
        if num < 0 || 50 < num {
            return nil
        }
        
        var char: String? = nil
        if 0 == num {
            let ch = 0x24ea
            char = String(UnicodeScalar(ch)!)
        } else if 0 < num && num <= 20 {
            let ch = 0x2460 + (num - 1)
            char = String(UnicodeScalar(ch)!)
        } else if 21 <= num && num <= 35 {
            let ch = 0x3251 + (num - 21)
            char = String(UnicodeScalar(ch)!)
        } else if 36 <= num && num <= 50 {
            let ch = 0x32b1 + (num - 36)
            char = String(UnicodeScalar(ch)!)
        }
        return char
    }
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        
        UIApplication.shared.open(URL)
        
        return false
    }
    @objc func playVideo(_ sender: UIButton) {
        let player = AVPlayer(url: playUrl! as URL
        )
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            controller.player!.play()
        }
    }
    @objc func playVideo2(_ sender: UIButton) {
        
        let player = AVPlayer(url: playUrl2! as URL
        )
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            controller.player!.play()
        }
    }
    @objc func playVideo2_alert(_ sender: UIButton) {
        let message = "現在、視聴できる解説動画はありません。"
        let alert: UIAlertController = UIAlertController(title: "確認", message: "\(message)", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    func download(){
        
        let textVideo:String = selectedApplyID!+".mp4"
        let refVideo = Storage.storage().reference().child("apply").child("\(self.selectedApplyID!)").child("\(textVideo)")
        refVideo.downloadURL{ url, error in
            if (error != nil) {
            } else {
                self.playUrl = url as NSURL?
                print("download success!! URL:", url!)
            }
            self.initilizedView.removeFromSuperview()
        }
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref.updateChildValues(data)
            }
            //            self.initilizedView.removeFromSuperview()
        })
        
    }
    
    
    @IBAction func toSelectedPremiumVideoButtonTapped(_ sender: Any) {
        if coachingContents.text == "プレミアム"{
            performSegue(withIdentifier: "toSelectedPremiumVideo", sender: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "オリジナル解説動画は、プレミアムコーチングのみ視聴可能です。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toSelectedApplyListEdit"){
            if adminStatus == "1"{
                if #available(iOS 13.0, *) {
                    let nextData: SelectedApplyListEditViewController = segue.destination as! SelectedApplyListEditViewController
                    nextData.selectedApplyID = self.selectedApplyID!
                } else {
                    // Fallback on earlier versions
                }
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "申込内容を編集できません", preferredStyle:  UIAlertController.Style.alert)
                
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }else{
            
        }
    }
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "キャンセル", height: 60) {
            print("-")
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "送信する", height: 60) {
            //            self.starLabel.text = "You rated \(ratingVC.cosmosStarRating.rating) stars"
            let ref = self.Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("summury")
            let data = ["review_star":"\(ratingVC.cosmosStarRating.rating)" as Any] as [String : Any]
            ref.updateChildValues(data)
            self.review_star_button.isHidden = true
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    
    @IBAction func showCustomDialogTapped(_ sender: Any) {
        if adminStatus == "1"{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "ユーザーによる評価が届くまでお待ちください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            showCustomDialog()
        }
    }
    
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップアップされる
        return .none
    }
}
