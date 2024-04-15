//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation
import FirebaseFirestore

/// Object to manage database interactions
final class DatabaseManager {
    /// Shared instance
    static let shared = DatabaseManager()
    
    /// Private constructor
    private init() {}
    
    /// Database referenec
    private let database = Firestore.firestore()
    
    /// Find single user with email
    /// - Parameters:
    ///   - email: Source email
    ///   - completion: Result callback
    public func findUser(
        with email: String,
        completion: @escaping (User?) -> Void
    ) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }

            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
    
    /// Create new user
    /// - Parameters:
    ///   - newUser: User model
    ///   - completion: Result callback
    public func createUser(
        newUser: User,
        completion: @escaping (Bool) -> Void
    ) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
}
