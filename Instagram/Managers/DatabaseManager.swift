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
    
    /// Find posts from a given user
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Result callback
    public func posts(
        for username: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
        ref.getDocuments { snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }).sorted(by: {
                return $0.date > $1.date
            }),
                  error == nil else {
                return
            }
            completion(.success(posts))
        }
    }
    
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
    
    /// Create new post
    /// - Parameters:
    ///   - newPost: New Post model
    ///   - completion: Result callback
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
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
