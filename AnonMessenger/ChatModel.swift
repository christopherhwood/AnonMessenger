//
//  ChatModel.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/23/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

struct ChatModel
{
    var sender: String!
    var message: String!
    var read: Bool!
    var success: Bool!
    
    init(sender: String, message: String, read: Bool = false)
    {
        self.sender = sender
        self.message = message
        self.read = read
        self.success = true
    }
}