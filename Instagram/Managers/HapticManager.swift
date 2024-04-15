//
//  HapticManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 15.04.24.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

