//
//  UserDefaultsHelper.swift
//
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2019 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

class UserDefaultsHelper: NSObject {
    
    static let shared = UserDefaultsHelper()
    
    private let PERSISTENT_USER_TOKEN_KEY = "userTokenKey"
    private let STAY_LOGGED_IN_KEY = "stayLoggedInKey"
    private let CURRENT_USER_KEY = "currentUserKey"
    
    private override init() { }
    
    func savePersistentUserToken(token: String) {
        let userDefaults = UserDefaults.standard
        let userToken: [String: String] = ["userToken": token]
        userDefaults.setValue(userToken, forKey: PERSISTENT_USER_TOKEN_KEY)
        userDefaults.synchronize()
    }
    
    func getPersistentUserToken() -> String? {
        let userDefaults = UserDefaults.standard
        if let userToken = userDefaults.value(forKey: PERSISTENT_USER_TOKEN_KEY),
            let token = (userToken as! [String: String])["userToken"] {
            return token
        }
        return nil
    }
    
    func removePersistentUser() {
        UserDefaults.standard.removeObject(forKey: PERSISTENT_USER_TOKEN_KEY)
    }
    
    func saveStayLoggedIn(stayLoggedIn: Bool) {
        let userDefaults = UserDefaults.standard
        let loggedIn: [String: NSNumber] = ["stayLoggedIn": NSNumber(booleanLiteral: stayLoggedIn)]
        userDefaults.setValue(loggedIn, forKey: STAY_LOGGED_IN_KEY)
        userDefaults.synchronize()
    }
    
    func getStayLoggedIn() -> Bool {
        let userDefaults = UserDefaults.standard
        if let loggedIn = userDefaults.value(forKey: STAY_LOGGED_IN_KEY),
            let stayLoggedIn = (loggedIn as! [String: NSNumber])["stayLoggedIn"] {
            return stayLoggedIn.boolValue
        }
        return false
    }
    
    func saveCurrentUser(currentUser: BackendlessUser) {
        let data = NSKeyedArchiver.archivedData(withRootObject: currentUser)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: CURRENT_USER_KEY)
        userDefaults.synchronize()
    }
    
    func getCurrentUser() -> BackendlessUser? {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.value(forKey: CURRENT_USER_KEY) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? BackendlessUser
        }
        return nil
    }
    
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: CURRENT_USER_KEY)
    }
}
