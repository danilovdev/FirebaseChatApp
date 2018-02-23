//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Alexey Danilov on 14.01.18.
//  Copyright © 2018 danilovdev. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    
    var toId: String?
    
    var text: String?
    
    var timestamp: Int?
    
    var imageUrl: String?
    
    var imageWidth: NSNumber?
    
    var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? Int
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    
}
