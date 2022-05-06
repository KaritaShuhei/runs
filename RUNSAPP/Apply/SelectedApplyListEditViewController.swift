//
//  SelectedApplyListEditViewController.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/04.
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

class SelectedApplyListEditViewController: UIViewController,UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate, UINavigationControllerDelegate {
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var answerFlag: UILabel!
//    @IBOutlet weak var answerFlagImageView: UIImageView!
    @IBOutlet weak var coachingPlan: UILabel!
    @IBOutlet weak var coachingContents: UILabel!
    @IBOutlet weak var coachingContentsImageView: UIImageView!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var playVideo: UIButton!
    @IBOutlet var ImageView2: UIImageView!
    @IBOutlet var playVideo2: UIButton!
    @IBOutlet weak var buttonForMeeting: UIButton!

    @IBOutlet weak var coachNameTextField: UITextField!
    @IBOutlet weak var coachIntroductionTextView: UITextView!
    @IBOutlet weak var coachIconImageView: UIImageView!

    @IBOutlet weak var scoreCriteria1: UITextField!
    @IBOutlet weak var scoreCriteria2: UITextField!
    @IBOutlet weak var scoreCriteria3: UITextField!
    @IBOutlet weak var scoreCriteria4: UITextField!
    @IBOutlet weak var scoreCriteria5: UITextField!
    @IBOutlet weak var score1: UITextField!
    @IBOutlet weak var score2: UITextField!
    @IBOutlet weak var score3: UITextField!
    @IBOutlet weak var score4: UITextField!
    @IBOutlet weak var score5: UITextField!

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var meetingTextView: UITextView!
    @IBOutlet weak var meetingInfoHowToRegister: UILabel!

    @IBOutlet weak var meetingDate: UILabel!
    @IBOutlet weak var meetingInfo: UILabel!
    
    @IBOutlet weak var statusLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!


    var selectedApplyID: String?
    var selectedTeamID: String?

    var cloudVideoURL: String?
    var cloudImageURL: String?

    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoAseet: PHAsset?
    var videoURL: URL?
    var playUrl:NSURL?
    var data:Data?
    var videoURL2: URL?
    var playUrl2:NSURL?
    var data2:Data?

    var pickerview0: UIPickerView = UIPickerView()
    var coachIDArray = [String]()
    var coachNameArray = [String]()
    var coachIntroArray = [String]()
    var selectedCoachID:String?
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
    var noApplyMessage = UILabel()
    var afterApplyMessage = UILabel()
    
    var transRotate1 = CGAffineTransform()
    var transRotate2 = CGAffineTransform()
    
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    var cellWitdh: CGFloat!
    var cellHeight: CGFloat!
    var cellOffset: CGFloat!
    var navHeight: CGFloat!

    var uploadTaskStatus0 = 0
    var uploadTaskStatus1 = 0

    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    let Ref = Database.database().reference()

