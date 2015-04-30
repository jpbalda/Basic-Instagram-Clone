//
//  UserProfileViewController.swift
//  Basic Instagram Clone
//
//  Created by Juan Pablo Balda Andrade on 4/27/15.
//  Copyright (c) 2015 JPBA. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postsColletion: UICollectionView!
    
    var searchResult = [PFUser]()
    var selectedIndex = -1
    var userPosts = [PFObject]()
    var userImages = [Int: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set navigation title
        self.navigationItem.title = searchResult[selectedIndex].username
        
        //Get user's image
        let imageObject:AnyObject? = searchResult[selectedIndex].objectForKey("image")
        
        if imageObject != nil {
            let image = imageObject as! PFFile
            image.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                    self.userImage.image = UIImage(data: imageData!)
                }
            })
        }
        
        //Get user's posts
        var query = PFQuery(className: "Post")
        query.whereKey("createdBy", equalTo: searchResult[selectedIndex])
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                self.postsLabel.text = "\(objects!.count)"
                // Do something with the found objects
                if let posts = objects as? [PFObject] {
                    for post in posts {
                        self.userPosts.append(post)
                    }
                    self.postsColletion.reloadData()
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        //Get number of followers
        query = PFQuery(className: "Follower")
        query.whereKey("following", equalTo: searchResult[selectedIndex])
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil {
                self.followersLabel.text = "\(count)"
            }
        }
        
        //Get number of users following
        query = PFQuery(className: "Follower")
        query.whereKey("user", equalTo: searchResult[selectedIndex])
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error == nil {
                self.followingLabel.text = "\(count)"
            }
        }
        
        postsColletion.delegate = self
        postsColletion.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Get prototype cell
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("prototypeCell", forIndexPath: indexPath) as! UserProfileCollectionViewCell
        
        //Get post image
        let imageObject:AnyObject? = userPosts[indexPath.row].objectForKey("image")

        if imageObject != nil {
            let image = imageObject as! PFFile
            image.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                    //Append image to array
                    self.userImages[indexPath.row] = (UIImage(data: imageData!)!)
                    cell.postImage.image = UIImage(data: imageData!)
                }
            })
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Check segue identifier
        if segue.identifier == "userImageSegue" {
            var vc = segue.destinationViewController as! UserPostViewController
            
            //Get cell index
            var indexPath = postsColletion.indexPathsForSelectedItems().first as! NSIndexPath
            
            //Pass data to view controller
            vc.selectedImage = userImages[indexPath.row]!
            vc.postComment = userPosts[indexPath.row].objectForKey("comment") as! String
        }
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
