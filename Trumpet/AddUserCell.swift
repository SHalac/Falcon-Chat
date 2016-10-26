//
//  AddUserCell.swift
//  Trumpet
//
//  Created by Selim Halac on 6/15/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit

class AddUserCell: UITableViewCell {


    @IBOutlet weak var AddedLabel: UILabel!
    @IBOutlet weak var PlusButton: UILabel!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var NickName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
