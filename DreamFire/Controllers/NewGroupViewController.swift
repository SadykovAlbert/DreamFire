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
    
    var masFriends = [AppUser]()
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
        saveBarButtonOutlet.title = "Save"
        buttonOutlet.isHidden = true
        
        //
    }
    func setupProfile(){
        //buttonOutlet.isHidden = false
        tableViewOutlet.isHidden = false
        nameTextField.isEnabled = false
        descriptionTextField.isEnabled = false
        nicknameTextField.isEnabled = false
        saveBarButtonOutlet.isEnabled = true//?
        saveBarButtonOutlet.title = "Add Users"
        
        nameTextField.text = group?.name
        descriptionTextField.text = group?.description
        nicknameTextField.text = group?.nickname
        
        buttonOutlet.isHidden = true
        guard let userMail = Auth.auth().currentUser?.email else {return}
        let groupAdmin = group?.admin
        if userMail == groupAdmin{
            buttonOutlet.isHidden = false
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            self.displayListOfUsers()
        
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        generateMasFriends()
        setupUI()
      
        
    }
    func generateMasFriends(){
        
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let userFriendsRef = Database.database().reference().child("users").child(myUid).child("friendsmail")
        userFriendsRef.observe(.value) { (snapshot) in
            
            //
            var _mails = [String]()

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    guard let dict = snap.value as? [String:String] else {return}
                    guard let mail = dict["email"] else {return}
                    _mails.append(mail)

                }
            }
         
            self.mails = _mails
            
        }
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.value) { (snapshot) in
            
            var _friends = [AppUser]()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    let user = AppUser(snapshot: snap)
                    for mail in self.mails{
                        if mail == user.email{
                            _friends.append(user)
                            break
                        }
                    }
                }
                
            }
            self.masFriends = _friends
            
        }
        
    }
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
    
        switch segueChoise {
        case .profileGroup:
            addButtonAction()
        case .registrationGroup:
            saveButtonAction()
        }
        
    }
    func saveButtonAction(){
        
        //
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
        groupRef.child("groupusers").childByAutoId().setValue(["email" : userMail,"uid":user.uid])
        
        let myGroupRef = Database.database().reference().child("users").child(user.uid).child("groups").child(uid)//
        myGroupRef.setValue(["nickname":group.nickname])
        self.navigationController?.popViewController(animated: true)
        //
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addUsersTOGroupSegue"{
            let vc = segue.destination as! AddFriendViewController
            vc.segueChoise = .addNewUserToGroup
            //vc.groupUid = groupUid
            vc.group = group
            vc.friends = masFriends
        }
    }
    
    func addButtonAction(){
        
        performSegue(withIdentifier: "addUsersTOGroupSegue", sender: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //DELETE GROUP
        //print("HELOO DELETE")
        guard let groupUid = group?.uid else {return}
        
        //print("groupUsers: \(groupUsers)")
        
        //
        var masRef = [DatabaseReference]()
        for _ in 0 ..< groupUsers.count{
            masRef.append(Database.database().reference().child("users"))
        }
        //
        //var i = 0
        for userInGroup in groupUsers{
            let userUid = userInGroup.uid
            
            //print("uid: \(userUid)")
            let groupOfUserRef = Database.database().reference().child("users").child(userUid).child("groups").child(groupUid)
            
            //let groupOfUserRef = masRef[i].child(userUid).child("groups").child(groupUid)
            //i += 1
            groupOfUserRef.removeValue()
            //print("INArray")
        }
        
        //print("group users count: \(groupUsers.count)")
        let usersOfgroupRef = Database.database().reference().child("groups").child(groupUid)
        usersOfgroupRef.removeValue()
        
        self.navigationController?.popViewController(animated: true)
        
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
        
        print("mailsINDisplaList: \(mails)")

        //========

        guard let uid = groupUid else {return}
        let ref = Database.database().reference().child("groups").child(uid).child("groupusers")

        ref.observe(.value) { (snapshot) in

            
            var _mails:[String] = []

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {



                    guard let maildict = snap.value as? [String : AnyObject] else {return}
                    guard let mail = maildict["email"] as? String else {return}

                    _mails.append(mail)

                }
            }
            self.mails = _mails

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
