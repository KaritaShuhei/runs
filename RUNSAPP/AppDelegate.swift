//
//  AppDelegate.swift
//  RUNSAPP
//
//  Created by Shuhei Karita on 2022/04/25.
//

import UIKit
import Firebase
import FirebaseAuth
import AVFoundation
import AVKit
import Messages
import FirebaseMessaging
import UserNotifications
import StoreKit
import Siren
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var firstLogin:String?
    
    
    override init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false

    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        IQKeyboardManager.shared.enable = true
        forceUpdate()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("APNs token: \(token)")

//        if Auth.auth().currentUser != nil {
//            print("APNs token: \(token)")
//            let currentUid:AnyObject = Auth.auth().currentUser!.uid as AnyObject
//            let data1 = ["fcmStatus":"1","apnsToken":token as Any]
//            let dbRef = Database.database().reference()
//            dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
//
//            Messaging.messaging().token { token, error in
//              if let error = error {
//                print("Error fetching FCM registration token: \(error)")
//              } else if let token = token {
//                  let data1 = ["fcmToken":token as Any]
//                  let dbRef = Database.database().reference()
//                  dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
//                print("FCM registration token: \(token)")
//              }
//            }
//        }
//        print("Messaging.messaging().apnsToken:")
//        print(Messaging.messaging().apnsToken  as Any)
        Messaging.messaging().apnsToken = deviceToken
        print("Messaging.messaging().apnsToken: \(Messaging.messaging().apnsToken)")

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

}
private extension AppDelegate {
    
    func forceUpdate() {
        let siren = Siren.shared
        // 言語を日本語に設定
        siren.presentationManager = PresentationManager(forceLanguageLocalization: .japanese)
        
        // ruleを設定
        siren.rulesManager = RulesManager(globalRules: .critical)
        
        // sirenの実行関数
        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // 以下のように、完了時の処理を無視して記述することも可能
        // siren.wail()
    }
}
extension UIView {
    
    /// 枠線の色
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 枠線のWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 角丸の大きさ
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// 影の色
    @IBInspectable var shadowColor: UIColor? {
        get {
            return layer.shadowColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.shadowColor = newValue?.cgColor
            layer.masksToBounds = false
        }
    }
    
    /// 影の透明度
    @IBInspectable var shadowAlpha: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// 影のオフセット
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// 影のぼかし量
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
}

