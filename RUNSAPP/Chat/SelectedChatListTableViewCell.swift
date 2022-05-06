//
//  SelectedChatListTableViewCell.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/04.
//

import UIKit

class SelectedChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
