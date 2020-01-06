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
    
    
    let ref = Database.database().reference().child("users")
    
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
        
        var flag = false
        
        guard var textField = mailTextField.text, textField != "" else {return}
        self.mailTextField.text = ""
        let ref = Database.database().reference().child("users")
        
        ref.observe(.value) { (snapshot) in //===========
            let mas = snapshot.valueInExportFormat() as! [String:AnyObject]
            
            for (_,j) in mas{
                let mas2 = j as! [String:AnyObject]
                
                guard let email = mas2["email"] as? String else {return}
                if (textField == email){
                    textField = ""
                    flag = true
                    guard let uid = mas2["uid"] as? String else {return}
                    self.addToFriendFB(uid: uid)
                    
                    //
                    //self.dismiss(animated: true, completion: nil)
                    
                    self.navigationController?.popViewController(animated: true)
                    //
                                    }
                if (flag == true){break}
                
            }
            
        }//==================
        
        displayWarningLabel(withText: "No such user")

    }
    
    func addToFriendFB(uid: String){
        
        guard let user = Auth.auth().currentUser else {return}
        
        let friendRef = ref.child(uid)
        let ourRef = self.ref.child(user.uid).child("friends").childByAutoId()
        
        
        
        friendRef.observe(.value) { (snapshot) in
            let friendUser = AppUser(snapshot: snapshot)
            ourRef.setValue(friendUser.convertToDictionary())
        }
        //
        
        
        
        
        
        let ourRef1 = self.ref.child(user.uid)
        let friendRef1 = self.ref.child(uid).child("friends").childByAutoId()
        
        ourRef1.observe(.value) { (snapshot) in
            let ourUser = AppUser(snapshot: snapshot)
            friendRef1.setValue(ourUser.convertToDictionary())
        }
        
        
    }
    
    

}
