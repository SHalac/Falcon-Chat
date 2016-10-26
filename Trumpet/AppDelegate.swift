//
//  AppDelegate.swift
//  Trumpet
//
//  Created by Selim Halac on 5/7/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
var THEGLOBALVAR = ""
var localhost = "http://localhost:3000"
var trumpetHeroku = "http://trumpetchat.herokuapp.com"
var GLOBALLINK = trumpetHeroku
var USERALERTNOTIFICATION = NSMutableOrderedSet()



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isLogged: Bool?
    var GLOBALclientuser:String?
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //SocketIOManager.isLoggedIn = false;
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        /*if(SocketIOManager.isLoggedIn!){
            SocketIOManager.sharedInstance.closeConnection()
        }*/
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of
      
         
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       /* if(SocketIOManager.isLoggedIn!){
            SocketIOManager.sharedInstance.establishConnection(THEGLOBALVAR)
        }*/
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

