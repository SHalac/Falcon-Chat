//
//  ChatViewController.swift
//  Trumpet
//
//  Created by Selim Halac on 5/18/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DockView: UIView!
    
    var CLIENTuser:String?
    var TOuser:String?
    var Messages = [ChatMessage]()
    var ChatViewSocket: SocketIOManager?
    
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ChatInput: UITextField!
    
   //
    
    @IBOutlet weak var DockViewHeight: NSLayoutConstraint!
    @IBAction func SendMessage(sender: AnyObject) {
        // insert code here
        self.ChatInput.endEditing(true)
        let mssgText = ChatInput.text!
        let dateFormatter = NSDateFormatter()
        let currentDate = NSDate()
        dateFormatter.dateFormat = "hh:mm a"
        let convertedDate = dateFormatter.stringFromDate(currentDate)
        ChatViewSocket!.sendMessageToServer(mssgText,from: CLIENTuser!,to: [TOuser!],time:convertedDate)
        self.ChatInput.text = ""
        populateMessages()
    }
    override func viewWillAppear(animated: Bool) {
        ChatViewSocket = SocketIOManager()
        ChatViewSocket!.socket.on("update"){data, ack in
            let testvar = data[0] as! NSDictionary
            let Alerted = testvar["userToUpdate"]! as! String
            if(Alerted == self.TOuser!){
            self.populateMessages()
            }
            else{
                USERALERTNOTIFICATION.addObject(Alerted)
            }
        }// socket.on
            ChatViewSocket?.establishConnection(CLIENTuser!)
    }
    override func viewWillDisappear(animated: Bool) {
        ChatViewSocket!.closeConnection()
    }
    func populateMessages(){
        Messages = []
        let poster = GLOBALLINK + "/populateMessages"
        let addJson: [String: AnyObject] = [
            "parties": [TOuser!,CLIENTuser!],
            ]
        Alamofire.request(.POST,poster, parameters: addJson, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                let messageArray = json["messageList"]
                for (_, subJson) in messageArray {
                    if(subJson["author"].string! == self.CLIENTuser!){
                    let newMessage = ChatMessage(Direction: .Me, Name: "Me", Content: subJson["content"].string!,Time: subJson["time"].string!)
                        self.Messages.append(newMessage)
                    }
                    else{
                        let newMessage = ChatMessage(Direction: .You, Name: subJson["author"].string!, Content: subJson["content"].string!,Time: subJson["time"].string!)
                        self.Messages.append(newMessage)
                    }
                    
                }//for loop
                self.tableView.reloadData()
            case .Failure:
                print("network error.")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        tableView.delegate = self
        tableView.dataSource = self
        ChatInput.delegate = self
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
             NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 21)!
            //NSFontAttributeName: UIFont(name: "Avenir", size: 21)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        //UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
         //UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 21)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.tableTapped))
        self.tableView.addGestureRecognizer(tapGesture)
        populateMessages()
        // Do any additional setup after loading the view.
    }
    func addHandlers() {
        // Our socket handlers go here
    }
    
    
    func tableTapped(){
        self.ChatInput.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Messages.count
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.27, animations: {
            self.DockViewHeight.constant = 294;
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.29, animations: {
            self.DockViewHeight.constant = 40;
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let messageType = Messages[indexPath.row].Direction
        switch messageType {
        case .Me:
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatBubbleMe") as! MeChatCellTableViewCell!
                //cell.Name.text = Messages[indexPath.row].Name
            cell.ChatText.text = Messages[indexPath.row].Content
            cell.MeTime.text = Messages[indexPath.row].Time
            return cell
            
        case .You:
                let cell = tableView.dequeueReusableCellWithIdentifier("ChatBubbleYou") as! YouChatCellTableViewCell!
                cell.YouTime.text = Messages[indexPath.row].Time
                cell.Name.text = Messages[indexPath.row].Name
                cell.ChatText.text = Messages[indexPath.row].Content
                return cell
        }
       
        /*
 let cell = tableView.dequeueReusableCellWithIdentifier("OnlineFriend") as UITableViewCell!
 cell.textLabel!.text = FriendsList[indexPath.row].Name
 cell.detailTextLabel!.text = FriendsList[indexPath.row].Status
 return cell
        */
        //ChatBubbleYou
        //ChatBubbleMe
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
