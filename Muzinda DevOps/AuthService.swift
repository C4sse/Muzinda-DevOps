//
//  AuthService.swift
//  Spark
//  Created by Stacey Smith on 11/21/18.
//  Copyright © 2018 AppsDevo. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AuthService {
    
    static func logIn (email: String,  password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func  signUp(username: String, email: String,  password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authData: AuthDataResult?, error: Error?) in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            let uid = authData!.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid)
            
            storageRef.putData(imageData, metadata: nil, completion: { (_, error: Error?) in
                
                if error != nil {
                    return
                }
                
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    if error != nil {
                        return
                    } 
                    
                    if let profileImageUrl = url?.absoluteString {
                        
                        self.setUserInformation(profileImageUrl: profileImageUrl, username: username, email: email, uid: uid, onSuccess: onSuccess)
                    }
                })
            })
        }
    }
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "usernameLowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
    }
    
    static func updateUserInfo (username: String, email: String,imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            
            let userId = Auth.auth().currentUser?.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(userId!)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata,  error) in
                if error != nil {
                    return
                }
                
                storageRef.downloadURL(completion: { ( url, error ) in
                    
                    if error != nil {
                        return
                    }
                    
                    if let profileImageUrl = url?.absoluteString {
                        self.updateDatabase(profileImageUrl: profileImageUrl, username: username, email: email, onSuccess: onSuccess, onError: onError)
                    }
                })
            })
        })
    }
    
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "usernameLowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref)in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
}



