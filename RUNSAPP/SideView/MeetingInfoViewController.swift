//
//  MeetingInfoViewController.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/12.
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

class MeetingInfoViewController: UIViewController, UITableViewDelegate,UITableViewDataSource ,UIPickerViewDataSource,UIPickerViewDelegate{
    
    @IBOutlet var TableView: UITableView!
    @IBOutlet weak var meetingDateTextField: UITextField!
    @IBOutlet weak var meetingDateTextField1: UITextField!
    @IBOutlet weak var meetingDateTextField2: UITextField!
    
    var array = [Any]()
    
    var twoDimArray:[[Any]] = []
    var twoDimArray_re:[[Any]] = []
    var dicArray = [String:NSDictionary]()
    
    var pickerview0: UIPickerView = UIPickerView()
    var pickerview1: UIPickerView = UIPickerView()
    var pickerview2: UIPickerView = UIPickerView()
    var yyyyArray = [String]()
    var MMArray = [String]()
    var ddArray = [String]()
    var hh1Array = [String]()
    var mm1Array = [String]()
    var hh2Array = [String]()
    var mm2Array = [String]()
    
    var yyyyRow_n = String()
    var MMRow_n = String()
    var ddRow_n = String()
    var hhRow_n = String()
    var mmRow_n = String()
    
    var yyyyRow = String()
    var MMRow = String()
    var ddRow = String()
    var hh1Row = String()
    var mm1Row = String()
    var hh2Row = String()
    var mm2Row = String()
    
    var df = DateFormatter()
    var meetingDateID = String()
    var teamID = String()
    var youbi = String()
    
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var messageView: UIView = UIView()
    var settingTextLabel = UILabel()
    var settingButton: UIButton = UIButton()
    var noApplyMessage = UILabel()
    
