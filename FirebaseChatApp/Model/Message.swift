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

class Message {
    
    var fromId: String?
    
    var toId: String?
    
    var text: String?
    
    var timestamp: Int?
    
    var imageUrl: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
