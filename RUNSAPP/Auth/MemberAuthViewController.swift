//
//  MemberAuthViewController.swift
//  clubsupApp
//
//  Created by 原井川　千夏 on 2022/01/03.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseEmailAuthUI

class MemberAuthViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    let Ref = Database.database().reference()

    let providers: [FUIAuthProvider] = [
        FUIEmailAuth()
    ]
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    
    override func viewDidLoad() {
        //        loadData()
        self.authUI.delegate = self
        self.authUI.providers = providers
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func authButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if emailTextField.text == "" || passTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "空欄の項目があります。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            initilize()
            Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passTextField.text ?? "") { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }

                if authResult?.user != nil {
                    self?.performSegue(withIdentifier: "toRootHomeView0", sender: nil)

//                    let currentUid:String = Auth.auth().currentUser!.uid
//                    let ref1 = Database.database().reference().child("user").child("\(currentUid)").child("profile")
//                    ref1.observeSingleEvent(of: .value, with: { (snapshot) in
//                        let value = snapshot.value as? NSDictionary
//                        let key = value?["purchaseStatus"] as? String ?? ""
//                        if key == "課金中"{
//                            self?.initilizedView.removeFromSuperview()
//                            self?.performSegue(withIdentifier: "toRootHomeView0", sender: nil)
//                        }else{
//                            self?.initilizedView.removeFromSuperview()
//                            self?.performSegue(withIdentifier: "toCoachingPlan1View", sender: nil)
//                        }
//                    })
//                    ログイン成功
                } else {
                    let alert: UIAlertController = UIAlertController(title: "確認", message: "認証情報に誤りがあります。再度入力してください。", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        
                    })
                    alert.addAction(defaultAction)
                    self?.present(alert, animated: true, completion: nil)

                    self?.initilizedView.removeFromSuperview()
//                    ログイン失敗
                }
                // ...
            }
        }
    }
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
