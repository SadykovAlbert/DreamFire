
import UIKit
import Firebase

class FriendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let ref = Database.database().reference().child("users")
    var friends = [AppUser]()
    var mails = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let name = friends[indexPath.row].name
        let lastName = friends[indexPath.row].lastName
        cell.nameLabel.text = name
        cell.lastNameLabel.text = lastName
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        friends = []
        mails = []
        guard let user = Auth.auth().currentUser else {return}
        
        //===
        ref.child(user.uid).child("friendsmail").observe(.value) { (snapshot) in
            
            var _mails:[String] = []
            
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    guard let hDict = snap.value as? [String:String] else {return}
                    guard let mail = [String](hDict.values).first else {return}

                    
                    _mails.append(mail)
                    
                }
            }
            self.mails = _mails
           
        }
        //==

        //=========================
        let fbRef = Database.database().reference().child("users")
        fbRef.observe(.value) { (snapshot) in
            
            
                        var _friends:[AppUser] = []
            
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots {
            
                                //print("SNAP-----: \(snap)")
                                let user = AppUser(snapshot: snap)
                                for mail in self.mails{
                                    if user.email == mail{
                                        _friends.append(user)
                                    }
                                }
                                
                            }
                        }
                        self.friends = _friends
                        self.tableView.reloadData()
            
        }
        
        
        //=========================
        
    }
    
    
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return}
            let vc = segue.destination as! ProfileViewController
            let friend = friends[indexPath.row]
            vc.friend = friend
            vc.segueChoise = .friend
            
        }
        else if segue.identifier == "newFriendSegue"{
            let vc = segue.destination as! AddFriendViewController
            vc.friends = friends
            vc.segueChoise = .addNewFriend
        }
    
    }
    
    

}
