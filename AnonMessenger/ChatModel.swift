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
//    var time: String!
    var message: String!
    var success: Bool!
    
    init(sender: String, time: String, message: String)
    {
        self.sender = sender
//        self.time = time
        self.message = message
        self.success = sender != "Me"
    }
}