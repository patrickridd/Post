//
//  Post.swift
//  Post
//
//  Created by Patrick Ridd on 7/12/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation

class Post {
    
    let username: String
    let text: String
    let timeStamp: NSTimeInterval
    var identifier: NSUUID
    
    
    init(username: String, text: String, timeStamp: NSTimeInterval = NSDate().timeIntervalSince1970, identifier: NSUUID = NSUUID()){
        
        self.username = username
        self.text = text
        self.identifier = identifier
        self.timeStamp = timeStamp
        
    }
    
    init?(dictionary: [String: AnyObject], identifier: String) {
        guard let username = dictionary["username"] as? String,
            text = dictionary["text"] as? String,
            timeStamp = dictionary["timestamp"] as? NSTimeInterval else {
                return nil
        }
        
        self.username = username
        self.text = text
        self.timeStamp = timeStamp
        self.identifier =  NSUUID(UUIDString: identifier) ?? NSUUID()
        
    }
    
    /*Add an endpoint computed property. Append the .identifier string value and '.json' to the PostController.baseURL to
     return the URL for the HTTP request.
     */
    var endpoint: NSURL? {
        return PostController.baseURL?.URLByAppendingPathComponent(self.identifier.UUIDString).URLByAppendingPathExtension("json")
    }
    
    /* Add a jsonValue computed property that returns a [String: AnyObject] representation of the Post object.
       note: Remember to use the correct keys. This will be the same Dictionary that you use in the failable initializer.
    */
    
    var jsonValue: [String: AnyObject] {
        return ["text":text, "timestamp": timeStamp, "username":username]
    }
    /* Add a jsonData computed property as a convenient accessor that uses NSJSONSerialization to get an NSData? representation of the jsonValue dictionary.
     note: This will be used when you set the HTTP Body on the NSMutableURLRequest, which requires NSData?, not a [String: AnyObject]
    */
    var jsonData: NSData? {
        return try? NSJSONSerialization.dataWithJSONObject(jsonValue, options: .PrettyPrinted)
    }
    var queryTimestamp: NSTimeInterval {
        return self.timeStamp - 1
    }
}