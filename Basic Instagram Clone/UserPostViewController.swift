//
//  UserImageViewController.swift
//  Basic Instagram Clone
//
//  Created by Juan Pablo Balda Andrade on 4/28/15.
//  Copyright (c) 2015 JPBA. All rights reserved.
//

import UIKit

class UserPostViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var selectedImage = UIImage()
    var postComment = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Set post image and comment
        userImage.image = selectedImage
        commentTextView.text = postComment
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
