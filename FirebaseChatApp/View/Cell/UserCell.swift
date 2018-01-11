//
//  UserCell.swift
//  FirebaseChatApp
//
//  Created by Alexey Danilov on 12.01.18.
//  Copyright © 2018 danilovdev. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
