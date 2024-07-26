//
//  StoriesViewModel.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 26.07.24.
//

import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}

