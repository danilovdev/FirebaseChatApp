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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        let loginController = LoginViewController()
        present(loginController, animated: true)
    }


}

