//
//  ChatListTableViewCell.swift
//  oemapp
//
//  Created by Shuhei Karita on 2022/04/04.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var answerFlagImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var personImageview: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
