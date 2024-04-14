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
}
