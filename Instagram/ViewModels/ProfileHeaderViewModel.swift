//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 8.07.24.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePictureUrl: URL?
    let followerCount: Int
    let followingICount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let name: String?
    let bio: String?
}
