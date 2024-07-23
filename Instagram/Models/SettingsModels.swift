//
//  SettingsModels.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 23.07.24.
//

import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOption]
}

struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}

