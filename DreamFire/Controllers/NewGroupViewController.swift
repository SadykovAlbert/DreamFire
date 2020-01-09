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
        
        //
    }
    func setupProfile(){
        buttonOutlet.isHidden = false
        tableViewOutlet.isHidden = false
        nameTextField.isEnabled = false
        descriptionTextField.isEnabled = false
        nicknameTextField.isEnabled = false
        saveBarButtonOutlet.isEnabled = true//?
        saveBarButtonOutlet.title = "Add Users"
        
        nameTextField.text = group?.name
        descriptionTextField.text = group?.description
        nicknameTextField.text = group?.nickname
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            self.displayListOfUsers()
        
        //print("mailsInVDA: \(mails)")
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //displayListOfUsers()
        //print("VWD: \(mails)")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //displayListOfUsers()
        //print("VDD: \(mails)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //displayListOfUsers()
        //generateMasFriends
        //print("mailsInVWA: \(mails)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //displayListOfUsers()
        generateMasFriends()
        setupUI()
      
        //print("mailsInVDL: \(mails)")
        
    }
    func generateMasFriends(){
        
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let userFriendsRef = Database.database().reference().child("users").child(myUid).child("friendsmail")
        userFriendsRef.observe(.value) { (snapshot) in
            
            //
            var _mails = [String]()
            //print("Snapshot is : \(snapshot)")
            
            
            //
//            guard let snaps = snapshot.children.allObjects as? [DataSnapshot] else {return}
//            guard let mymas = snaps as? [AppUser]
            //
            
//            guard let massivFriends = snapshot as? [Int:AppUser] else {return}
//            print("mas: \(massivFriends)")
//            guard let friend = snapshot.value as? AppUser else {print("error AS1"); return}
            
            //_friends.append(friend)
            
            //print("/////=========")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    //print("snap is: \(snap)")
                    //let friend = AppUser(snapshot: snap)
                    guard let dict = snap.value as? [String:String] else {return}
                    guard let mail = dict["email"] else {return}
                    _mails.append(mail)

                }
            }
         
            self.mails = _mails
            //print("masMails: \(self.mails)")
            //
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
            print("friends: \(self.masFriends)")
            print("//////============")
        }
        
    }
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        
//        guard let name = nameTextField.text,
//        let  description = descriptionTextField.text,
//        let nickname = nicknameTextField.text,
//        name != "",
//        description != "",
//        nickname != ""
//            else {return}
//
//        nameTextField.text = ""
//        descriptionTextField.text = ""
//        nicknameTextField.text = ""
//
//
//        guard let user = Auth.auth().currentUser else {return}
//        guard let userMail = user.email else {return}
//
//        let groupRef = Database.database().reference().child("groups").childByAutoId()
//
//        guard let uid = groupRef.key else {return}
//
//
//
//        let group = AppGroup(name: name, description: description, nickname: nickname, admin: userMail, uid: uid)
//        groupRef.setValue(group.convertToDictionary())
//        groupRef.child("groupusers").childByAutoId().setValue(["email" : userMail])
//
//        let myGroupRef = Database.database().reference().child("users").child(user.uid).child("groups").childByAutoId()
//        myGroupRef.setValue(["nickname":group.nickname])
//        self.navigationController?.popViewController(animated: true)
        
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
        
        let myGroupRef = Database.database().reference().child("users").child(user.uid).child("groups").childByAutoId()
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
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //DELETE GROUP
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

            
            //print("VDA ========")
            //print("count: \(self.groupUsers.count)")
        }
        //======
        
        
        
        
    }
    
    
    
}
