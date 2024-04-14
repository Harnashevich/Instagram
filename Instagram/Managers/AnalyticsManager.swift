//
//  AnalyticsManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    enum FeedInteraction: String {
        case like
        case comment
        case share
        case reported
        case doubleTapToLike
    }

    func logFeedInteraction(_ type: FeedInteraction) {
        Analytics.logEvent(
            "feedback_interaction",
            parameters: [
                "type":type.rawValue.lowercased()
            ]
        )
    }
}

