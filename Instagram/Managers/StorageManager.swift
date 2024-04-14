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
}
