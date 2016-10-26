//
//  SocketIOManager.swift
//  Trumpet
//
//  Created by Selim Halac on 5/22/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class SocketIOManager: NSObject {


    static let sharedInstance = SocketIOManager()
    static var isLoggedIn: Bool?
    var controllerType: String?
    var socket = SocketIOClient(socketURL: NSURL(string:"ws://trumpetchat.herokuapp.com")!)
   // var socket = SocketIOClient(socketURL: NSURL(string:"http://localhost:3000")!)
    
    
override init() {
    super.init()
}
    
func addHandlers(info:String){
        let infoJson: [String: AnyObject] = [
            "username": info
        ]
    socket.on("connect"){data, ack in
        self.socket.emit("USERLOGINCHECK", infoJson)
      //  print("socket connected \n");
    }
    socket.on("testSocket"){data, ack in
        let testvar = data[0] as! NSDictionary
        print( "The following username was given by test socket: \(testvar["hello"]!)")
    }
       // socket.on("update"){data, ack in
            
        //}
        
}
    func sendMessageToServer(msg:String,from:String,to:[String],time:String){
        let msgJson: [String: AnyObject] = [
            "usernameFROM": from,
            "usernameTo": to,
            "message": msg,
            "time": time
            ]
     socket.emit("MessageToServer", msgJson)
        print("user sent a message")
}
    


    func establishConnection(username:String) {
        addHandlers(username)
    socket.connect()
   // print("connection now....")
}
    
    
func closeConnection() {
    socket.disconnect()
}
    
    
}

