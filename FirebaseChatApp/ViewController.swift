//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Alexey Danilov on 09.01.18.
//  Copyright © 2018 danilovdev. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let reference = Database.re
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
    }
    
    @objc func handleLogout() {
        let loginController = LoginViewController()
        present(loginController, animated: true)
    }


}

