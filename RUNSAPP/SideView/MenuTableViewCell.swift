//
//  menuTableViewCell.swift
//  track_online
//
//  Created by 刈田修平 on 2020/11/21.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet var menu: UILabel!
    @IBOutlet weak var menuIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
