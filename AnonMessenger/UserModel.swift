//
//  UserModel.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/24/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

class UserModel
{
    var name: String!
    var messages: Array<ChatModel>!
    var unreadMessages: Int
    {
        get {
            return self.messages.filter({$0.read == false}).count
        }
    }
    
    convenience init(name: String)
    {
        self.init(name: name, messages: [])
    }
    
    init(name: String, messages: Array<ChatModel>)
    {
        self.name = name
        self.messages = messages
    }
}
