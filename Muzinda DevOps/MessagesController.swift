//
//  MessagesController.swift
//  Spark
//
//  Created by Casse on 13/3/19.
//  Copyright © 2019 AppsDevo. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var messages = [Message]()
    var messagesDictionary = [String: Message]() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleView = UILabel()
        titleView.text = "Messages"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.textColor = UIColor.black
        self.navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissMessageController))
        reloadDataOnView()
    }
    
    func reloadDataOnView() {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        obeserveUserMessages()
    }
    
    func obeserveUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("userMessages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("userMessages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    private func fetchMessageWithMessageId(messageId: String) {
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = UserModel()
            user.id = chatPartnerId
            user.username = dictionary["username"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(user: UserModel) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    @objc func dismissMessageController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
}
