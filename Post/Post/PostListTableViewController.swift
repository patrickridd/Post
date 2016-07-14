//
//  PostListTableViewController.swift
//  Post
//
//  Created by Patrick Ridd on 7/13/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, PostControllerDelegate {
    
    
    var postController = PostController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200

        
        
        
        self.refreshControl?.addTarget(self, action: #selector(PostListTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // MARK: - Actions
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        postController.fetchPosts { (postArray) in
            
            self.tableView.reloadData()
            print("refreshed tableview")
            self.refreshControl?.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    
    @IBAction func addPost(sender: AnyObject) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let postAlert = UIAlertController(title: "Enter Post", message: "Enter Username and Message", preferredStyle: .Alert)
        
        postAlert.addTextFieldWithConfigurationHandler { (userNameTextField: UITextField) in
            userNameTextField.placeholder = "username please..."
        }
        postAlert.addTextFieldWithConfigurationHandler { (messageTextField: UITextField) in
            messageTextField.placeholder = "enter your message here..."
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let postAction = UIAlertAction(title: "Post", style: .Default) { (UIAlertAction) in
            
            guard let username = postAlert.textFields?[0].text, text = postAlert.textFields?[1].text else { return}
            
            self.postController.addPost(username, text: text)
            
            
            
            
        }
        postAlert.addAction(dismissAction)
        postAlert.addAction(postAction)
        presentViewController(postAlert, animated: true, completion: nil)
    }
    
    
    func presentErrorAlert() {
        let errorAlert = UIAlertController(title: "Missing Information", message: "You are missing information in either the username and/or message field. Try again.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        errorAlert.addAction(okAction)
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath)
        let post = postController.posts[indexPath.row]
        // Configure the cell...
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.username
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row + 1 >= postController.posts.count {
            postController.fetchPosts(false, completion: { (postArray) in
                if postArray != nil {
                    tableView.reloadData()
                }
            })
            
            
        }
    }
        // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         
        
        // MARK: - PostControllerDelegate Protocol Methods
        func postsUpdated(posts: [Post]) {
            tableView.reloadData()
        }
        
        
        
        
        
    
}
