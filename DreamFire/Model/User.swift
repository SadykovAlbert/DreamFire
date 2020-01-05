
import Foundation
import Firebase

struct AppUser {
    
    var name: String = ""
    var firstName: String = ""
    var password: String = ""
    let uid: String
    let email: String
    let ref: DatabaseReference?
    
    init(user: User, name: String, firstName: String , password: String) {
        self.name = name
        self.firstName = firstName
        self.password = password
        self.uid = user.uid
        self.email = user.email!
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        name = snapshotValue["name"] as! String
        firstName = snapshotValue["firstname"] as! String
        email = snapshotValue["email"] as! String
        password = snapshotValue["password"] as! String
        uid = snapshotValue["uid"] as! String
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["name": name, "firstname": firstName, "password": password, "uid": uid, "email": email]
    }
}
