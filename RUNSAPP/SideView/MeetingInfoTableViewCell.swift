//
//  meetingInfoTableViewCell.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/12.
//

import UIKit

class MeetingInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var meetingDate: UILabel!
    @IBOutlet weak var reserveStatus: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var trashButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
