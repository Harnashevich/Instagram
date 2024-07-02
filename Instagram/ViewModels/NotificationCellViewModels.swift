//
//  NotificationCellViewModels.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 1.07.24.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
    let date: String
}

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
    let date: String
}

struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
    let date: String
}
