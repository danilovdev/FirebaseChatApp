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
import MobileCoreServices
import AVFoundation


protocol ZoomingDelegate {
    
    func handleZoomForImageView(startingImageView: UIImageView)
}

class ChatLogController: UICollectionViewController {
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    
    var startingImageView: UIImageView?
    
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
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "ic_image_48pt")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        
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
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
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
        
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
       return inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func handleUploadTap(sender: UIGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String,
                                            kUTTypeMovie as String
        ]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func setupKeyboardObservers() {
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidlShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidlShow(notification: Notification) {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                let keyboardFrame = frameValue.cgRectValue
                let duration = durationValue.doubleValue
                containerViewButtonAnchor?.constant = -keyboardFrame.height
                    UIView.animate(withDuration: duration, animations: {
                        self.view.layoutIfNeeded()
                    })
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: Notification) {
        containerViewButtonAnchor?.constant = 0
        if let userInfo = notification.userInfo,
            let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            let duration = durationValue.doubleValue
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    var containerViewButtonAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        let text = inputTextField.text!
        let properties: [String: Any] = ["text": text]
        sendMessageWithProperties(properties: properties)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.zoomingDelegate = self
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
           cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func observerMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded) { snapshot in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
            })
        }
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSString(string: text).boundingRect(with: size,
                                            options: options,
                                            attributes: attributes,
                                            context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> Void) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let imageUrl = metaData?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        let messagesRef = Database.database().reference().child("messages")
        let childRef = messagesRef.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let toId = user!.id!
        let timestamp = Int(Date().timeIntervalSince1970)
        var values: [String: Any] = [
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        
        properties.forEach { (key, value) in
            values[key] = value
        }
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userRefMessages = Database.database().reference()
                .child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userRefMessages.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference()
                .child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: Any] = ["imageUrl": imageUrl,
                          "imageWidth": image.size.width,
                          "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    @objc private func handleZoomOut(sender: UIGestureRecognizer) {
        if let zoomOutImageView = sender.view as? UIImageView {
            zoomOutImageView.layer.cornerRadius = 16.0
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1.0
            }, completion: { completed in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    private func handleImageSelectedForInfo(info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { imageUrl in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    private func handleVideoSelectedForUrl(url: URL) {
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(fileName).putFile(from: url, metadata: nil, completion: { [unowned self] (metadata, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { imageUrl in
                        let properties: [String: Any] = [
                            "imageUrl": imageUrl,
                            "imageWidth": thumbnailImage.size.width,
                            "imageHeight": thumbnailImage.size.height,
                            "videoUrl": videoUrl]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { [unowned self] snapshot in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { [unowned self] snapshot in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error as NSError {
            print(error)
        }
        return nil
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
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if message.imageUrl != nil, let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth) * 200
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
}

extension ChatLogController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForUrl(url: videoUrl)
        } else {
            handleImageSelectedForInfo(info: info)
        }
        
        dismiss(animated: true)
    }
    
}

extension ChatLogController: ZoomingDelegate {
    func handleZoomForImageView(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        if let startingFrame = startingFrame, let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0.0
            keyWindow.addSubview(blackBackgroundView!)
            
            let zoomingImageView = UIImageView(frame: startingFrame)
            zoomingImageView.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleZoomOut))
            zoomingImageView.addGestureRecognizer(tapGestureRecognizer)
            zoomingImageView.image = startingImageView.image
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1.0
                self.inputContainerView.alpha = 0.0
                
                let height = (startingFrame.height / startingFrame.width) * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
}

