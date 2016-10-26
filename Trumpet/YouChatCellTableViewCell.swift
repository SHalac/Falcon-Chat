//
//  YouChatCellTableViewCell.swift
//  Trumpet
//
//  Created by Selim Halac on 5/17/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit

enum MessageDirection {
    case Me
    case You
}

struct ChatMessage {
    var Direction:MessageDirection
    var Name:String
    var Content:String
    var Time:String
}


class YouChatCellTableViewCell: UITableViewCell {
    @IBOutlet  var YouTime: UILabel!
    @IBOutlet var Name: UILabel!
   @IBOutlet var ChatText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

class MeChatCellTableViewCell: UITableViewCell {
    @IBOutlet var Name: UILabel!
    @IBOutlet var ChatText: UILabel!
    
    @IBOutlet  var MeTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}


