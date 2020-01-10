//
//  AddFriendViewController.swift
//  DreamFire
//
//  Created by Albert on 06/01/2020.
//  Copyright © 2020 Albert. All rights reserved.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    var friends = [AppUser]()
    var mails = [String]()
    let ref = Database.database().reference().child("users")
    let myMail = Auth.auth().currentUser?.email
    
    var group:AppGroup?
    
    enum whichSegue {
        case addNewFriend
        case addNewUserToGroup
    }
    
    var segueChoise: whichSegue = .addNewUserToGroup
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMailsAndFriends()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.alpha = 0
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func displayWarningLabel(withText text: String) {
        warningLabel.text = text
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.warningLabel.alpha = 1
        }) { [weak self] complete in
            self?.warningLabel.alpha = 0
        }
    }
    
    @IBAction func findButtonPressed(_ sender: UIButton) {
        
        switch segueChoise {
        case .addNewFriend:
            addToFriend()
        case .addNewUserToGroup:
            addToGroup()
        }
        
    }
    
    func addToFriend(){
        
        guard var textField = mailTextField.text, textField != "" else {return}
        self.mailTextField.text = ""
        
        
        if textField == myMail{
            displayWarningLabel(withText: "You can not add yourself to Friends")
            return
        }
        for mail in mails{
            if textField == mail{
                displayWarningLabel(withText: "This user already your Friend")
                return
            }
        }
        
        let demoRef1 = Database.database().reference().child("users")
        demoRef1
            .queryOrdered(byChild: "email")
            .queryEqual(toValue: textField)
            .observe(.value) { (dataSnapshot) in
                
                
                
                let dict = dataSnapshot.value as! [String:AnyObject]
                var uid:String = ""
                var dict2: [String:AnyObject] = [:]
                for (i,j) in dict{
                    
                    uid = i
                    
                    guard let dicthelp = j as? [String:AnyObject] else {return}
                    dict2 = dicthelp
                }
                let mail = dict2["email"] as! String
                
                guard textField != "" else {return}
                self.addToFriendByMail(mail: mail, uid: uid)
                textField = ""
                self.navigationController?.popViewController(animated: true)
                
                
        }
        
        
        
        
        displayWarningLabel(withText: "No such user")
        
    }
    func addToGroup(){
        
        print("HEY func addToGroup")
        print("===================")
        guard var textField = mailTextField.text, textField != "" else {return}
        self.mailTextField.text = ""
        
        var friendsMails = [String]()
        var flag = false
        var userUid: String?
        
        
        //проверка есть ли такой юзер в друзьях
        for friend in friends {
            friendsMails.append(friend.email)
            if textField == friend.email{
                userUid = friend.uid
                flag = true // да , есть
                break
            }
        }
        if flag == false{
            displayWarningLabel(withText: "You dont have such user in friends")//такого нет
            return
        }
        // если здесь то есть
        var groupMails = [String]()
        
        guard let groupUid = group?.uid else {return}
        print("HELLOoooooooooo=========")
        let groupRef = Database.database().reference().child("groups").child(groupUid).child("groupusers")
        groupRef.observe(.value) { (snapshot) in// есть ли такой человек (мой друг) в группе?
            
            var _groupMails = [String]()
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    guard let dict = snap.value as? [String:AnyObject] else {return}
                    
                    guard let mail = dict["email"] as? String else {return}
                    
                    _groupMails.append(mail)
                    
                }
            }
            
            groupMails = _groupMails// сформирован массив майлов участников группы
            
            var flagExistedUser = false
            
            for mailG in groupMails{//======
                
                if mailG == textField{
                    flagExistedUser = true
                }
            }
            print("flagExistedUser: \(flagExistedUser)")
            if flagExistedUser == true{
                self.displayWarningLabel(withText: "Such user already exist")
                return
            }
            else{
                
                guard textField != "" else {print("ERROR TF PID");return}
                guard let uid = userUid else {print("ERROR uid = userUid");return}
                guard let nickname = self.group?.nickname else {print("nickname = self.group?.nickname");return}
                let userRef = Database.database().reference().child("users").child(uid).child("groups").child(groupUid)
                userRef.setValue(["nickname": nickname])
                
                print("HELLO CREATE place for user")
                let groupRef = Database.database().reference().child("groups").child(groupUid).child("groupusers").childByAutoId()
                groupRef.setValue(["email":textField,"uid":uid])
                textField = ""
                self.navigationController?.popViewController(animated: true)
            }
        }//
        
    }
    
    
    func addToFriendByMail(mail:String, uid:String){
        guard let user = Auth.auth().currentUser else {return}
        
        let ref1 = Database.database().reference().child("users")
        let ref2 = Database.database().reference().child("users")
        
        
        ref1.child(user.uid).child("friendsmail").childByAutoId().setValue(["email":mail])
        ref2.child(uid).child("friendsmail").childByAutoId().setValue(["email":user.email])
        
    }
    
    
    
    func getMailsAndFriends(){
        
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        let friendsMailRef = Database.database().reference().child("users").child(userUid).child("friendsmail")
        
        
        friendsMailRef.observe(.value) { (snapshot) in
            
            var _mails = [String]()
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    guard let dict = snap.value as? [String:AnyObject] else {return}
                    guard let mail = dict["email"] as? String else {return}
                    
                    _mails.append(mail)
                    
                }
                
                
            }
            
            self.mails = _mails
            
        }
        
        
        let friendsRef = Database.database().reference().child("users")
        
        
        friendsRef.observe(.value) { (snapshot) in
            
            var _friends = [AppUser]()
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    let user = AppUser(snapshot: snap)
                    for mail in self.mails{
                        if mail == user.email{
                            _friends.append(user)
                            
                        }
                        
                    }
                    
                }
                
            }
            self.friends = _friends
            
        }
    }
    
}
