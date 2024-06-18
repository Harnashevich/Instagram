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
    
    /// Upload post image
    /// - Parameters:
    ///   - data: Image data
    ///   - id: New post id
    ///   - completion: Result callback
    public func uploadPost(
        data: Data?,
        id: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            completion(nil)
            return
        }
        
        storage.child(ref).downloadURL { url, _ in
            completion(url)
        }
    }
    
    public func profilePictureURL(for username: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(username)/profile_picture.png").downloadURL { url, _ in
            completion(url)
        }
    }
    
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
