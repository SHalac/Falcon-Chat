//
//  AddFriendController.swift
//  Trumpet
//
//  Created by Selim Halac on 6/11/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SwiftyJSON
//, UITableViewDelegate, UITableViewDataSource
class AddFriendController: UITableViewController, UISearchBarDelegate{
   
    @IBOutlet weak var ElSearchBar: UISearchBar!
    var emptyarray = []
    var SearchResults = [SearchItem]()
    var FilterResults = [SearchItem]()
    var active:Bool?
    var CLIENTusername: String?
    var CLIENTfriends: [String]?
    var AddViewSocket: SocketIOManager?
    
    override func viewWillAppear(animated: Bool) {
        AddViewSocket = SocketIOManager()
        
        AddViewSocket!.socket.on("update"){data, ack in
            let testvar = data[0] as! NSDictionary
            let Alerted = testvar["userToUpdate"]! as! String
            USERALERTNOTIFICATION.addObject(Alerted)
        }// socket.on
        AddViewSocket?.establishConnection(CLIENTusername!)
    }
    override func viewWillDisappear(animated: Bool) {
        AddViewSocket!.closeConnection()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem()
        barButton.title = "Main"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 102/255, blue: 102/255, alpha: 1)
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "SnellRoundHand-Bold", size: 29)!
            //NSFontAttributeName: UIFont(name: "Avenir", size: 21)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        self.title = "Trumpet"

        ElSearchBar.delegate = self
        active = false
        updateFriendList()
        let poster = GLOBALLINK + "/getAll"
        Alamofire.request(.GET,poster).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                let good = json["good"]
                if(good){
                    for (_, subJson) in json["documents"] {
                        let fetchedUser = subJson["username"].string!
                        let fetchedName = subJson["name"].string!
                        if (fetchedUser != self.CLIENTusername){
                        self.SearchResults += [SearchItem(SearchName: fetchedName,SearchUser: fetchedUser)]
                        }
                    }
                    self.tableView.reloadData()
                }
                else if(!good){
                    print("data not good..?")
                }
            case .Failure:
                print ("there was a failure")
            }}
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.active!){
            return self.FilterResults.count
        }
            
        else{
        return self.SearchResults.count
        }
    }
    func checkIfFriends(Mainuser:String, otheruser: String){
        
    }
    func updateFriendList(){
        CLIENTfriends = []
        let addJson: [String: AnyObject] = [
            "username": self.CLIENTusername!,
        ]
        let poster = GLOBALLINK + "/simpleFriendList"
        Alamofire.request(.POST,poster, parameters: addJson, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                for (_, subJson) in json{
                    self.CLIENTfriends?.append(subJson["username"].string!)
                }
                print("HERES YOUR FRIEND LIST FOR \(self.CLIENTusername!)")
                print(self.CLIENTfriends!)
                    self.tableView.reloadData()
            case .Failure:
                print("network error.")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddFriendCell") as! AddUserCell
        
        if (self.active!){
            //tableView.separatorStyle = .SingleLineEtched
            cell.NickName.text! = "Your friend \(FilterResults[indexPath.row].Name)."
            cell.UserName.text! = FilterResults[indexPath.row].Username
            if(CLIENTfriends!.contains(FilterResults[indexPath.row].Username)==false){
                cell.PlusButton.hidden = false
                cell.AddedLabel.hidden = true
            }
            else{
                cell.PlusButton.hidden = true
                cell.AddedLabel.hidden = false
            }
            
        }
        else{
            //tableView.separatorStyle = .None
            cell.AddedLabel.hidden = true
            cell.PlusButton.hidden = true
            cell.NickName.text! = ""
            cell.UserName.text! = ""
            //cell.textLabel!.text = SearchResults[indexPath.row].Name
           // cell.detailTextLabel!.text = SearchResults[indexPath.row].Username
        }
        return cell
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //active = false
        ElSearchBar.resignFirstResponder()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //active = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(self.active!){
        if(CLIENTfriends!.contains(FilterResults[indexPath.row].Username)==false){
        ElSearchBar.resignFirstResponder()
        let addJson: [String: AnyObject] = [
            "adder": self.CLIENTusername!,
            "toadd": FilterResults[indexPath.row].Username
        ]
        let poster = GLOBALLINK + "/addFriend"
        Alamofire.request(.POST,poster, parameters: addJson, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                let good = json["good"]
                if(good){
                     self.updateFriendList()
                }
            case .Failure:
                print("network error.")
            }
        }
            }
        }
    
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == ""){
            active = false
            tableView.reloadData()
        }
        else{
        active = true
            let temp = searchText.lowercaseString
        FilterResults = SearchResults.filter {
            let corica = $0.Username.rangeOfString(temp, options: .CaseInsensitiveSearch ) != nil
            return corica
        }
        tableView.reloadData()
        }
        //str.hasPrefix("Hello")
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //active = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
