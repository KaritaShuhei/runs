//
//  applyFormViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/08/17.
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
import StoreKit

class ApplyFormViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
    var window: UIWindow?
    
    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    
    var viaAppRuleFlag: String?
    
    let imagePickerController = UIImagePickerController()
    var videoAseet: PHAsset?
    var videoURL: URL?
    var cloudVideoURL: String?
    var cloudImageURL: String?
    var currentAsset: AVAsset?
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    var currentTextField = UITextField()
    var currentTextView = UITextView()
    var segueNumber: Int?
    let refreshControl = UIRefreshControl()
    let Ref = Database.database().reference()
    
    var selectedTeamID:String?
    var applyLimitBasic:Int?
    var applyLimitPremium:Int?
    var selectedTeamName:String?
    var selectedApplyStatus:String?
    var applyNumber: Int?
    
    var answerFlagArray = [String]()
    
    var pickerview0: UIPickerView = UIPickerView()
    var pickerview1: UIPickerView = UIPickerView()
    var coachingContentsArray:[String] = ["選択してください","ミーティング","解説動画"]
    var applyCountArray = [String]()
    var meetingDateArray = [String]()
    var meetingIDArray = [String]()
    var selectedMeetingID:String?
    //    var selectedCoachingContents:String?
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingTextLabel2 = UILabel()
    var settingButton: UIButton = UIButton()
    
    var uploadTaskStatus0 = 0
    var uploadTaskStatus1 = 0
    
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var coachingContents: UITextField!
    @IBOutlet weak var meetingDate: UITextField!
    
    override func viewDidLoad() {
        cameraAuthorization()
        setting()
        loadData()
        checkApplyNumber()
        initilize()
        //        pickerviewData()
        //        fetchProducts()
        //        fetchPurchaseStatus()
        //        checkApplyNumber()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func setting(){
        meetingDate.placeholder = ""
        meetingDate.backgroundColor = .lightGray
        meetingDate.isEnabled = false
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
    func processing2(progress:String){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        
        settingTextLabel2.text = "\(progress)%"
        settingTextLabel2.numberOfLines = 0
        settingTextLabel2.frame = CGRect(x: 20, y: viewHeight/2 + 100, width: viewWidth-40, height: 100)
        settingTextLabel2.textColor = .systemGreen
        settingTextLabel2.textAlignment = NSTextAlignment.center
        
        initilizedView.addSubview(settingTextLabel2)
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
        coachingContents.text = ""
        meetingDate.text = ""
        pickerview0.delegate = self
        pickerview0.dataSource = self
        pickerview0.tag = 0
        pickerview0.showsSelectionIndicator = true
        pickerview1.delegate = self
        pickerview1.dataSource = self
        pickerview1.tag = 1
        pickerview1.showsSelectionIndicator = true
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        coachingContents.inputView = pickerview0
        coachingContents.inputAccessoryView = toolbar
        meetingDate.inputView = pickerview1
        meetingDate.inputAccessoryView = toolbar
        
    }
    @objc func done() {
        self.view.endEditing(true)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView{
        
        if pickerView.tag == 0{
            
            let label = (view as? UILabel) ?? UILabel()
            label.text = self.coachingContentsArray[row]
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            return label
            
        } else {
            
            let label = (view as? UILabel) ?? UILabel()
            label.text = self.meetingDateArray[row]
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            return label
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0{
            
            return coachingContentsArray.count
            
        } else {
            
            return meetingDateArray.count
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            
            if coachingContents.text == "選択してください"{
                return ""
            }else{
                return coachingContentsArray[row]
            }
            
        } else {
            
            if meetingDate.text == "選択してください"{
                return ""
            }else{
                return meetingDateArray[row]
            }
            
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        
        if pickerView.tag == 0 {
            coachingContents.text = coachingContentsArray[row]
            if coachingContents.text == "ミーティング"{
                meetingDate.text = ""
                meetingDate.placeholder = "選択してください"
                meetingDate.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.9581108689, green: 0.9730401635, blue: 0.9727780223, alpha: 1)}
                meetingDate.isEnabled = true
            }else{
                meetingDate.text = ""
                meetingDate.placeholder = ""
                meetingDate.backgroundColor = .lightGray
                meetingDate.isEnabled = false
                //                return coachingContents.text = coachingContentsArray[row]
            }
            
        } else {
            selectedMeetingID = meetingIDArray[row]
            meetingDate.text = meetingDateArray[row]
            
        }
        if coachingContents.text == "選択してください"{
            coachingContents.text = ""
        }
        if meetingDate.text == "選択してください"{
            meetingDate.text = ""
        }
        
    }
    
    func checkApplyNumber(){
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
            let key0 = value?["applyLimitBasic"] as? Int ?? 0
            self.applyLimitBasic = Int(key0)
            print("self.applyLimitBasic\(self.applyLimitBasic)")
            //                print("個人申込制限：\(self.applyLimit)")
        })
        //        }
        
        let ref = Ref.child("apply").queryOrdered(byChild: "uid").queryEqual(toValue: "\(currentUid)")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key = snap!["date_yyyyMMdd"] as? String
                    if key?.contains("\(date_yyyymm)") == true{
                        self.applyCountArray.append(key ?? "")
                        print("self.applyCountArray\(self.applyCountArray)")
                    }
                }
            }
        })
    }
    func loadData(){
        
        memo.delegate = self
        self.PlayButton.isHidden = true
        
        
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        let date_n_yyyyMMddHHmm = formatter.string(from: now as Date)
        
        let ref1 = Ref.child("user").child("\(currentUid)").child("profile")
        ref1.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key0 = value?["teamID"] as? String ?? ""
            let key1 = value?["teamName"] as? String ?? ""
            if key1 != ""{
                selectedTeamID = key0
            }else{
                selectedTeamID = "runs"
            }
            selectedTeamName = key1
            let ref = Ref.child("team").child("\(selectedTeamID!)").child("meeting")
            ref.observeSingleEvent(of: .value, with: { [self](snapshot) in
                self.meetingIDArray.append("")
                self.meetingDateArray.append("選択してください")
                if let snapdata = snapshot.value as? [String:NSDictionary]{
                    for key in snapdata.keys.sorted(){
                        let snap = snapdata[key]
                        let key0 = snap!["meetingID"] as? String
                        let key1 = snap!["reserveStatus"] as? String
                        let key2 = snap!["date"] as? String
                        let key3 = snap!["date_int_start"] as? String
                        if key1 == "0" && date_n_yyyyMMddHHmm < key3 ?? "0"{
                            self.meetingIDArray.append(key0 ?? "")
                            self.meetingDateArray.append(key2 ?? "")
                        }
                        if snap == snapdata[snapdata.keys.sorted().last!]{
                            pickerviewData()
                            self.initilizedView.removeFromSuperview()
                        }
                    }
                }else{
                    self.initilizedView.removeFromSuperview()
                    //                    self.meetingIDArray.append("-")
                    //                    self.meetingDateArray.append("-")
                    pickerviewData()
                }
            })
            
        })
    }
    @IBAction func selectedImage(_ sender: Any) {
        
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
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("yes！")
        self.PlayButton.isHidden = false
        
        //        videoAseet = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
        //        videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        
        videoAseet = info[.phAsset] as? PHAsset
        print("videoAseet")
        print("info[.phAsset] as? PHAsset",info[.phAsset] as? PHAsset)
        //        print(videoAseet as Any)
        
        //        videoAseet = info[.phAsset] as? PHAsset
        //        let phVideoOptions = PHVideoRequestOptions()
        //        phVideoOptions.version = .original
        //        PHImageManager().requestAVAsset(forVideo: phAsset!, options: phVideoOptions) { [self] asset, audioMix, info in
        //            DispatchQueue.main.async {
        //                if ((asset?.isKind(of: AVURLAsset.self)) != nil) {
        //                   // Now, you can use asset
        //                    self.videoURL = asset
        //                }
        //            }
        //        }
        //        let options=PHVideoRequestOptions()
        //        options.version = .original
        //        if let URL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
        //            let result = PHAsset.fetchAssets(withALAssetURLs: [URL], options: nil)
        //            let asset = result.firstObject
        ////            print(asset?.value(forKey: "filename"))
        //        }
        
        let options=PHVideoRequestOptions()
        options.version = .original
        print("videoAseet:\(videoAseet)")
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
        //        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
        
        //        let refResult:PHFetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        //        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        //        options.version = .original
        //        PHImageManager.default().requestAVAsset(forVideo: refResult[0], options: options, resultHandler: { (asset, audioMix, info) in
        //            if let urlAsset = asset as? AVURLAsset {
        //                self.videoURL = urlAsset.url
        //                print("動画を高画質で取得")
        //            }
        //        })
        //        }
        self.imageView.image = self.previewImageFromVideo((info[UIImagePickerController.InfoKey.mediaURL] as? URL)!)!
        self.imageView.contentMode = .scaleAspectFit
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
    
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップアップされる
        return .none
    }
    //    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    //        for product in response.products {
    //            let payment: SKPayment = SKPayment(product: product)
    //            SKPaymentQueue.default().add(payment)
    //            print(payment)
    //        }
    //    }
    
    @IBAction func sendVideo(_ sender: Any) {
        if selectedTeamID == "runs"{
            if self.applyLimitBasic ?? 0 <= self.applyCountArray.count{
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
        if self.selectedTeamID != ""{
            applyNumber = answerFlagArray.filter({$0 == "団体利用"}).count
        }else{
            applyNumber = answerFlagArray.filter({$0 == "個人利用"}).count
        }
        if coachingContents.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }else if coachingContents.text == "ミーティング" && meetingDate.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else if self.videoURL == nil{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "動画を選択してください", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信しますがよろしいですか？一度送信した申込は取り消しできません。", preferredStyle:  UIAlertController.Style.alert)
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
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        
        let applyID = "\(date_yyyyMMddHHmmSS)"+"_apply_"+"\(self.currentUid)"
        
        //ここから動画DB格納定義

        if self.videoURL != nil{
            self.segueNumber = 1
            let storageReference = Storage.storage().reference().child("apply").child("\(applyID)").child("\(applyID).mp4")
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
            
            let uploadTask0 = storageReference.putFile(from: temporaryFileURL, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    let alert: UIAlertController = UIAlertController(title: "確認", message: "動画を送信できませんでした。容量を確認してください。", preferredStyle:  UIAlertController.Style.alert)
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
                    let videoData = ["cloudVideoURL":"\(self.cloudVideoURL!)" as Any] as [String : Any]
                    let ref0 = self.Ref.child("apply").child("\(applyID)")
                    ref0.updateChildValues(videoData)
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                }
                
            }
            let storageReferenceImage = Storage.storage().reference().child("apply").child("\(applyID)").child("\(applyID).png")
            let uploadTask1 = storageReferenceImage.putData(self.data!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("error")
                    return
                }
                
                let ref0 = self.Ref.child("apply").child("\(applyID)")
                let applyData = ["uid":"\(self.currentUid)","userName":"\(self.currentUserName)","applyID":"\(applyID)","teamID":"\(self.selectedTeamID ?? "")","teamName":"\(self.selectedTeamName ?? "")","answerFlag":"0","coachingContents":"\(self.coachingContents.text ?? "")","meetingDate":"\(self.meetingDate.text ?? "")","memo":"\(self.memo.text ?? "コメントなし")","created_at":"\(date_yyyyMMddHHmmSS)","date_yyyyMMddHHmm":"\(date_yyyyMMddHHmm)","date_yyyyMMdd":"\(N_date_yyyy)"+"\(N_date_mm)"+"\(N_date_dd)","date_yyyyMM":"\(N_date_yyyy)"+"年"+"\(N_date_mm)"+"月","fcmTrigger":"0" as Any] as [String : Any]
                //        マスターテーブル
                ref0.updateChildValues(applyData)
                
                if self.coachingContents.text == "ミーティング"{
                    
                    let data1 = ["reserveStatus":"1","applyID":"\(applyID)","userName":"\(self.currentUserName)",]
                    
                    let ref1 = self.Ref.child("team").child("\(self.selectedTeamID ?? "-")").child("meeting").child(self.selectedMeetingID ?? "-")
                    ref1.updateChildValues(data1)
                    
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
                        self.performSegue(withIdentifier: "toResultView", sender: nil)
                    }else{
                        return
                    }
                }
            }
            uploadTask1.observe(.success) { snapshot in
                // Upload completed successfully
                self.uploadTaskStatus1 = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.uploadTaskStatus0 == 1{
                        self.performSegue(withIdentifier: "toResultView", sender: nil)
                    }else{
                        return
                    }
                }
            }
            
        }
        
    }
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if (segue.identifier == "resultView") {
    //            if #available(iOS 13.0, *) {
    //            } else {
    //                // Fallback on earlier versions
    //            }
    //        }
    //    }
    
}
