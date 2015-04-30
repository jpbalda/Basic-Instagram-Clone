//
//  SecondViewController.swift
//  Basic Instagram Clone
//
//  Created by Juan Pablo Balda Andrade on 4/21/15.
//  Copyright (c) 2015 JPBA. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    var searchResult = [PFUser]()
    var userFollowing = [String]()
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        var button = sender as! UIButton
        //Disable button to avoid double tap
        button.enabled = false
        
        //Check if user followed or unfollowed
        if button.currentTitle == "Follow" {
            //Create the relation between current user and user to follow
            var following = PFObject(className: "Follower")
            var userRelation = following.relationForKey("user")
            var followingRelation = following.relationForKey("following")
            userRelation.addObject(PFUser.currentUser()!)
            followingRelation.addObject(searchResult[sender.tag])
            following.saveInBackgroundWithBlock { (success, error) -> Void in
                if success == true {
                    //Change button's color and title
                    button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
                    button.setTitle("Unfollow", forState: UIControlState.Normal)
                }
                //Enable button
                button.enabled = true
            }
        } else {
            //Find the relation between current user and followed user to delete it
            var query = PFQuery(className: "Follower")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.whereKey("following", equalTo: searchResult[sender.tag])
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    // The find succeeded.
                    
                    // Do something with the found objects
                    if let userFollows = objects as? [PFObject] {
                        for row in userFollows {
                            //Change button's color and title
                            button.backgroundColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
                            button.setTitle("Follow", forState: UIControlState.Normal)
                            
                            //Delete relation
                            row.deleteInBackground()
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
                //Enable button
                button.enabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Find what users the current user is following
        var query = PFQuery(className: "Follower")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                
                // Do something with the found objects
                if let userFollows = objects as? [PFObject] {
                    for row in userFollows {
                        var followingRelation = row.relationForKey("following") as PFRelation
                        followingRelation.query()!.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                            //Append to array
                            self.userFollowing.append((object as! PFUser).username!)
                        })
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        userSearchBar.delegate = self
        
        //Turn off keyboards autocapitalize
        userSearchBar.autocapitalizationType = UITextAutocapitalizationType.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Get prototype cell
        var cell = tableView.dequeueReusableCellWithIdentifier("prototypeCell") as! SearchTableViewCell
        
        //Setup follow button
        cell.followButton.tag = indexPath.row
        
        //Check what users the current user is following compared to the search result
        if contains(userFollowing, searchResult[indexPath.row].username!) {
            //Change button's color and title
            cell.followButton.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            cell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
        }
        
        //Date format for subtitle
        let format = NSDateFormatter()
        format.dateStyle = NSDateFormatterStyle.LongStyle
        
        //Set title and subtitle
        cell.textLabel?.text = searchResult[indexPath.row].username
        cell.detailTextLabel?.text = "Member since " + format.stringFromDate(searchResult[indexPath.row].createdAt!)

        //Get user's image
        let imageObject:AnyObject? = searchResult[indexPath.row].objectForKey("image")
        if imageObject != nil {
            let image = imageObject as! PFFile
            image.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                    cell.imageView?.image = UIImage(data: imageData!)
                }
            })
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //Remove white spaces
        let searchText = searchBar.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //Check that search text is more than or equal to 3 charaters long
        if count(searchText) >= 3 {
            //Hide keyboard
            searchBar.resignFirstResponder()
            
            //Look for users that contain the search text
            var query = PFUser.query()!
            query.whereKey("username", containsString: searchBar.text)
            query.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
            query.whereKey("emailVerified", equalTo: true)
            query.orderByAscending("username")
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    // The find succeeded.
                    
                    //Remove all items in array
                    self.searchResult.removeAll(keepCapacity: true)
                    
                    // Do something with the found objects
                    if let users = objects as? [PFUser] {
                        for user in users {
                            //Append user to array
                            self.searchResult.append(user)
                        }
                        //Reload table view
                        self.resultsTableView.reloadData()
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Check segue identifier
        if segue.identifier == "userProfileSegue" {
            var vc = segue.destinationViewController as! UserProfileViewController
            
            //Get cell index
            var indexPath = resultsTableView.indexPathForSelectedRow()
            
            //Pass data to view controller
            vc.searchResult = self.searchResult
            vc.selectedIndex = indexPath!.row
        }
    }
}