    override func viewDidLoad() {
        initilize()
        pickerViewData()
        loadData()
        TableView.dataSource = self
        TableView.delegate = self
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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

    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    func getCurrentDate(){
        let now = NSDate()
        let formatter_yyyy = DateFormatter()
        let formatter_MM = DateFormatter()
        let formatter_dd = DateFormatter()
        let formatter_HH = DateFormatter()
        let formatter_mm = DateFormatter()
        formatter_yyyy.dateFormat = "yyyy"
        formatter_MM.dateFormat = "MM"
        formatter_dd.dateFormat = "dd"
        formatter_HH.dateFormat = "HH"
        formatter_mm.dateFormat = "mm"
        
        yyyyRow_n = formatter_yyyy.string(from: now as Date)
        MMRow_n = formatter_MM.string(from: now as Date)
        ddRow_n = formatter_dd.string(from: now as Date)
        hhRow_n = formatter_HH.string(from: now as Date)
        mmRow_n = formatter_mm.string(from: now as Date)
    }
    func pickerViewData(){

        getCurrentDate()
        
        yyyyRow = yyyyRow_n
        MMRow = MMRow_n
        ddRow = ddRow_n
        hh1Row = hhRow_n
        mm1Row = mmRow_n
        hh2Row = hhRow_n
        mm2Row = mmRow_n
        
        
        meetingDateDataSet()
        meetingDateDataSet1()
        meetingDateDataSet2()
        
        pickerview0.delegate = self
        pickerview0.dataSource = self
        pickerview0.tag = 0
        pickerview1.delegate = self
        pickerview1.dataSource = self
        pickerview1.tag = 1
        pickerview2.delegate = self
        pickerview2.dataSource = self
        pickerview2.tag = 2
        
        var i_yyyyArray:Int = 0
        var i_MMArray:Int = 0
        var i_ddArray:Int = 0
        var i_hh1Array:Int = 0
        var i_mm1Array:Int = 0
        
        var i_yyyyArray_n:Int = 0
        var i_MMArray_n:Int = 0
        var i_ddArray_n:Int = 0
        var i_hh1Array_n:Int = 0
        var i_mm1Array_n:Int = 0

        for i in Int(yyyyRow)!..<2025{
            yyyyArray.append(String(i))
            if String(i) == yyyyRow{
                print("i_yyyyArray:"+String(i_yyyyArray))
                i_yyyyArray_n = i_yyyyArray
            }
            i_yyyyArray+=1
        }
        for i in 1..<13{
            if i < 10{
                MMArray.append("0"+String(i))
                if "0"+String(i) == MMRow{
                    print("i_MMArray:"+String(i_MMArray))
                    i_MMArray_n = i_MMArray
                }
            }else{
                MMArray.append(String(i))
                if String(i) == MMRow{
                    print("i_MMArray:"+String(i_MMArray))
                    i_MMArray_n = i_MMArray
                }
            }
            i_MMArray+=1
        }
        for i in 1..<32{
            if i < 10{
                ddArray.append("0"+String(i))
                if "0"+String(i) == ddRow{
                    print("i_ddArray:"+String(i_ddArray))
                    i_ddArray_n = i_ddArray
                }
            }else{
                ddArray.append(String(i))
                if String(i) == ddRow{
                    print("i_ddArray:"+String(i_ddArray))
                    i_ddArray_n = i_ddArray
                }
            }
            i_ddArray+=1

        }
        for i in 0..<24{
            if i < 10{
                hh1Array.append("0"+String(i))
                hh2Array.append("0"+String(i))
                if "0"+String(i) == hh1Row{
                    print("i_hh1Array:"+String(i_hh1Array))
                    i_hh1Array_n = i_hh1Array
                }
            }else{
                hh1Array.append(String(i))
                hh2Array.append(String(i))
                if String(i) == hh1Row{
                    print("i_hh1Array:"+String(i_hh1Array))
                    i_hh1Array_n = i_hh1Array
                }
            }
            i_hh1Array+=1
        }
        for i in 0..<60{
            if i%15 == 0{
                if i < 10{
                    mm1Array.append("0"+String(i))
                    mm2Array.append("0"+String(i))
                }else{
                    mm1Array.append(String(i))
                    mm2Array.append(String(i))
                }
            }
            if i/15 == Int(mm1Row)!/15{
                print("i_mm1Array:"+String(i_mm1Array/15))
                i_mm1Array_n = i_mm1Array/15
            }
            i_mm1Array+=1
        }

        print(i_yyyyArray_n)
        print(i_MMArray_n)
        print(i_ddArray_n)
        print(i_hh1Array_n)
        print(i_mm1Array_n)

        pickerview0.selectRow(i_yyyyArray_n, inComponent: 0, animated: false)
        pickerview0.selectRow(i_MMArray_n, inComponent: 1, animated: false)
        pickerview0.selectRow(i_ddArray_n, inComponent: 2, animated: false)
        pickerview1.selectRow(i_hh1Array_n, inComponent: 0, animated: false)
        pickerview1.selectRow(i_mm1Array_n, inComponent: 1, animated: false)
        pickerview2.selectRow(i_hh1Array_n, inComponent: 0, animated: false)
        pickerview2.selectRow(i_mm1Array_n, inComponent: 1, animated: false)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        meetingDateTextField.inputView = pickerview0
        meetingDateTextField1.inputView = pickerview1
        meetingDateTextField2.inputView = pickerview2
        meetingDateTextField.inputAccessoryView = toolbar
        meetingDateTextField1.inputAccessoryView = toolbar
        meetingDateTextField2.inputAccessoryView = toolbar
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0{
            
            return 3
            
        }else if pickerView.tag == 1{
            
            return 2
            
        }else{
            
            return 2
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            switch component {
            case 0:
                return yyyyArray.count
            case 1:
                return MMArray.count
            case 2:
                return ddArray.count
            default:
                return 0
            }
            
        }else if pickerView.tag == 1{
            switch component {
            case 0:
                return hh1Array.count
            case 1:
                return mm1Array.count
            default:
                return 0
            }
            
        }else{
            switch component {
            case 0:
                return hh2Array.count
            case 1:
                return mm2Array.count
            default:
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0{
            switch component {
            case 0:
                return yyyyArray[row]
            case 1:
                return MMArray[row]
            case 2:
                return ddArray[row]
            default:
                return "error"
            }
        }else if pickerView.tag == 1{
            switch component {
            case 0:
                return hh1Array[row]
            case 1:
                return mm1Array[row]
            default:
                return "error"
            }
        }else{
            switch component {
            case 0:
                return hh2Array[row]
            case 1:
                return mm2Array[row]
            default:
                return "error"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0{
            switch component {
            case 0:
                yyyyRow = yyyyArray[row]
                meetingDateDataSet()
            case 1:
                MMRow = MMArray[row]
                meetingDateDataSet()
            case 2:
                ddRow = ddArray[row]
                meetingDateDataSet()
            default:
                break
            }
        }else if pickerView.tag == 1{
            switch component {
            case 0:
                hh1Row = hh1Array[row]
                meetingDateDataSet1()
            case 1:
                mm1Row = mm1Array[row]
                meetingDateDataSet1()
            default:
                break
            }
        }else  if pickerView.tag == 2{
            switch component {
            case 0:
                hh2Row = hh2Array[row]
                meetingDateDataSet2()
            case 1:
                mm2Row = mm2Array[row]
                meetingDateDataSet2()
            default:
                break
            }
        }
        
    }
    func meetingDateDataSet(){
        df.dateFormat = "yyyyMMdd"
        df.locale = Locale(identifier: "ja_JP")
        
        guard let d = df.date(from: "\(yyyyRow)\(MMRow)\(ddRow)") else { return print("d:\(yyyyRow)\(MMRow)\(ddRow)") }
        guard let dc = df.calendar?.component(.weekday, from: d) else { return print("error") }
        
        youbi = df.shortWeekdaySymbols[dc - 1]
        print(youbi)
        meetingDateTextField.text = "\(yyyyRow)/\(MMRow)/\(ddRow)（\(youbi)）"
        
        
    }
    func meetingDateDataSet1(){
        meetingDateTextField1.text = "\(hh1Row)時\(mm1Row)分"
    }
    func meetingDateDataSet2(){
        meetingDateTextField2.text = "\(hh2Row)時\(mm2Row)分"
    }
    func loadData(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        noApplyMessage.text = "登録したミーティング日時が\nありません"
        noApplyMessage.numberOfLines = 0
        noApplyMessage.frame = CGRect(x: viewWidth/4, y: 30, width: viewWidth/2, height: 100)
        noApplyMessage.textColor = .gray
        noApplyMessage.textAlignment = NSTextAlignment.center
        //Viewに追加
        TableView.addSubview(noApplyMessage)
        
        dicArray.removeAll()
        twoDimArray.removeAll()
        twoDimArray_re.removeAll()
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["teamID"] as? String
            teamID = key1 ?? "-"
            let ref1 = Ref.child("team").child("\(key1 ?? "-")").child("meeting")
            ref1.observeSingleEvent(of: .value, with: { [self]
                (snapshot) in
                if let snapdata = snapshot.value as? [String:NSDictionary]{
                    for key in snapdata.keys.sorted(){
                        array.removeAll()
                        let snap = snapdata[key]
                        let data0 = snap!["meetingID"] ?? "-"
                        let data1 = snap!["date"] ?? "-"
                        let data2 = snap!["date_int_start"] ?? "-"
                        if yyyyRow_n + MMRow_n + ddRow_n + hhRow_n + mmRow_n <= data2 as! String{
                            array = [data0 as Any,data1 as Any]
                            twoDimArray.append(array)
                            dicArray.updateValue(snapdata[key]! as NSDictionary, forKey: data0 as! String)
                            twoDimArray_re = twoDimArray.sorted{$1[0] as! String > $0[0] as! String}
                        }
                        if snap == snapdata[snapdata.keys.sorted().last!]{

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.initilizedView.removeFromSuperview()
                            }
                            TableView.reloadData()
                        }
                        
                    }
                }else{
                    self.initilizedView.removeFromSuperview()
                }
            })
            
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
        
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "meetingInfoCell", for: indexPath as IndexPath) as? MeetingInfoTableViewCell
        
        cell!.meetingDate.text = dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["date"] as? String
        if dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["reserveStatus"] as? String == "0"{
            cell!.reserveStatus.text = "○"
            cell!.userName.text = ""
        }else{
            cell!.reserveStatus.text = "×"
            cell!.userName.text = "\(dicArray[(twoDimArray_re[indexPath.row][0] as? String)!]?["userName"] as? String ?? "-")" + "さんから申込がありました"
        }
        cell!.trashButton.tag = indexPath.row
        cell!.trashButton.setTitle("", for: UIControl.State.normal)
        cell!.trashButton.addTarget(self, action: #selector(self.tapButton(_:)), for: UIControl.Event.touchUpInside)
        
        return cell!
    }
    @IBAction func sendData(_ sender: Any) {
        self.view.endEditing(true)
        getCurrentDate()

        let s1 = "\(yyyyRow)\(MMRow)\(ddRow)\(hh1Row)\(mm1Row)"
        let s2 = "\(yyyyRow_n)\(MMRow_n)\(ddRow_n)\(hhRow_n)\(mmRow_n)"
        let s3 = "\(hh1Row)\(mm1Row)"
        let s4 = "\(hh2Row)\(mm2Row)"
        let i1 = Int(s1) ?? 0
        let i2 = Int(s2) ?? 0
        let i3 = Int(s3) ?? 0
        let i4 = Int(s4) ?? 0
        if i1 < i2 || i3 >= i4{
            alert()
        }else{
            meetingDateID = "meetingDate_" + "\(yyyyRow)\(MMRow)\(ddRow)_\(hh1Row)\(mm1Row)_\(hh2Row)\(mm2Row)"
            let date_int_start = "\(yyyyRow)\(MMRow)\(ddRow)\(hh1Row)\(mm1Row)"
            let date_int_end = "\(yyyyRow)\(MMRow)\(ddRow)\(hh2Row)\(mm2Row)"
            let data = ["reserveStatus":"0","meetingID":"\(meetingDateID)","date_int_start":"\(date_int_start)","date_int_end":"\(date_int_end)","date":"\(meetingDateTextField.text ?? "-")\(meetingDateTextField1.text ?? "-")~\(meetingDateTextField2.text ?? "-")"]
            let ref1 = Ref.child("team").child("\(teamID)").child("meeting").child(meetingDateID)
            ref1.updateChildValues(data)
            loadData()
            let alert: UIAlertController = UIAlertController(title: "確認", message: "登録が完了しました。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }
    }
    func alert(){
        let alert: UIAlertController = UIAlertController(title: "確認", message: "過去の日付、時刻は登録できません。また日付、開始時刻、終了時刻をご確認ください。", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func tapButton(_ sender: UIButton){
        let selectedReserveStatus = dicArray[(twoDimArray_re[sender.tag][0] as? String)!]?["reserveStatus"] as? String
        if selectedReserveStatus == "1"{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "既にミーティングの予約が入っている日程は取り消せません。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                
            })

            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "このミーティング日時を削除してよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                let selectedMeetingDateID = dicArray[(twoDimArray_re[sender.tag][0] as? String)!]?["meetingID"] ?? "-"
                let ref1 = Ref.child("team").child("\(teamID)").child("meeting").child(selectedMeetingDateID as! String)
                ref1.removeValue { error, _ in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        
                        self.loadData()
                        print("Data saved successfully!")
                    }
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
    
}
