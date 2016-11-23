//
//  ViewController.swift
//  Trumpet
//
//  Created by Selim Halac on 5/7/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController{
    //var CLIENTusername:String?
 
    @IBAction func SignUp(sender: AnyObject) {
        self.performSegueWithIdentifier("SignUpIn", sender: sender)
    }
    @IBAction func LogInButton(sender: AnyObject) {
        let logParameters: [String: AnyObject] = [
            "username": UserName.text!,
            "password": UserPassword.text!
        ]
        let poster = GLOBALLINK + "/authenticate"
        print(poster)
        Alamofire.request(.POST,poster, parameters: logParameters, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                let good = json["good"]
                if(good){
                    THEGLOBALVAR = self.UserName.text!
                    //SocketIOManager.isLoggedIn = true;
                    //SocketIOManager.sharedInstance.establishConnection(self.UserName.text!)
                    self.performSegueWithIdentifier("LoggingIn", sender: sender)
                }
                else if(!good){
                    let authmessage = "invalid \(json["reason"])"
                    let alertController = UIAlertController(title: "Authentication Error", message: authmessage, preferredStyle:UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
                    self.showViewController(alertController, sender: self)
                        }
            case .Failure:
                let alertController = UIAlertController(title: "Authentication Error", message: "A server error occured, try again later.", preferredStyle:UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
                self.showViewController(alertController, sender: self)
                print("Request failed with error")
            }
        }

    }
    
    override func viewDidLoad() {
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOutside))
        self.view.addGestureRecognizer(tapGesture)
    }
    func tappedOutside(){
        self.UserName.endEditing(true)
        self.UserPassword.endEditing(true)
    }
    
    @IBOutlet weak var UserName: UITextField!
    
    @IBOutlet weak var UserPassword: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoggingIn" {
            let nav = segue.destinationViewController as! UINavigationController
            let listcontroller:ChatListTableViewController = nav.topViewController as! ChatListTableViewController
            listcontroller.Username = UserName.text
            listcontroller.Status = "Online"
        }
        
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

