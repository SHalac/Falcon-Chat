//
//  ChatListTableViewController.swift
//  Trumpet
//
//  Created by Selim Halac on 5/17/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChatListTableViewController: UITableViewController{
    
    var FriendsList = [Friend]()
    var Status: String?
    var Username: String?
    var ChatPerson: Friend?
    var ChatListSocket: SocketIOManager?
    //var UserInfo = User()
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 102/255, blue: 102/255, alpha: 1)
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "SnellRoundHand-Bold", size: 29)!
            //NSFontAttributeName: UIFont(name: "Avenir", size: 21)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.title = "Trumpet"
        //self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        let customFont = UIFont(name: "Helvetica", size: 12.0)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: customFont!], forState: UIControlState.Normal)
        ChatListSocket = SocketIOManager()
        ChatListSocket!.socket.on("update"){data, ack in
            let testvar = data[0] as! NSDictionary
            let Alerted = testvar["userToUpdate"]! as! String
            for listedUser in self.FriendsList{
                if(listedUser.Username == Alerted){
                    listedUser.Update = true
                    USERALERTNOTIFICATION.addObject(Alerted)
                }
            }// for loop
            self.tableView.reloadData()
        }// socket.on
        initiateFriendList()
        ChatListSocket?.establishConnection(self.Username!)
         print("just established a connection ")
    }
    override func viewWillDisappear(animated: Bool) {
        print("about to close socket in view Will dissapear")
        ChatListSocket?.closeConnection()
       // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       // SocketIOManager.sharedInstance.establishConnection()
    }
    func initiateFriendList(){
        FriendsList = []
        let addJson: [String: AnyObject] = [
            "username": self.Username!,
            ]
        let poster = GLOBALLINK + "/getFriendList"
        Alamofire.request(.POST,poster, parameters: addJson, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                for (_, subJson) in json{
                    let tempfriend = Friend(FriendName: subJson["name"].string!, FriendStatus: subJson["status"].string!, FriendUser: subJson["username"].string!,UpdateUser:false)
                    self.FriendsList.append(tempfriend)
                }
                if(USERALERTNOTIFICATION.count>0){
                    for userToChange in USERALERTNOTIFICATION{
                        for listedUser in self.FriendsList{
                            if(listedUser.Username == userToChange as! String){
                                listedUser.Update = true
                            }
                        }// for loop in friends list
                        
                    }/// useralert for loop
                }// if statement
                self.tableView.reloadData()
            case .Failure:
                print("network error.")
            }
        }
    }
    func addToList(Persons: Friend...){
        for Person:Friend in Persons{
            FriendsList.insert(Person, atIndex: 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCellWithIdentifier("OnlineFriend") as UITableViewCell!
        cell.textLabel!.text = FriendsList[indexPath.row].Username
        cell.detailTextLabel!.text = FriendsList[indexPath.row].Status
        if(FriendsList[indexPath.row].Update){
        cell.backgroundColor = UIColor.yellowColor()
        }
        else{
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        ChatPerson = Friend(FriendName: FriendsList[indexPath.row].Name, FriendStatus: "Online", FriendUser:FriendsList[indexPath.row].Username,UpdateUser: false);
        if(FriendsList[indexPath.row].Update == true){
            USERALERTNOTIFICATION.removeObject(FriendsList[indexPath.row].Username)
        }
        FriendsList[indexPath.row].Update = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("YEAH", sender: self) //CHANGE ChatWithFriend or YEAH
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController:ChatViewController = segue.destinationViewController as? ChatViewController
        {
            viewController.title = ChatPerson?.Name
            viewController.TOuser = ChatPerson?.Username
            viewController.CLIENTuser = self.Username!
        }
        if let viewController:AddFriendController = segue.destinationViewController as? AddFriendController
        {
            viewController.CLIENTusername = self.Username
        }
    }
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FriendsList.count
    }

}
