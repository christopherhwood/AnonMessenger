//
//  Socket.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/23/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import Foundation

protocol SocketMessageReceiverDelegate
{
    func didReceiveMessage(message:String, senderName: String)
}

protocol SocketMessageSenderDelegate
{
    func didHaveError(message:String, receiverName: String)
}

protocol SocketUserDelegate
{
    func didAddUser(username:String)
    func didRemoveUser(username:String)
}

class Socket: NSObject, NSStreamDelegate
{
    static let sharedInstance = Socket()
    
    var messageReceiverDelegate: SocketMessageReceiverDelegate!
    var messageSenderDelegate: SocketMessageSenderDelegate!
    var userDelegate: SocketUserDelegate!
    
    private override init() { super.init() }
    
    let serverAddress: CFString = "127.0.0.1"
    let serverPort: UInt32 = 80
    
    private var inputStream: NSInputStream!
    private var outputStream: NSOutputStream!
    
    func connect(address: CFString, port: UInt32)
    {
        print("connecting...")
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorNull, address, port, &readStream, &writeStream)
        
        guard let rStream = readStream, wStream = writeStream else
        {
            print("Read stream or write stream is nil")
            return
        }
        self.inputStream = rStream.takeRetainedValue()
        self.outputStream = wStream.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }
    
    func login(username: String, completionHandler: Bool -> Void)
    {
        let loginData = ["type":"login", "username":username]
        do
        {
            let data = try NSJSONSerialization.dataWithJSONObject(loginData, options: NSJSONWritingOptions.PrettyPrinted)
            let success = outputStream.write(UnsafePointer(data.bytes), maxLength: data.length)
            // fail check 
            completionHandler(success != -1)
        }
        catch
        {
            print("Couldn't convert login data to JSON")
            completionHandler(false)
        }
    }
    
    func sendMessage(message: String, receiver: String, completionHandler: (Bool, String) -> Void)
    {
        let messageData = ["type":"message", "message":message, "receiver":receiver]
        do
        {
            let data = try NSJSONSerialization.dataWithJSONObject(messageData, options: NSJSONWritingOptions.PrettyPrinted)
            let success = outputStream.write(UnsafePointer(data.bytes), maxLength: data.length)
            completionHandler(success != -1, message)
        }
        catch
        {
            print ("Couldn't convert message data to JSON")
            completionHandler(false, message)
        }
        
    }
    
    internal func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode
        {
            case NSStreamEvent.OpenCompleted:
                print("Stream opened")
            
            case NSStreamEvent.HasBytesAvailable:
                self.handleIncomingStream(aStream)
            
            case NSStreamEvent.ErrorOccurred:
                self.handleStreamError(aStream)
            
            case NSStreamEvent.EndEncountered:
                break
            
            default:
                break
        }
    }
    
    internal func handleIncomingStream(stream: NSStream)
    {
        if stream == inputStream
        {
            do
            {
                let inputDict = try NSJSONSerialization.JSONObjectWithStream(inputStream, options: NSJSONReadingOptions.MutableContainers)
                if inputDict["type"] == "client_add"
                {
                    self.userDelegate.didAddUser(inputDict["username"])
                }
                else if inputDict["type"] = "client_remove"
                {
                    self.userDelegate.didRemoveUser(inputDict["username"])
                }
                else
                {
                    self.messageReceiverDelegate.didReceiveMessage(inputDict["message"], inputDict["username"])
                }
            }
            catch
            {
                print("Couldn't parse incoming dictionary")
            }
        }
    }
    
    internal func handleStreamError(stream: NSStream)
    {
        if stream == outputStream
        {
   
            if let error = outputStream.streamError, messageData = outputStream.valueForKey(NSStreamDataWrittenToMemoryStreamKey) as? NSData
            {
                print("Couldn't send message: %@", error)
                
                do
                {
                    let json = try NSJSONSerialization.JSONObjectWithData(messageData, options: NSJSONReadingOptions.MutableContainers)
                    self.messageSenderDelegate.didHaveError(json["message"], receiverName: json["receiver"])
                }
                catch
                {
                    print("Couldn't parse json from sending error")
                }
            }
        }
        else if stream == inputStream
        {
            if let error = inputStream.streamError
            {
                print("Couldn't receive message: %@", error)
            }
        }
    }
}
