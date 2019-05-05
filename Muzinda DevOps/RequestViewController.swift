//
//  RequestViewController.swift
//  Muzinda DevOps
//
//  Created by Casse on 5/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import UIKit

class RequestViewController: ViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.title = "Request Service"
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        let newRequestId = API.Map.REF_MAPREQ.childByAutoId().key
        let newRequestReference = API.Map.REF_MAPREQ.child(newRequestId!)
        let dict = ["latitude": Double(latitudeTextField.text!)!, "longitude": Double(longitudeTextField.text!)!, "name": nameTextField.text!] as [String : Any]
        print(dict)
        newRequestReference.setValue(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
               print(error!.localizedDescription)
                return
            }
        })
    }
}
