//
//  applyListTableViewCell.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/04.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit

class ApplyListTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var coachingContents: UILabel!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet weak var answerFlag: UILabel!
//    @IBOutlet weak var answerFlagImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var personImageview: UIImageView!
    @IBOutlet weak var meetingDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
