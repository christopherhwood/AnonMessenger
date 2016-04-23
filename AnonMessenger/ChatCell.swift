//
//  ChatCell.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/23/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

protocol ChatCellDelegate
{
    func resendMessage(chat: ChatModel, index:Int)
}

class ChatCell: UITableViewCell
{
    var chat: ChatModel!
    var delegate: ChatCellDelegate!
    private var bgView: UIView!
    private var userNameLabel: UILabel!
//    private var dateLabel: UILabel!
    private var messageView: UITextView!
    private var resendButton: UIButton!
    
    private let TOP_BAR_HEIGHT: CGFloat = 25
    private let MESSAGE_BUBBLE_WIDTH: CGFloat = 3*SCREEN_WIDTH/4
    private let PADDING:CGFloat = 10
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.bgView = UIView()
        bgView.layer.borderColor = UIColor.darkGrayColor().CGColor
        bgView.layer.borderWidth = 1
        self.userNameLabel = UILabel()
//        self.dateLabel = UILabel()
        self.messageView = UITextView()
        self.messageView.editable = false
        self.resendButton = UIButton()
        self.resendButton.backgroundColor = UIColor.redColor()
        self.resendButton.layer.cornerRadius = 20
        self.resendButton.setTitle("!", forState: UIControlState.Normal)
        self.resendButton.addTarget(self, action: #selector(ChatCell.didResend), forControlEvents: UIControlEvents.TouchUpInside)
        self.resendButton.hidden = true
        
        self.contentView.addSubview(bgView)
        self.contentView.addSubview(userNameLabel)
//        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(resendButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.bgView.frame = CGRect(x: PADDING, y: PADDING, width: MESSAGE_BUBBLE_WIDTH, height: self.contentView.bounds.height-2*PADDING)
        self.userNameLabel.frame = CGRect(x: PADDING/2, y: PADDING/2, width: (bgView.bounds.width-PADDING)/2, height: TOP_BAR_HEIGHT)
//        self.dateLabel.frame = CGRect(x: userNameLabel.frame.maxX, y: PADDING/2, width: (bgView.bounds.width-PADDING)/2, height: TOP_BAR_HEIGHT)
        self.messageView.frame = CGRect(x: PADDING/2, y: TOP_BAR_HEIGHT+PADDING/2, width: bgView.bounds.width-PADDING, height: bgView.bounds.height-3*PADDING/2-TOP_BAR_HEIGHT)
        
        userNameLabel.text = chat.sender
        userNameLabel.font = UIFont.systemFontOfSize(10)
        
//        dateLabel.text = chat.time
//        dateLabel.font = UIFont.systemFontOfSize(10)
        
        messageView.text = chat.message
        messageView.font = UIFont.systemFontOfSize(12)
        
        if (chat.sender != "Me")
        {
            bgView.backgroundColor = UIColor.greenColor()
        }
    }
    
    internal func didResend()
    {
        delegate.resendMessage(self.chat, index: self.tag)
    }
}
