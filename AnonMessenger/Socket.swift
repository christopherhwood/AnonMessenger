//
//  Socket.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/23/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import Foundation

protocol SocketDelegate
{
    func didReceiveMessage(message:String)
    func didHaveError(message:String)
}

class Socket: NSObject, NSStreamDelegate
{
    static let sharedInstance = Socket()
    var delegate: SocketDelegate!
    private override init() { super.init() }
    
    private let serverAddress: CFString = "127.0.0.1"
    private let serverPort: UInt32 = 80
    
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
    
    func login(username: String) -> Bool
    {
        let loginInfo: String = "iam:"+username
        if let data = loginInfo.dataUsingEncoding(NSASCIIStringEncoding)
        {
            let success = outputStream.write(UnsafePointer(data.bytes), maxLength: data.length)
            
            // fail check 
            if (success == -1)
            {
                return false
            }
        }
        
        return true
    }
    
    func sendMessage(message: String) -> Bool
    {
        let messageInfo: String = "msg:"+message
        if let data = messageInfo.dataUsingEncoding(NSASCIIStringEncoding)
        {
            let success = outputStream.write(UnsafePointer(data.bytes), maxLength: data.length)
            
            // fail check
            if success == -1
            {
                return false
            }
        }
        
        return true
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
            let bufferSize = 1024
            var buffer = Array<UInt8>(count:bufferSize, repeatedValue: 0)
            var bytesRead: Int
            
            while inputStream.hasBytesAvailable
            {
                bytesRead = inputStream.read(&buffer, maxLength: bufferSize)
                if (bytesRead > 0)
                {
                    let output = NSString(bytes: &buffer, length: bytesRead, encoding: NSUTF8StringEncoding)
                    if output != nil
                    {
                        delegate.didReceiveMessage(output as! String)
                    }
                }
                else
                {
                    print("Oops, no message received")
                }
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
                
                if let message = String(data: messageData, encoding: NSASCIIStringEncoding)
                {
                    delegate.didHaveError(message)
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
