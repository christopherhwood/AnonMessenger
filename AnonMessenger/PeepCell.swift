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
    var peep: UserModel!
    private var nameLabel: UILabel!
    private var redCircle: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFontOfSize(16)
        redCircle = UIView()
        redCircle.layer.cornerRadius = 15
        redCircle.backgroundColor = UIColor.redColor()
        redCircle.layer.masksToBounds = true
        redCircle.hidden = true
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(redCircle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.nameLabel = UILabel(frame: CGRect(x: 10, y: 50, width: 150, height: 50))
        self.nameLabel.text = self.peep.name
        
        redCircle.frame = CGRect(x: contentView.bounds.width-60, y: 5, width: 40, height: 40)
        if self.peep.unreadMessages > 0
        {
            redCircle.hidden = false
        }
    }
}
