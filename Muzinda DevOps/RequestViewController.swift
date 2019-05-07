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
        
        
    }
}
