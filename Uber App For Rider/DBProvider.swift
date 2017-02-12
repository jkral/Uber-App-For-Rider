//
//  DBProvider.swift
//  Uber App For Rider
//
//  Created by Jeff Kral on 12/16/16.
//  Copyright © 2016 Jeff Kral. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider()
    
    static var Instance : DBProvider {
        return _instance
    }
    
    var dbRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var ridersRef: FIRDatabaseReference {
        return dbRef.child(Constants.RIDERS)
    }
    
    var requestRef: FIRDatabaseReference {
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedRef: FIRDatabaseReference {        
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    func saveUser(withId: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRider: true];
        
        ridersRef.child(withId).child(Constants.DATA).setValue(data)
    }
    
}
