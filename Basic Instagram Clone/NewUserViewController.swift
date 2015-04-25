//
//  NewUserViewController.swift
//  Basic Instagram Clone
//
//  Created by Juan Pablo Balda Andrade on 4/22/15.
//  Copyright (c) 2015 JPBA. All rights reserved.
//

import UIKit
import Parse

class NewUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func signUpTouched(sender: AnyObject) {
        let username = usernameText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let password = passwordText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let email = emailText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if username != "" && password != "" && email != "" {
            //Create the activity indicator (spinner)
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            //Ignore all user interactions
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var user = PFUser()
            user.username = username
            user.password = password
            user.email = email
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                //Hide activity indicator (spinner)
                self.activityIndicator.stopAnimating()
                //Start accepting user interactions
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    // Hooray! Let them use the app now.
                    self.displayAlert("Sign Up Successful", message: "Please check your email inbox to verify you email address, then try to log in")
                    self.tabBarController?.selectedIndex = 0
                } else {
                    //let errorString = error.userInfo["error"] as NSString
                    // Show the errorString somewhere and let the user try again.
                    self.displayAlert("Couldn't log in", message: error!.userInfo?["error"] as! String)
                }
            }
        } else {
            displayAlert("Error in form", message: "Please enter an email, username, and password")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameText.delegate = self
        passwordText.delegate = self
        emailText.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
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
