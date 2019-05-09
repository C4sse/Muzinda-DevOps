//
//  ViewController.swift
//  Spark
//
//  Created by Stacey Smith on 11/19/18.
//  Copyright © 2018 AppsDevo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewToLoginButtonConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.isHidden = false
        self.passwordTextField.isHidden = false
        self.LoginButton.isHidden = true
        self.LoginButton.layer.cornerRadius = LoginButton.frame.size.height / 2
        self.LoginButton.clipsToBounds = true
        
        setUpTextView(emailTextField)
        setUpTextView(passwordTextField)
        setUpTextField(emailTextField)
        setUpTextField(passwordTextField)
        
        self.LoginButton.isEnabled = false
        handleTextField()
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
        let imagePassword = UIImage(named: "lock")
        let imageEmail = UIImage(named: "email1")
        
        emailView.image = imageEmail
        passwordView.image = imagePassword

        if textField == emailTextField {

            emailView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
            textField.leftViewMode = UITextField.ViewMode.always
            textField.addSubview(emailView)

        } else if textField == passwordTextField {

            passwordView.frame = CGRect(x: 12, y: 10, width: 20, height: 18)
            textField.leftViewMode = UITextField.ViewMode.always
            textField.addSubview(passwordView)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if API.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "loginToTabBarVC", sender: nil)
        }
    }
    
    func handleTextField() {
        
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            stackViewBottomConstraint.constant = keyboardRect.size.height + LoginButton.frame.size.height + 10
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            
            stackViewBottomConstraint.constant = 250
            
            UIView.animate(withDuration: 0.8) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @objc func textFieldDidChange() {
        
        guard  let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            self.LoginButton.setTitleColor(.white, for: UIControl.State.normal)
            self.LoginButton.isEnabled = false
            
            return
        }
        
        self.LoginButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            let databaseReff = Database.database().reference().child("users")
            
            databaseReff.queryOrdered(byChild: "email").queryEqual(toValue: self.emailTextField.text!).observe(.value, with: { snapshot in
                if snapshot.exists(){
                    
                    //User email exist
                    print("it exists")
                    self.passwordTextField.isHidden = false
                    textField.resignFirstResponder()
                    self.passwordTextField.becomeFirstResponder()
                    self.LoginButton.isHidden = false
                }
                else{
                    //email does not [email id available]
                    print("it doesnt exist")
                }
                
            })
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            LoginButtonTapped((Any).self)
        }
        return true
    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        AuthService.logIn(email: emailTextField.text!.replacingOccurrences(of: " ", with: "").lowercased(), password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "loginToTabBarVC", sender: nil)
            
        }, onError: {error in
            
            ProgressHUD.showError(error!)
        })
    }
}
