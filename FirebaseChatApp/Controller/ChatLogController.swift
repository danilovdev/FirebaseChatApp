//
//  ChatLogController.swift
//  FirebaseChatApp
//
//  Created by Alexey Danilov on 14.01.18.
//  Copyright © 2018 danilovdev. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    var messages = [Message]()
    
    let cellId = "cellId"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observerMessages()
        }
    }
    
    lazy var inputTextField: UITextField = {
       let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setInputComponents()
    }
    
    func setInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    }
    
    @objc func handleSend() {
        let messagesRef = Database.database().reference().child("messages")
        let childRef = messagesRef.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let toId = user!.id!
        let text = inputTextField.text!
        let timestamp = Int(Date().timeIntervalSince1970)
        let values: [String: Any] = ["text": text, "toId": toId, "fromId": fromId, "timestamp": timestamp]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userRefMessages = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userRefMessages.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    func observerMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded) { snapshot in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.toId = dictionary["toId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? Int
                
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
                
            })
            
        }
    }
    
}

extension ChatLogController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}

