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
    
    var group:AppGroup?
    
    var groupUid: String?
    var groupUsers = [AppUser]()

    var mails = [String]()
    
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
        
        nameTextField.text = group?.name
        descriptionTextField.text = group?.description
        nicknameTextField.text = group?.nickname
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayListOfUsers()
        
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
        
        let groupRef = Database.database().reference().child("groups").childByAutoId()
        
        guard let uid = groupRef.key else {return}
        
        
        
        let group = AppGroup(name: name, description: description, nickname: nickname, admin: userMail, uid: uid)
        groupRef.setValue(group.convertToDictionary())
        groupRef.child("groupusers").childByAutoId().setValue(["email" : userMail])
        
        let myGroupRef = Database.database().reference().child("users").child(user.uid).child("groups").childByAutoId()
        myGroupRef.setValue(["nickname":group.nickname])
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellViewGroupUsers", for: indexPath) as! CustomTableViewCell
        
        let name = groupUsers[indexPath.row].name
        let lastName = groupUsers[indexPath.row].lastName
        cell.nameLabel.text = name
        cell.lastNameLabel.text = lastName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func displayListOfUsers(){
        

        guard let uid = groupUid else {return}
        let ref = Database.database().reference().child("groups").child(uid).child("groupusers")
        //========
        ref.observe(.value) { (snapshot) in
            
            
            var _mails:[String] = []

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {

                    

                    guard let maildict = snap.value as? [String : String] else {return}
                    guard let mail = maildict.values.first else {return}
               
                    _mails.append(mail)

                }
            }
            self.mails = _mails
            print("1observeEND")
        }
    
        //================
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.value) { (snapshot) in

            
            var _groupUsers:[AppUser] = []

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {

                   
                    let user = AppUser(snapshot: snap)
                    for mail in self.mails{
                        
                        if user.email == mail{
                            _groupUsers.append(user)
                        }
                    }

                }
            }
            self.groupUsers = _groupUsers
            self.tableViewOutlet.reloadData()

            
        }
        //======
        
        
        
        
    }
    
    
    
}
