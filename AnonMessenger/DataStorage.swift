//
//  DataStorage.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/24/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

protocol DataStorageUserDelegate
{
    func didChangeUserArray()
}

protocol DataStorageMessageDelegate
{
    func didReceiveMessage(chat: ChatModel)
}

class DataStorage
{
    static let sharedInstance = DataStorage()
    
    private var userArray: Array<UserModel> {
        didSet {
            self.userDelegate?.didChangeUserArray()
        }
    }
    var userDelegate: DataStorageUserDelegate?
    var messageDelegate: DataStorageMessageDelegate?
    
    private init()
    {
        userArray = []
    }
    
    func addUser(username: String)
    {
        let newUser = UserModel(name: username)
        userArray.append(newUser)
    }
    
    func removeUser(username: String)
    {
        userArray = userArray.filter({$0.name != username})
    }
    
    func addChat(chat: ChatModel)
    {
        userArray.filter({$0.name == chat.sender}).first?.messages.append(chat)
    }
    
    func updateChat(newChat: ChatModel, receivingUser: String)
    {
        guard let user = userArray.filter({$0.name == receivingUser}).first where user.messages.count > 0 else
        {
            return
        }
        for (idx, oldChat) in user.messages.enumerate()
        {
            if oldChat.message == newChat.message
            {
                user.messages[idx] = newChat
                self.updateUser(user)
            }
        }
    }
    
    func updateUser(newUser: UserModel)
    {
        for (idx, oldUser) in userArray.enumerate()
        {
            if oldUser.name == newUser.name
            {
                userArray[idx] = newUser
            }
        }
    }
    
    func listUsersSortedByUnreadMessages() -> Array<UserModel>
    {
        return userArray.sort({$0.0.unreadMessages > $0.1.unreadMessages})
    }
}

extension DataStorage: SocketUserDelegate, SocketMessageReceiverDelegate
{
    internal func didAddUser(username: String)
    {
        self.addUser(username)
    }
    
    internal func didRemoveUser(username: String)
    {
        self.removeUser(username)
    }
    
    internal func didReceiveMessage(message: String, senderName: String)
    {
        let chat = ChatModel(sender: senderName, message: message)
        self.addChat(chat)
        self.messageDelegate?.didReceiveMessage(chat)
    }
}
