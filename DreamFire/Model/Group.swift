//
//  Group.swift
//  DreamFire
//
//  Created by Albert on 08/01/2020.
//  Copyright © 2020 Albert. All rights reserved.
//


import Foundation
import Firebase

struct AppGroup {
    
    var name: String = ""
    var description: String = ""
    var nickname: String = ""
    var admin: String = ""
    var uid: String = ""
    let ref: DatabaseReference?
    
    init(name: String, description: String , nickname: String, admin: String, uid: String) {
        self.name = name
        self.description = description
        self.nickname = nickname
        self.admin = admin
        self.uid = uid
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        name = snapshotValue["name"] as! String
        description = snapshotValue["description"] as! String
        nickname = snapshotValue["nickname"] as! String
        admin = snapshotValue["admin"] as! String
        uid = snapshotValue["uid"] as! String
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["name": name, "description": description, "nickname": nickname, "admin": admin, "uid": uid]
    }
}
