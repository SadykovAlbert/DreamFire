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
    //var groupUid:String?
    var group:AppGroup?
    
    enum whichSegue {
        case addNewFriend
        case addNewUserToGroup
    }
    
    var segueChoise: whichSegue = .addNewUserToGroup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        warningLabel.alpha = 0
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
        //        getMails()
        //        guard var textField = mailTextField.text, textField != "" else {return}
        //        self.mailTextField.text = ""
        //        //let ref = Database.database().reference().child("users")
        //
        //        if textField == myMail{
        //            displayWarningLabel(withText: "You can not add yourself to Friends")
        //            return
        //        }
        //        for mail in mails{
        //            if textField == mail{
        //                displayWarningLabel(withText: "This user already your Friend")
        //                return
        //            }
        //        }
        //
        //        let demoRef1 = Database.database().reference().child("users")
        //        demoRef1
        //            .queryOrdered(byChild: "email")
        //            .queryEqual(toValue: textField)
        //            .observe(.value) { (dataSnapshot) in
        //
        //
        //
        //                let dict = dataSnapshot.value as! [String:AnyObject]
        //                var uid:String = ""
        //                var dict2: [String:AnyObject] = [:]
        //                for (i,j) in dict{
        //
        //                    uid = i
        //
        //                    guard let dicthelp = j as? [String:AnyObject] else {return}
        //                    dict2 = dicthelp
        //                }
        //                let mail = dict2["email"] as! String
        //                print("dict: \(dict2["email"]!)")
        //                print("uid: \(uid)")
        //                guard textField != "" else {return}
        //                self.addToFriendByMail(mail: mail, uid: uid)
        //                textField = ""
        //                self.navigationController?.popViewController(animated: true)
        //
        //
        //        }
        //
        //
        //
        //        /*----
        //                let myUid = uid.first//"DbhQcCI4PfPDkLTiErFVvoq2gbu2"
        //                print(dataSnapshot.childSnapshot(forPath: "\(myUid!)/friends").children.allObjects)
        //
        //                //demoRef.child(myUid).child("friends").removeValue()
        //
        //        }-----*/
        ////        demoRef.child("DbhQcCI4PfPDkLTiErFVvoq2gbu2").child("friends").removeValue()
        //
        //        displayWarningLabel(withText: "No such user")
        
    }
    
    func addToFriend(){
        
        getMails()
        guard var textField = mailTextField.text, textField != "" else {return}
        self.mailTextField.text = ""
        //let ref = Database.database().reference().child("users")
        
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
                print("dict: \(dict2["email"]!)")
                print("uid: \(uid)")
                guard textField != "" else {return}
                self.addToFriendByMail(mail: mail, uid: uid)
                textField = ""
                self.navigationController?.popViewController(animated: true)
                
                
        }
        
        
        
        /*----
         let myUid = uid.first//"DbhQcCI4PfPDkLTiErFVvoq2gbu2"
         print(dataSnapshot.childSnapshot(forPath: "\(myUid!)/friends").children.allObjects)
         
         //demoRef.child(myUid).child("friends").removeValue()
         
         }-----*/
        //        demoRef.child("DbhQcCI4PfPDkLTiErFVvoq2gbu2").child("friends").removeValue()
        
        displayWarningLabel(withText: "No such user")
        
    }
    func addToGroup(){
        
        guard let textField = mailTextField.text, textField != "" else {return}
        self.mailTextField.text = ""
        
        var friendsMails = [String]()
        var flag = false
        var userUid: String?
        
        for friend in friends {
            friendsMails.append(friend.email)
            if textField == friend.email{
                userUid = friend.uid
                flag = true
                break
            }
        }
        if flag == false{
            displayWarningLabel(withText: "You dont have such user in friends")
            return
        }
        
        var groupMails = [String]()
        
        guard let groupUid = group?.uid else {return}
        let groupRef = Database.database().reference().child("groups").child(groupUid).child("groupusers")
        groupRef.observe(.value) { (snapshot) in
            
            var _groupMails = [String]()
            //var userUid: String?
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    print("I hope it is user")
                    print(snap)
                    //
//                    let user = AppGroup(snapshot: snap)
//                    let mail = user.email
//                    userUid = user.uid
                    //
                    guard let dict = snap.value as? [String:AnyObject] else {return}
                    
                    guard let mail = dict["email"] as? String else {return}
                    //guard let _userUid = dict["uid"] as? String else {return}
                    //userUid = _userUid
                    
                    _groupMails.append(mail)
                    
                    
                }
                
            }
            print("groupMAils: \(_groupMails)")
            groupMails = _groupMails
            
            var flagExistedUser = false
            for mailG in groupMails{
                for mailF in friendsMails{
                    if mailF == mailG{
                        
                        flagExistedUser = true
                        break
                    }
                }
            }
            
            if flagExistedUser == true{
                self.displayWarningLabel(withText: "Such user already exist")
            }
            else{
                
                guard let uid = userUid else {return}
                guard let nickname = self.group?.nickname else {return}
                let userRef = Database.database().reference().child("users").child(uid).child("groups").childByAutoId()
                userRef.setValue(["nickname": nickname])
                
                
                let groupRef = Database.database().reference().child("groups").child(groupUid).child("groupusers").childByAutoId()
                groupRef.setValue(["email":textField,"uid":uid])
                
            }
            
            
        }//
        
        
        
        
        //найти usera по email
        //
        //        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //        let searchUserRef = Database.database().reference().child("users").child(myUid).child("friendsmail")
        //        searchUserRef
        //            .queryOrdered(byChild: "email")
        //            .queryEqual(toValue: textField)
        //            .observe(.value) { (snapshot) in
        //
        //
        //                //
        //                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
        //                    for snap in snapshots {
        //
        //
        //
        //
        //
        //                    }
        //                }
        //                //
        //
        //
        //        }
        //
        
        
        
        //        guard let uid = group?.uid else {return}
        //        let groupRef = Database.database().reference().child("groups").child(uid).child("groupusers")
        //        groupRef.observe(.value) { (snapshot) in
        //
        //            var flag = false
        //            var userUid = "ERRORUID"
        //            //
        //            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
        //                for snap in snapshots {
        //
        ////                    let user = AppUser(snapshot: snap)
        ////                    if user.email == textField{
        ////                        flag = true;
        ////                        userUid = user.uid
        //
        //                    guard let dict = snap.value as? [String:AnyObject] else {return}
        //
        //                    guard let mail = dict["email"] as? String else {return}
        //                    guard let uid = dict["uid"] as? String else {return}
        //                    if mail == textField{
        //                        flag = true;
        //                        userUid = uid
        //                    }
        //
        //                }
        //            }
        //            //
        //            if flag == true{
        //                self.displayWarningLabel(withText: "Such User already exist")
        //            }else{
        //
        //                let addToGroupRef = Database.database().reference()
        //                    .child("groups").child(uid).child("groupusers").childByAutoId()
        //                addToGroupRef.setValue(["email":textField, "uid":userUid])
        //
        //                let userRef = Database.database().reference()
        //                    .child("users").child(userUid).child("groups").childByAutoId()
        //                guard let nick = self.group?.nickname else {return}
        //                userRef.setValue(["nickname": nick])
        //
        //            }
        //
        //        }
        
    }
    
    
    func addToFriendByMail(mail:String, uid:String){
        guard let user = Auth.auth().currentUser else {return}
        
        let ref1 = Database.database().reference().child("users")
        let ref2 = Database.database().reference().child("users")
        
        
        ref1.child(user.uid).child("friendsmail").childByAutoId().setValue(["email":mail])
        ref2.child(uid).child("friendsmail").childByAutoId().setValue(["email":user.email])
        
    }
    
    func addToFriendFB(uid: String){
        
        guard let user = Auth.auth().currentUser else {return}
        
        
        let friendRef = ref.child(uid)
        let ourRef = self.ref.child(user.uid).child("friends").childByAutoId()
        
        friendRef.observe(.value) { (snapshot) in
            let friendUser = AppUser(snapshot: snapshot)
            ourRef.setValue(friendUser.convertToDictionary())
        }
        
        
        let ourRef1 = self.ref.child(user.uid)
        let friendRef1 = self.ref.child(uid).child("friends").childByAutoId()
        
        ourRef1.observe(.value) { (snapshot) in
            let ourUser = AppUser(snapshot: snapshot)
            friendRef1.setValue(ourUser.convertToDictionary())
        }
        
    }
    
    func getMails(){
        for friend in friends{
            let mail = friend.email
            mails.append(mail)
        }
    }
    
    
}
