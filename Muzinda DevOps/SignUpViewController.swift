//
//  SignUpViewController.swift
//  Spark
//
//  Created by Stacey Smith on 11/19/18.
//  Copyright © 2018 AppsDevo. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var stackViewBottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var stackViewTosignUPButtonConstraint: NSLayoutConstraint!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        
        setUpTextField(usernameTextField)
        setUpTextField(passwordTextField)
        setUpTextField(emailTextField)
        setUpTextView(usernameTextField)
        setUpTextView(passwordTextField)
        setUpTextView(emailTextField)
        
        self.signUpButton.layer.cornerRadius = signUpButton.frame.size.height / 2
        self.signUpButton.clipsToBounds = true
        
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = (profileImage.frame.size.width / 2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        self.signUpButton.isEnabled = false
        self.signUpButton.backgroundColor = .lightGray
        self.signUpButton.setTitleColor(.white, for: UIControl.State.normal)
        
        handleTextField()
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setUpTextField(_ textField: UITextField) {
        
        textField.backgroundColor = UIColor.white
        textField.tintColor = UIColor.black
        textField.textColor = UIColor.black
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: textField.frame.height))
        textField.leftView = paddingView
        
        //        let passwordPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: self.textField.frame.height))
        //        textField.leftView = passwordPaddingView
    }
    
    func setUpTextView(_ textField: UITextField) {
        
        let emailView = UIImageView()
        let passwordView = UIImageView()
        let usernameView = UIImageView()
        let imagePassword = UIImage(named: "lock")
        let imageEmail = UIImage(named: "email1")
        let imageUsername = UIImage(named: "userFilled")
        
        emailView.image = imageEmail
        passwordView.image = imagePassword
        usernameView.image = imageUsername
        
        if textField == emailTextField {
            
            emailView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
            textField.leftViewMode = UITextField.ViewMode.always
            textField.addSubview(emailView)
            
        } else if textField == passwordTextField {
            
            passwordView.frame = CGRect(x: 12, y: 10, width: 20, height: 18)
            textField.leftViewMode = UITextField.ViewMode.always
            textField.addSubview(passwordView)
            
        } else if textField == usernameTextField {
            
            usernameView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
            usernameTextField.leftViewMode = UITextField.ViewMode.always
            usernameTextField.addSubview(usernameView)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            signupButtonTapped(Any.self)
        }
        return true
    }
    
    @objc func keyboardWillChange(notification: Foundation.Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            stackViewBottomConstriant.constant = keyboardRect.size.height + stackViewTosignUPButtonConstraint.constant + signUpButton.frame.size.height + 10
            
            if profileImage.frame.size.height <= 50 {
                profileImage.fadeOut(1)
            }
            
            print("profile image height: \(profileImage.frame.size.height)")
            
            UIView.animate(withDuration: 0.5)  {
                self.view.layoutIfNeeded()
            }
            
        } else {
            
            stackViewBottomConstriant.constant = 160
            self.profileImage.fadeIn(0.9)
            UIView.animate(withDuration: 0.8) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        if profileImage.isHidden {
            profileImage.fadeIn(1)
        }
    }
    
    func handleTextField() {
        
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text?.replacingOccurrences(of: " ", with: "").lowercased(), !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            self.signUpButton.backgroundColor = .gray
            self.signUpButton.setTitleColor(.lightGray, for: UIControl.State.normal)
            self.signUpButton.isEnabled = false
            return
        }
        
        self.signUpButton.backgroundColor = .blue
        self.signUpButton.setTitleColor(.white, for: UIControl.State.normal)
        self.signUpButton.isEnabled = true
    }
    
    @objc func handleSelectProfileImageView() {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present (pickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismissOnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        
        if let profileImg = self.selectedImage != nil ? self.selectedImage : UIImage(named: "placeholderImg"), let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!.replacingOccurrences(of: " ", with: "").lowercased(), password: passwordTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.performSegue(withIdentifier: "signupToMap", sender: nil)
            }, onError: { (errorString) in
                ProgressHUD.showError(errorString!)
            })
        } else {
            ProgressHUD.showError("Profile Image can't be empty")
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if  let  image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension UIImageView {
    
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIImageView.animate(withDuration: duration!,
                            animations: { self.alpha = 1 },
                            completion: { (value: Bool) in
                                if let complete = onCompletion { complete() }
        })
    }
    
    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIImageView.animate(withDuration: duration!,
                            animations: { self.alpha = 0 },
                            completion: { (value: Bool) in
                                self.isHidden = false
                                if let complete = onCompletion { complete() }
        })
    }
}
