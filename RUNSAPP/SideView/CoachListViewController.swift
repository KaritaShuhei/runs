//
//  coachListViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2022/03/16.
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
class CoachListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet var TableView: UITableView!

    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
                
       
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "coachListCell", for: indexPath as IndexPath) as? CoachListTableViewCell
        return cell!
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
