//
//  PostController.swift
//  Post
//
//  Created by Patrick Ridd on 7/12/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation


protocol PostControllerDelegate: class {
    func postsUpdated(posts: [Post])
}

class PostController {
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts")
    static let endpoint: String = "json"
    let urlAppended = baseURL?.URLByAppendingPathExtension(endpoint)
    
    weak var delegate: PostControllerDelegate?
    
    init() {
        
        fetchPosts { (postArray) in
            guard let posts = postArray else {
                print("Could not fetch posts upon initialization")
                return
            }
            
            self.posts = posts
            
        }
    }
    
    var posts: [Post] = [] {
        didSet {
            if let delegate = delegate {
                delegate.postsUpdated(posts)
            } else {
                print("Delegate was nil")
            }
        }
    }
    
    func fetchPosts(completion: (postArray: [Post]?) -> Void) {
        
        var postsArray: [Post] = []
        
        guard let url = urlAppended else {
            print("URL returned nil")
            completion(postArray: nil)
            return
        }
        
        
        NetworkController.performRequestForURL(url, httpMethod: .Get) { (data, error) in
            guard let data = data, jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String:AnyObject] else {
                completion(postArray: nil)
                return
            }
            
            for keyValuePair in jsonDictionary {
                guard let newDictionary = keyValuePair.1 as? [String : AnyObject]  else {
                    completion(postArray: nil)
                    return
                }
                let id = keyValuePair.0
                let post = Post(dictionary: newDictionary, identifier: id)
                if let post = post  {
                    postsArray.append(post)
                }
                
                
            }
            let sortedPosts = postsArray.sort({$0.timeStamp > $1.timeStamp})
            dispatch_async(dispatch_get_main_queue(), {
                completion(postArray: sortedPosts)
                
            })
            
            
        }
    }
    
    func addPost(userName: String, text: String) {
        let post = Post(username: userName, text: text)
        
        let requestURL = post.endpoint
        guard let url = requestURL else {
            print("URL for adding Post returned nil")
            return
        }
        NetworkController.performRequestForURL(url, httpMethod: .Put, body: post.jsonData) { (data, error) in
            let responseDataString = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? ""
            if error != nil {
                print("Error: \(error?.localizedDescription)")
            } else if responseDataString.containsString("error") {
                print("Error: \(responseDataString). Contains 'error' in response string.")
            } else {
                print("Successfully saved data to endpoint. \nResponse: \(responseDataString)")
            }
            
            
        }
        fetchPosts { (postArray) in
            
        }
    }
}
