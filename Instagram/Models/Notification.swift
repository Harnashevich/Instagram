//
//  Notification.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation

struct IGNotification: Codable {
    let identifer: String
    let notificationType: Int // 1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let username: String
    let dateString: String
    // Follow/Unfollow
    let isFollowing: Bool?
    // Like/Comment
    let postId: String?
    let postUrl: String?
} 
