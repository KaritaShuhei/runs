//
//  SceneDelegate.swift
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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let windows = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = windows
        windows.makeKeyAndVisible()
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)

        let ref = Database.database().reference().child("admin").child("setting").child("maintenance")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["flag"] as? String ?? ""
            if key == "1"{
                let vc = sb.instantiateViewController(withIdentifier: "maintenanceView")
                self.window!.rootViewController = vc
            }
        })

        if Auth.auth().currentUser == nil {
            let vc = sb.instantiateViewController(withIdentifier: "topView")
            window!.rootViewController = vc
        } else {

            UIApplication.shared.applicationIconBadgeNumber = 0

            let vc = sb.instantiateViewController(withIdentifier: "rootHomeView")
            self.window!.rootViewController = vc
            

        }
        
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
