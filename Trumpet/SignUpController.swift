//
//  SignUpController.swift
//  Trumpet
//
//  Created by Selim Halac on 6/1/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpController: UIViewController, UITextFieldDelegate {


    @IBOutlet var SignUpView: UIView!
    @IBOutlet weak var Password2: UITextField!
    @IBOutlet weak var Password1: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var PasswordMatch: UILabel!
    @IBOutlet weak var UserAvailable: UILabel!
    @IBOutlet weak var PasswordTyped: UILabel!
    @IBOutlet weak var CancelButton: UIButton!
    var myTimer: NSTimer?
    var valid = false
    var passgood = false
    var pass2good = false
    var usergood = false
    var emailgood = false
    var namegood = false
    
    @IBAction func CancelSignUp(sender: AnyObject) {
         self.performSegueWithIdentifier("SignUpOut", sender: sender)
    }
    @IBAction func SignUpUser(sender: AnyObject) {
        if(checkSignUpForm()){
            let SignName = Name.text!
            let SignUser = Username.text!
            let SignEmail = Email.text!
            let SignPassword = Password2.text!
            
            let signUpJson: [String: AnyObject] = [
                "name": SignName,
                "username": SignUser,
                "email": SignEmail,
                "password": SignPassword
            ]
            let poster = GLOBALLINK + "/createuser"
            Alamofire.request(.POST,poster, parameters: signUpJson, encoding: .JSON).responseJSON { response in
                switch response.result {
                case .Success(let data):
                    print("request is fine.")
                    let json = JSON(data)
                    let success = json["success"]
                    if(success){
                        let alert: UIAlertController = UIAlertController(title: "Success", message: "Your account has been successfully created", preferredStyle: .Alert)
                        
                        let okButton = UIAlertAction(title: "Woo!", style: .Default) { action -> Void in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.performSegueWithIdentifier("SignUpOut", sender: self)
                            })
                        }
                        alert.addAction(okButton)
                        self.showViewController(alert, sender: self)
                    
                    }
                    else{
                        let alertController = UIAlertController(title: "Sign Up Error", message: "Something seems to be wrong with the server... Try again later", preferredStyle:UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
                        self.showViewController(alertController, sender: self)
                    }
                case .Failure:
                    let alertController = UIAlertController(title: "Sign Up Error", message: "Something seems to be wrong with the server... Try again alter", preferredStyle:UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
                    self.showViewController(alertController, sender: self)
                }
            }
        }
        
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == Password1 || textField==Password2){
           // SignUpView.anim
        }
        
    }
    func checkSignUpForm() -> Bool{
        if(checkName(Name.text!)){
            namegood = true
        }
        else{
            let alertController = UIAlertController(title: "Invalid Name", message: "Enter a valid first name", preferredStyle:UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
            self.showViewController(alertController, sender: self)
            return false

        }
        if(checkemail(Email.text!)){
            emailgood = true
        }
        else{
            let alertController = UIAlertController(title: "Invalid Email", message: "Enter a valid email", preferredStyle:UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
            self.showViewController(alertController, sender: self)
            return false
        }
        if(usergood && emailgood && namegood && passgood && pass2good){
           return true
        }
        let alertController = UIAlertController(title: "Items missing", message: "Some form items have been left incomplete", preferredStyle:UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil));
        self.showViewController(alertController, sender: self)
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Password1.delegate = self
        Password2.delegate = self
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpController.tappedOutside))
        self.view.addGestureRecognizer(tapGesture)
        PasswordMatch.hidden = true
        UserAvailable.hidden = true
        PasswordTyped.hidden = true
        CancelButton.layer.cornerRadius = 0.5 * CancelButton.bounds.size.width
        Username.addTarget(self, action: #selector(SignUpController.UsernameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        Password1.addTarget(self, action: #selector(SignUpController.checkPassword1(_:)), forControlEvents: UIControlEvents.EditingChanged)
        Password2.addTarget(self, action: #selector(SignUpController.checkPassword2(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    func tappedOutside(){
        self.Name.endEditing(true)
        self.Email.endEditing(true)
        self.Username.endEditing(true)
        self.Password1.endEditing(true)
        self.Password2.endEditing(true)
    }
    func checkPassword1(passwordfield: UITextField){
        //let pass1Format = "[A-Z0-9a-z._%+-]+"
       // let pass1Predicate = NSPredicate(format:"SELF MATCHES %@", pass1Format)
        if(Password1.text!.characters.count<7){
            PasswordTyped.text = "Password too short"
            PasswordTyped.textColor = UIColor.redColor()
            PasswordTyped.hidden = false
        }
        else if(Password1.text!.rangeOfString(" ") != nil){
            PasswordTyped.text = "Can't contain a space"
            PasswordTyped.textColor = UIColor.redColor()
            PasswordTyped.hidden = false
        }
        else{
            PasswordTyped.hidden = true
            passgood = true
        }
    }
    func checkPassword2(passwordfield: UITextField){
        if(Password1.text == Password2.text){
            PasswordMatch.text = "Passwords match"
            PasswordMatch.textColor = UIColor.greenColor()
            PasswordMatch.hidden = false
            pass2good = true
        }
        else{
            PasswordTyped.hidden = true
            PasswordMatch.text = "Passwords don't match"
            PasswordMatch.textColor = UIColor.redColor()
            PasswordMatch.hidden = false
        }
    }
    func checkName(nametoCheck: String) -> Bool{
        let nameFormat = "[A-Za-z]+"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
        return namePredicate.evaluateWithObject(nametoCheck)

    }
    
    func checkemail(emailtoCheck: String) -> Bool{
            let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
            return emailPredicate.evaluateWithObject(emailtoCheck)
    }

    func checkUsername(){
        let tempString = Username.text!
        let usernameJson: [String: AnyObject] = [
            "username": tempString
        ]
        UserAvailable.textColor = UIColor.greenColor()
        UserAvailable.text = "Username is available"
        UserAvailable.hidden = false
        let userFormat = ".*[^A-Za-z0-9_\\.].*"
        let userPredicate = NSPredicate(format:"SELF MATCHES %@", userFormat)
        if(userPredicate.evaluateWithObject(tempString)){
            UserAvailable.textColor = UIColor.redColor()
            UserAvailable.text = "Invalid username"
            UserAvailable.hidden = false
        }
        if(tempString.characters.count < 5){
            UserAvailable.textColor = UIColor.redColor()
            UserAvailable.text = "Username too short"
            UserAvailable.hidden = false
        }
        else if(tempString.rangeOfString(" ") != nil){
            UserAvailable.textColor = UIColor.redColor()
            UserAvailable.text = "Username can't Have Spaces"
            UserAvailable.hidden = false
        }
        else{
        let poster = GLOBALLINK + "/checkUserName"
        Alamofire.request(.POST,poster, parameters: usernameJson, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                let good = json["good"]
                if(!good){
                    self.UserAvailable.textColor = UIColor.redColor()
                    self.UserAvailable.text = "Username not available"
                    self.UserAvailable.hidden = false
                }
                else{
                    self.usergood = true
                }
            case .Failure:
                self.UserAvailable.textColor = UIColor.redColor()
                self.UserAvailable.text = "Network Error"
                self.UserAvailable.hidden = false
            }
        }
        }
        
       
    }

    func UsernameDidChange(userfield:UITextField){
        if let timer = myTimer{
            timer.invalidate()
        }
        myTimer = NSTimer.scheduledTimerWithTimeInterval(2, target:self, selector: #selector(SignUpController.checkUsername), userInfo: nil, repeats: false)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
