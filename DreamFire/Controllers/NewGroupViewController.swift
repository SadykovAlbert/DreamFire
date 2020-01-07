//
//  NewGroupViewController.swift
//  DreamFire
//
//  Created by Albert on 05/01/2020.
//  Copyright © 2020 Albert. All rights reserved.
//

import UIKit
import Firebase

class NewGroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var saveBarButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    enum whichSegue {
        case registrationGroup
        case profileGroup
    }
    
    var segueChoise: whichSegue = .profileGroup
    
    func setupUI(){
        
        switch segueChoise {
        case .registrationGroup:
            setupRegistration()
        case .profileGroup:
            setupProfile()
        }

    }
    
    func setupRegistration(){
        buttonOutlet.isHidden = true
        tableViewOutlet.isHidden = true
        //
        nameTextField.text = ""
        descriptionTextField.text = ""
        nicknameTextField.text = ""
        //
    }
    func setupProfile(){
        buttonOutlet.isHidden = false
        tableViewOutlet.isHidden = false
        nameTextField.isEnabled = false
        descriptionTextField.isEnabled = false
        nicknameTextField.isEnabled = false
        saveBarButtonOutlet.isEnabled = false
        saveBarButtonOutlet.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let name = nameTextField.text,
        let  description = descriptionTextField.text,
        let nickname = nicknameTextField.text,
        name != "",
        description != "",
        nickname != ""
            else {return}
        
        nameTextField.text = ""
        descriptionTextField.text = ""
        nicknameTextField.text = ""

        
        guard let user = Auth.auth().currentUser else {return}
        guard let userMail = user.email else {return}
        
        let groupRef = Database.database().reference().child("groups").child(user.uid)
        let group = AppGroup(name: name, description: description, nickname: nickname, admin: userMail)
        groupRef.setValue(group.convertToDictionary())
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
