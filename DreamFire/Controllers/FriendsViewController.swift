
import UIKit
import Firebase

class FriendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    let ref = Database.database().reference().child("users")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let name = friends[indexPath.row].name
        cell.nameLabel.text = name
        return cell
    }
    

    var friends = [AppUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("###################")
        
        friends = []
        guard let user = Auth.auth().currentUser else {return}
        
        ref.child(user.uid).child("friends").observe(.value) { (snapshot) in
            print("print")
            var _friends:[AppUser] = []

            print(snapshot.children)
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    print("print2")
                    print(snap)
                    let user = AppUser(snapshot: snap)
                    _friends.append(user)
                }
            }
            self.friends = _friends
            self.tableView.reloadData()
        }
        
        
        print("====================")
    }
    
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return}
            let vc = segue.destination as! ProfileViewController
            let friend = friends[indexPath.row]
            vc.friend = friend
            vc.segueChoise = .friend
        }
    }
    

    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var flag = false
        
        guard var textField = textField.text, textField != "" else {return}
        self.textField.text = ""
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
                        
                    }
                    if (flag == true){break}
                    
                }
                
            }//==================
        
        
        
       
       
        
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
