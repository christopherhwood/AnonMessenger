//
//  ChatViewController.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/22/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController
{
    private var peep: UserModel!
    private var tableView: UITableView!
    private var bgView: UIView!
    private var textBox: TextBox!
    private var chatArray: Array<ChatModel>!
    
    private let TEXT_BOX_SIZE = CGSizeMake(SCREEN_WIDTH, 60)
    
    convenience init(peep: UserModel)
    {
        self.init()
        self.peep = peep
        self.chatArray = peep.messages.map {(chat) -> ChatModel in
            var c = chat
            c.read = true
            return c
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createView()
    }
    
    private func createView()
    {
        self.navigationItem.title = peep.name
        
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(bgView)
        
        self.tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-TEXT_BOX_SIZE.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: "CHAT")
        bgView.addSubview(tableView)
        
        self.textBox = TextBox(frame: CGRect(x: 0, y: tableView.frame.maxY, width: TEXT_BOX_SIZE.width, height: TEXT_BOX_SIZE.height), delegate: self)
        bgView.addSubview(textBox)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataStorage.sharedInstance.updateUser(self.peep)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: ChatCell = tableView.dequeueReusableCellWithIdentifier("CHAT", forIndexPath: indexPath) as! ChatCell
        cell.chat = self.chatArray[indexPath.row]
        cell.delegate = self
        cell.tag =  indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let testString: NSAttributedString = NSAttributedString(string: chatArray[indexPath.row].message, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)])
        let testRect : CGRect = testString.boundingRectWithSize(CGSize(width: 3*SCREEN_WIDTH/4-20, height:CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return max(50.0, ceil(testRect.height))
    }
}

extension ChatViewController: TextBoxDelegate
{
    func textViewDidChange(textView: UITextView)
    {
        let fixedHeight = textView.frame.size.height
        let newSize = textView.sizeThatFits(CGSize(width: CGFloat.max, height: fixedHeight))
        var newTextFrame = textView.frame
        newTextFrame.size = CGSize(width: newSize.width, height: max(fixedHeight, newSize.height))
        textView.frame = newTextFrame
        
        self.textBox.sizeToFit()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "/n"
        {
            textView.resignFirstResponder()
            chatArray.append(ChatModel(sender: "Me", message: textView.text))
            Socket.sharedInstance.sendMessage(textView.text, receiver: self.peep.name) { (success, message) in
                if success == false
                {
                    for (idx, chat) in self.chatArray.enumerate()
                    {
                        if chat.message == message
                        {
                            self.chatArray[idx].success = false
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            textView.text = ""
        }
        return true
    }
}

extension ChatViewController: ChatCellDelegate
{
    func resendMessage(chat: ChatModel, index: Int)
    {
        for (idx, c) in self.chatArray.enumerate()
        {
            if c.message == chat.message
            {
                self.chatArray[idx].success = true
                self.tableView.reloadData()
            }
        }
        
        Socket.sharedInstance.sendMessage(chat.message, receiver: self.peep.name) { (success, message) in
            if success == false
            {
                for (idx, c) in self.chatArray.enumerate()
                {
                    if c.message == message
                    {
                        self.chatArray[idx].success = false
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}