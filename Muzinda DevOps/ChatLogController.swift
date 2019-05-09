//
//  ChatLogController.swift
//  Spark
//
//  Created by Casse on 15/3/19.
//  Copyright © 2019 AppsDevo. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let cellId = "cellId"
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
        setupKeyboardObserver()
    }
    
    var user: UserModel? {
        didSet {
            navigationItem.title = user?.username
            observeMessages()
        }
    }
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user!.id else { return }
        
        let userMessagesRef = Database.database().reference().child("userMessages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView.delegate = self
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    //scroll to the last index
                    if self.messages.count > 5 {
                        self.collectionView.contentOffset.y = (400)
                        self.collectionView.scrollToItem(at: NSIndexPath(item: self.messages.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "uploadImage")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: sendButton.intrinsicContentSize.width).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return containerView
    }()
    
    @objc func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        
        if let selectedImage = selectedImage {
            
            uploadToFirebaseStorageUsingImage(selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let data = image.jpegData(compressionQuality: 0.2) {
            
            ref.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                ref.downloadURL(completion: { (url: URL?, error: Error?) in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    
                    if let photoUrl = url?.absoluteString {
                        self.sendMessageWithImageUrl(photoUrl, image: image)
                    }
                })
            }
        }
    }
    
    private func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        
        sendMessageWithProperties(properties)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func setupKeyboardObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //        NotificationCenter.default.addObserver(self,
        //        selector: #selector(handleKeyboardWillShow),
        //        name: UIResponder.keyboardWillShowNotification, object: nil)
        //
        //        NotificationCenter.default.addObserver(self,
        //        selector: #selector(handleKeyboardWillHide),
        //        name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyBoardDidShow() {
        if self.messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Use Deinit later
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        //move input area
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        //move back input area
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor!.constant = self.estimatedFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        if let profileImageUrl = self.user!.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            // outgoing
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.layoutIfNeeded()
            
        } else {
            //incoming
            cell.bubbleView.backgroundColor = ChatMessageCell.lightGray
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false 
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.layoutIfNeeded()
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.messageImageView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 22
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        self.view.layoutIfNeeded()
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    public var screenWidth: CGFloat { return UIScreen.main.bounds.width * 0.70 }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: screenWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        
        if inputTextField.text! == "" {
            return
        }
        let properties = ["text": inputTextField.text!] as [String: AnyObject]
        self.inputTextField.text = nil
        sendMessageWithProperties(properties)
    }
    
    private func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : AnyObject]
        
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                ProgressHUD.showError("unable to send")
                return
            }
            
            
            
            let userMessagesRef = Database.database().reference().child("userMessages").child(fromId).child(toId)
            let messagesId = childRef.key
            let recipientUserMessagesRef = Database.database().reference().child("userMessages").child(toId).child(fromId)
            
            userMessagesRef.child(messagesId!).setValue(true)
            recipientUserMessagesRef.child(messagesId!).setValue(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