    override func viewDidLoad() {
//        cameraAuthorization()
        initilize()
        pickerviewData()
        download()
        loadData_apply()
        loadData_coach()
        loadData_answer()
        statusLabelLotation()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func cameraAuthorization(){
  
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // フォトライブラリに写真を保存するなど、実施したいことをここに書く
                } else if status == .denied {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                        settingToPhotoAccess()
                        return
                    }

                }
            }
        } else {

        }
    }
    func settingToPhotoAccess(){
        let alert = UIAlertController(title: "", message: "写真へのアクセスを許可してください", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                return
            }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        })
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)

    }
    func setting(){
        self.playVideo2.isHidden = true
        coachNameTextField.text = coachNameArray[0]
        coachIntroductionTextView.text = coachIntroArray[0]
    }
    
    func statusLabelLotation(){
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
        statusLabelView.transform = transRotate1
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
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
    
    func pickerviewData(){
        pickerview0.delegate = self
        pickerview0.dataSource = self
        pickerview0.tag = 0
        pickerview0.showsSelectionIndicator = true
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        coachNameTextField.inputView = pickerview0
        coachNameTextField.inputAccessoryView = toolbar

    }
    @objc func done() {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerView.tag == 0{
        
            return coachIDArray.count
            
        } else {
        
            return 0

        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if pickerView.tag == 0 {
            return coachNameArray[row]
        } else {
            return ""
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {

        if pickerView.tag == 0 {
            coachNameTextField.text = coachNameArray[row]
            selectedCoachID = coachIDArray[row]
            coachIntroductionTextView.text = coachIntroArray[row]
            print(coachIntroArray)
        } else {

        }
    }
    func loadData_apply(){
        
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
                
        let ref = Ref.child("apply").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
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
                    self.buttonForMeeting.isHidden = true
                    self.coachingContentsImageView.image = UIImage(systemName:"video.bubble.left")
                    self.meetingTextView.text = "-"
                    self.meetingTextView.backgroundColor = .lightGray
                    self.meetingTextView.isEditable = false
                }else if key4 == "ミーティング"{
                    self.coachingContentsImageView.image = UIImage(systemName:"person.2")
                    self.meetingInfoHowToRegister.text = "必ずURL→ミーティングID→パスワードの順で登録ください。\n例）https://us04web.zoom.us/j/********\nミーティングID: *** **** ****\nパスコード: ******"

                }
            }else{
                self.buttonForMeeting.isHidden = true
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
    func loadData_answer(){
        let ref0 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("coach")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["coachName"] as? String ?? "-"
            let key2 = value?["coachIntro"] as? String ?? "-"
            self.coachNameTextField.text = key1
            self.coachIntroductionTextView.text = key2
        })
        let ref1 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("deliverable")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["answerVideoID"] as? String ?? "-"
            let key2 = value?["meetingInfo"] as? String ?? ""
            let key3 = value?["comment"] as? String ?? "-"

            self.meetingInfo.text = key2
            if key2 != ""{
                self.meetingTextView.text = key2
                self.meetingInfoHowToRegister.text = ""
                self.buttonForMeeting.setTitle("ステータス変更", for: .normal)

            }
            
            self.commentTextView.text = key3

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
            let textImage:String = key1 + ".png"
            let refImage = Storage.storage().reference().child("apply").child("\(self.selectedApplyID!)").child("\(textImage)")
            refImage.downloadURL { url, error in
                if error != nil {
                    // Handle any errors
                } else {
                    self.ImageView2.sd_setImage(with: url, placeholderImage: nil)
                }
            }
            self.playVideo2.addTarget(self, action: #selector(self.playVideo2(_:)), for: .touchUpInside)


        })
        let ref2 = Ref.child("apply").child("\(self.selectedApplyID!)").child("answer").child("score")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as? NSDictionary
            let data1 = snap?["score1"] as? String ?? "-"
            let data2 = snap?["score2"] as? String ?? "-"
            let data3 = snap?["score3"] as? String ?? "-"
            let data4 = snap?["score4"] as? String ?? "-"
            let data5 = snap?["score5"] as? String ?? "-"
            let data6 = snap?["scoreCriteria1"] as? String ?? "頭"
            let data7 = snap?["scoreCriteria2"] as? String ?? "腕振り"
            let data8 = snap?["scoreCriteria3"] as? String ?? "脚の引き上げ"
            let data9 = snap?["scoreCriteria4"] as? String ?? "接地"
            let data10 = snap?["scoreCriteria5"] as? String ?? "軸"
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
        })
        
    }
    
    func loadData_coach(){
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["teamID"] as? String
            let ref1 = Ref.child("team").child("\(key1 ?? "-")").child("admin")
            ref1.observeSingleEvent(of: .value, with: { [self]
                (snapshot) in
                if let snapdata = snapshot.value as? [String:NSDictionary]{
                    for key in snapdata.keys.sorted(){
                        let snap = snapdata[key]
                        let data0 = snap!["coachID"] ?? ""
                        let data1 = snap!["userName"] ?? ""
                        let data2 = snap!["coachIntro"] ?? ""
                        self.coachIDArray.append(data0 as! String)
                        self.coachNameArray.append(data1 as! String)
                        self.coachIntroArray.append(data2 as! String)
                        print("coachIDArray:\(coachIntroArray)")
                        print("coachNameArray:\(coachIntroArray)")
                        print("coachIntroArray:\(coachIntroArray)")
                        self.setting()
                    }
                }
            })
            
        })
    }
    @IBAction func buttonTappedForMTG(_ sender: Any) {
        
        if answerFlag.text == "待機中"{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "このミーティングを完了にしますか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                let ref = Ref.child("apply").child("\(self.selectedApplyID!)")
                let data = ["answerFlag":"2"]
                ref.updateChildValues(data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    self.dismiss(animated: true, completion: nil)
                    return
                }

            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }else if answerFlag.text == "完了"{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "このミーティングを待機中に戻しますか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                let ref = Ref.child("apply").child("\(self.selectedApplyID!)")
                let data = ["answerFlag":"1"]
                ref.updateChildValues(data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    self.dismiss(animated: true, completion: nil)
                    return
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

    }

    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func selectedImage(_ sender: Any) {
        if coachingContents.text == "解説動画"{
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        // フォトライブラリに写真を保存するなど、実施したいことをここに書く
                    } else if status == .denied {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            settingToPhotoAccess()
                            return
                        }

                    }
                }
            } else {
                imagePickerController.sourceType = .photoLibrary
                //imagePickerController.mediaTypes = ["public.image", "public.movie"]
                imagePickerController.delegate = self
                //動画だけ
                imagePickerController.mediaTypes = ["public.movie"]
                //画像だけ
                //imagePickerController.mediaTypes = ["public.image"]
                imagePickerController.videoQuality = .typeHigh
                present(imagePickerController, animated: true, completion: nil)
                print("選択できた！")
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "この申込に対しては解説動画を添付できません。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("yes！")
        self.playVideo2.isHidden = false
        
        videoAseet = info[.phAsset] as? PHAsset
        
        let options=PHVideoRequestOptions()
        options.version = .original
        if videoAseet != nil{
            PHImageManager.default().requestAVAsset(forVideo: videoAseet!,options:options){(asset:AVAsset?,audioMix,info:[AnyHashable:Any]?)->Void in
                if let urlAsset = asset as? AVURLAsset{
                    let localURL = urlAsset.url as URL
                    self.videoURL = localURL
                    print("videoURL")
                    print(localURL)
                }else{
                }
            }
        }
        self.ImageView2.image = self.previewImageFromVideo((info[UIImagePickerController.InfoKey.mediaURL] as? URL)!)!
        self.ImageView2.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
        
    }
    
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        print("動画からサムネイルを生成する")
        let asset = AVAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value,0)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            data = image.pngData()
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
    @IBAction func playMovie(_ sender: Any) {
        print("動画再生ボタンが押されました")
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
    }

    @IBAction func sendVideo(_ sender: Any) {

        if coachNameTextField.text == "" || coachIntroductionTextView.text == "" || scoreCriteria1.text == "" || scoreCriteria2.text == "" || scoreCriteria3.text == "" || scoreCriteria4.text == "" || scoreCriteria5.text == "" || score1.text == "" || score2.text == "" || score3.text == "" || score4.text == "" || score5.text == "" || commentTextView.text == "" || meetingTextView.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。確認してください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else if coachingContents.text == "解説動画" && videoURL == nil{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "動画を添付してください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信しますがよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                processing()
                self.sendData()
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
    //
    
    func sendData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
            self.timeout()
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
        
        let answerVideoID = "\(date_yyyyMMddHHmmSS)"+"_answerVideo_"+"\(self.currentUid)"
        
        //ここから動画DB格納定義

        let ref0 = self.Ref.child("apply").child("\(selectedApplyID ?? "-")").child("answer").child("deliverable")
        let ref1 = self.Ref.child("apply").child("\(selectedApplyID ?? "-")").child("answer").child("coach")
        let ref2 = self.Ref.child("apply").child("\(selectedApplyID ?? "-")").child("answer").child("score")
        let ref3 = self.Ref.child("apply").child("\(selectedApplyID ?? "-")")
        let data0 = ["comment":"\(self.commentTextView.text ?? "")","meetingInfo":"\(self.meetingTextView.text ?? "")" as Any] as [String : Any]
        let data1 = ["coachID":"\(selectedCoachID ?? "-")","coachName":"\(coachNameTextField.text ?? "")","coachIntro":"\(coachIntroductionTextView.text ?? "")"]
        let data2 = ["score1":"\(self.score1.text ?? "")","score2":"\(self.score2.text ?? "")","score3":"\(self.score3.text ?? "")","score4":"\(self.score4.text ?? "")","score5":"\(self.score5.text ?? "")","scoreCriteria1":"\(self.scoreCriteria1.text ?? "")","scoreCriteria2":"\(self.scoreCriteria2.text ?? "")","scoreCriteria3":"\(self.scoreCriteria3.text ?? "")","scoreCriteria4":"\(self.scoreCriteria4.text ?? "")","scoreCriteria5":"\(self.scoreCriteria5.text ?? "")" as Any] as [String : Any]
        ref0.updateChildValues(data0)
        ref1.updateChildValues(data1)
        ref2.updateChildValues(data2)
        if coachingContents.text == "ミーティング"{
            let data3 = ["answerFlag":"1" as Any] as [String : Any]
            ref3.updateChildValues(data3)
        }else{
            let data3 = ["answerFlag":"2" as Any] as [String : Any]
            ref3.updateChildValues(data3)
        }
        


        if self.videoURL != nil{
            let storageReference = Storage.storage().reference().child("apply").child("\(selectedApplyID ?? "-")").child("\(answerVideoID).mp4")
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            /// create a temporary file for us to copy the video to.
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(self.videoURL!.lastPathComponent )
            
            /// Attempt the copy.
            do {
                try FileManager().copyItem(at: self.videoURL!.absoluteURL, to: temporaryFileURL)
            } catch {
                print("There was an error copying the video file to the temporary location.")
            }
            print("\(temporaryFileURL)")
            //            let metadata = StorageMetadata()
            //            metadata.contentType = "image/jpeg"
            let uploadTask0 = storageReference.putFile(from: temporaryFileURL, metadata: nil) { [self] metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    self.initilizedView.removeFromSuperview()

                    let alert: UIAlertController = UIAlertController(title: "確認", message: "動画を送信できませんでした。容量などを確認してください。", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    print("error")
                    return
                    
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                // You can also access to download URL after upload.
                storageReference.downloadURL { [self] (url, error) in
                    self.cloudVideoURL = url?.absoluteString
                    let data0 = ["answerVideoID":"\(answerVideoID)","answerVideoURL":"\(self.cloudVideoURL!)" as Any] as [String : Any]
                    let ref0 = self.Ref.child("apply").child("\(selectedApplyID ?? "-")").child("answer").child("deliverable")
                    ref0.updateChildValues(data0)
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }
            let storageReferenceImage = Storage.storage().reference().child("apply").child("\(selectedApplyID ?? "-")").child("\(answerVideoID).png")
            let uploadTask1 = storageReferenceImage.putData(self.data!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("error")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                // You can also access to download URL after upload.
                storageReference.downloadURL { (url, error) in
                    //                    self.cloudImageURL = url?.absoluteString
                    //                    print("cloudImageURL:\(self.cloudImageURL!)")
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }

            uploadTask0.observe(.progress) { snapshot in
              // Upload reported progress
              let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
                print("uploadTask0:\(percentComplete)")
            }
            uploadTask1.observe(.progress) { snapshot in
              // Upload reported progress
              let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
                print("uploadTask1:\(percentComplete)")
            }
            uploadTask0.observe(.success) { snapshot in
              // Upload completed successfully
                self.uploadTaskStatus0 = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.uploadTaskStatus1 == 1{
                        let alert: UIAlertController = UIAlertController(title: "確認", message: "送信が完了しました。", preferredStyle:  UIAlertController.Style.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in

                            self.dismiss(animated: true, completion: nil)

                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            uploadTask1.observe(.success) { snapshot in
              // Upload completed successfully
                self.uploadTaskStatus1 = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.uploadTaskStatus0 == 1{
                        let alert: UIAlertController = UIAlertController(title: "確認", message: "送信が完了しました。", preferredStyle:  UIAlertController.Style.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in

                            self.dismiss(animated: true, completion: nil)

                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }

        }else{
            self.initilizedView.removeFromSuperview()
            let alert: UIAlertController = UIAlertController(title: "確認", message: "送信が完了しました。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in

                self.dismiss(animated: true, completion: nil)

            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
