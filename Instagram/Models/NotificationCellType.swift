//
//  NotificationCellType.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 1.07.24.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}

