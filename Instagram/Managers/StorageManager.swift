//
//  StorageManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation
import FirebaseStorage
import FirebaseStorage

/// Object to interface with firebase storage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(
        username: String,
        data: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let data = data else {
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
}
