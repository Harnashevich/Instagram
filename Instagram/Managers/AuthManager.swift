//
//  AuthManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation
import FirebaseAuth

/// Object to manage authentication
final class AuthManager {
    /// Shared instanece
    static let shared = AuthManager()
    
    /// Private constructor
    private init() {}
    
    /// Auth reference
    private let auth = Auth.auth()
    
    /// Determine if user is signed in
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    /// Attempt sign in
    /// - Parameters:
    ///   - email: Email of user
    ///   - password: Password of user
    ///   - completion: Callback
    public func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
    }
    
    /// Attempt new user sign up
    /// - Parameters:
    ///   - email: Email
    ///   - username: Username
    ///   - password: Password
    ///   - profilePicture: Optional profile picture data
    ///   - completion: Callback
    public func signUp(
        email: String,
        username: String,
        password: String,
        profilePicture: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
    }
    
    /// Attempt Sign Out
    /// - Parameter completion: Callback upon sign out
    public func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try auth.signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
