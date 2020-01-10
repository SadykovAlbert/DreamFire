

import UIKit
import Firebase

class GroupViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference().child("users")
    let fbRef = Database.database().reference().child("groups")

    var groups = [AppGroup]()
    var nicknames = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath) as! CustomTableViewCell
        
        let name = groups[indexPath.row].name
        let nickname = groups[indexPath.row].nickname
        cell.nameLabel.text = name
        cell.lastNameLabel.text = nickname
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayListOfGroups()
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        
    }
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createGroupSegue" {
            guard let dvc = segue.destination as? NewGroupViewController else {return}
            dvc.segueChoise = .registrationGroup
        }
        else if segue.identifier == "showDetailGroup" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return}
            guard let dvc = segue.destination as? NewGroupViewController else {return}
            let group = groups[indexPath.row]
            dvc.groupUid = group.uid
            dvc.group = group
            dvc.segueChoise = .profileGroup
            

        }
    }
    

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "createGroupSegue", sender: nil)
    }
    
    func displayListOfGroups(){
        //
        
        
        groups = []
        nicknames = []
        guard let user = Auth.auth().currentUser else {return}
        
        
        
        //===
        ref.child(user.uid).child("groups").observe(.value) { (snapshot) in
            
            var _nicknames:[String] = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    guard let hDict = snap.value as? [String:AnyObject] else {return}
                    guard let nickname = hDict["nickname"] as? String else {return}
                  
                    _nicknames.append(nickname)
                  
                }
            }
            self.nicknames = _nicknames
          
        }
        
        fbRef.observe(.value) { (snapshot) in
            
            var _groups:[AppGroup] = []
            
            //print("BEGIN")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
              
                    
                    guard let _ = snap.value as? [String:AnyObject] else {return}

                    
                    let group = AppGroup(snapshot: snap)
                    for nickname in self.nicknames{
                        
                        if group.nickname == nickname{
                            
                            _groups.append(group)
                        }
                    }
                    
                }
            }
            self.groups = _groups
            self.tableView.reloadData()
            
            
        }
        
        
        //
    }

}
