//
//  PeepCell.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/21/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

class PeepCell: UITableViewCell
{
    let nameLabel: UILabel!
    let bioLabel: UILabel!
    
    var peep: UserModel! {
        get {
            return self.peep
        }
        set {
            self.nameLabel.text = newValue.username
            self.bioLabel.text = newValue.bio == nil ? "" : newValue.bio
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel(frame: CGRect(x: 10, y: 50, width: 150, height: 50))
        bioLabel = UILabel(frame: CGRect(x: 160, y: 10, width: self.contentView.bounds.width-150, height: 130))
        
        nameLabel.font = UIFont.systemFontOfSize(20)
        bioLabel.font = UIFont.systemFontOfSize(10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
