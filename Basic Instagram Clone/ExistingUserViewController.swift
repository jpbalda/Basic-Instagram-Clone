//
//  LoginViewController.swift
//  Basic Instagram Clone
//
//  Created by Juan Pablo Balda Andrade on 4/21/15.
//  Copyright (c) 2015 JPBA. All rights reserved.
//

import UIKit
import Parse


class ExistingUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBAction func LogInTapped(sender: AnyObject) {
        //Remove white spaces
        let user = usernameText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let pass = passwordText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //Validate fields
        if user != "" && pass != "" {
            //Show activity indicator (spinner)
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            //Ignore all user interactions
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            //Log user in
            PFUser.logInWithUsernameInBackground(user, password:pass) {
                (user: PFUser?, error: NSError?) -> Void in
                //Hide activity indicator (spinner)
                self.activityIndicator.stopAnimating()
                
                //Start accepting user interactions
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                    // Do stuff after successful login.
                    
                    //Check if email is verified
                    if user!.objectForKey("emailVerified")! as! Bool == true {
                        //Segue to Home
                        self.performSegueWithIdentifier("logInSegue", sender: self)
                    } else {
                        self.displayAlert("Couldn't log in", message: "Please verify your email address first")
                    }
                } else {
                    // The login failed. Check error to see why.
                    self.displayAlert("Couldn't log in", message: error!.userInfo?["error"] as! String)
                }
                
            }
        } else {
            displayAlert("Error in form", message: "Please enter username and password")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameText.delegate = self
        passwordText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Go directly to Home if user is already logged in
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("logInSegue", sender: self)
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide keyboard
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
