
import Foundation
import Firebase

struct AppUser {
    
    var name: String = ""
    var lastName: String = ""
    var password: String = ""
    let uid: String
    let email: String
    let ref: DatabaseReference?
    
    init(user: User, name: String, lastName: String , password: String) {
        self.name = name
        self.lastName = lastName
        self.password = password
        self.uid = user.uid
        self.email = user.email!
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        name = snapshotValue["name"] as! String
        lastName = snapshotValue["lastname"] as! String
        email = snapshotValue["email"] as! String
        password = snapshotValue["password"] as! String
        uid = snapshotValue["uid"] as! String
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["name": name, "lastname": lastName, "password": password, "uid": uid, "email": email]
    }
}
