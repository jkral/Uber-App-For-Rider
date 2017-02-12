//
//  AuthProvider.swift
//  Uber App For Rider
//
//  Created by Jeff Kral on 12/14/16.
//  Copyright © 2016 Jeff Kral. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    
    static let INVALID_EMAIL = "Invalid email. Please provide valid email address"
    static let WRONG_PASSWORD = "Wrong password, please enter correct password"
    static let PROBLEM_CONNECTING = "Problem connecting to the database, please try later"
    static let USER_NOT_FOUND =  "Please register"
    static let EMAIL_ALREADY_IN_USE = "Email already in use, please use another email"
    static let WEAK_PASSWORD = "Password should be at least 6 characters long"
    
}

class AuthProvider {
    
    private static let _instance = AuthProvider()
    
    static var Instance : AuthProvider {
        return _instance
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
            
        })
    }  // login func
    
    func  signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        FIRAuth.auth()?.createUser(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                if user?.uid != nil {
                    
                    // store user in database
                    DBProvider.Instance.saveUser(withId: user!.uid, email: withEmail, password: password)
                    
                    // sign in user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                    
                }
            }
        })
    }
    
    // sign up func
    
    func logout() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                return true
            } catch  {
                return false
            }
            
        }
        
        return true
    }
    
    
    
    
            private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
                
                if let errCode = FIRAuthErrorCode(rawValue: err.code) {
                    
                    switch errCode {
                        
                    case .errorCodeWrongPassword:loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                        break
                        
                    case .errorCodeInvalidEmail:loginHandler?(LoginErrorCode.INVALID_EMAIL)
                        break
                        
                    case .errorCodeUserNotFound:loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                        break
                        
                    case .errorCodeEmailAlreadyInUse:loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                        break
                        
                    case .errorCodeWeakPassword:loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                        break
                        
                    default: loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                        break
                        
                    }
                }
            }
    
}
