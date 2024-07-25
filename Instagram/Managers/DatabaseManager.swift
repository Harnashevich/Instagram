//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import Foundation
import FirebaseFirestore

/// Object to manage database interactions
final class DatabaseManager {
    /// Shared instance
    static let shared = DatabaseManager()
    
    /// Private constructor
    private init() {}
    
    /// Database referenec
    private let database = Firestore.firestore()
    
    /// Find users with prefix
    /// - Parameters:
    ///   - usernamePrefix: Query prefix
    ///   - completion: Result callback
    public func findUsers(
        with usernamePrefix: String,
        completion: @escaping ([User]) -> Void
    ) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })

            completion(subset)
        }
    }
    
    /// Find posts from a given user
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Result callback
    public func posts(
        for username: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
        ref.getDocuments { snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }).sorted(by: {
                return $0.date > $1.date
            }),
                  error == nil else {
                return
            }
            completion(.success(posts))
        }
    }
    
    /// Find single user with email
    /// - Parameters:
    ///   - email: Source email
    ///   - completion: Result callback
    public func findUser(
        with email: String,
        completion: @escaping (User?) -> Void
    ) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }

            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
    
    /// Find user with username
    /// - Parameters:
    ///   - username: Source username
    ///   - completion: Result callback
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }

            let user = users.first(where: { $0.username == username })
            completion(user)
        }
    }
    
    /// Create new post
    /// - Parameters:
    ///   - newPost: New Post model
    ///   - completion: Result callback
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    /// Create new user
    /// - Parameters:
    ///   - newUser: User model
    ///   - completion: Result callback
    public func createUser(
        newUser: User,
        completion: @escaping (Bool) -> Void
    ) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    /// Gets posts for explore page
    /// - Parameter completion: Result callback
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }

            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()

            users.forEach { user in
                group.enter()

                let username = user.username
                let postsRef = self.database.collection("users/\(username)/posts")

                postsRef.getDocuments { snapshot, error in

                    defer {
                        group.leave()
                    }

                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }),
                          error == nil else {
                        return
                    }

                    aggregatePosts.append(contentsOf: posts.compactMap({
                        (post: $0, user: user)
                    }))
                }
            }

            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    /// Get notifications for current user
    /// - Parameter completion: Result callback
    public func getNotifications(
        completion: @escaping ([IGNotification]) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                IGNotification(with: $0.data())
            }),
            error == nil else {
                completion([])
                return
            }

            completion(notifications)
        }
    }

    /// Creates new notification
    /// - Parameters:
    ///   - identifer: New notification ID
    ///   - data: Notification data
    ///   - username: target username
    public func insertNotification(
        identifer: String,
        data: [String: Any],
        for username: String
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifer)
        ref.setData(data)
    }
    
    /// Get a post with id and username
    /// - Parameters:
    ///   - identifer: Query id
    ///   - username: Query username
    ///   - completion: Result callback
    public func getPost(
        with identifer: String,
        from username: String,
        completion: @escaping (Post?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
            .document(identifer)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }

            completion(Post(with: data))
        }
    }
    
    /// Follow states that are supported
    enum RelationshipState {
        case follow
        case unfollow
    }

    /// Update relationship of follow for user
    /// - Parameters:
    ///   - state: State to update to
    ///   - targetUsername: Other user username
    ///   - completion: Result callback
    public func updateRelationship(
        state: RelationshipState,
        for targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("following")

        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")

        switch state {
        case .unfollow:
            // Remove follower for currentUser following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).delete()

            completion(true)
        case .follow:
            // Add follower for requester following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])

            completion(true)
        }
    }
    
    /// Get user counts for target usre
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Callback
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userRef = database.collection("users")
            .document(username)

        var followers = 0
        var following = 0
        var posts = 0

        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()

        userRef.collection("posts").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }

        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }

        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }

        group.notify(queue: .global()) {
            let result = (
                followers: followers,
                following: following,
                posts: posts
            )
            completion(result)
        }
    }
    
    /// Check if current user is following another
    /// - Parameters:
    ///   - targetUsername: Other user to check
    ///   - completion: Result callback
    public func isFollowing(
        targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let ref = database.collection("users")
            .document(targetUsername)
            .collection("followers")
            .document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // following
            completion(true)
        }
    }
    
    // MARK: - User Info

    /// Get user info
    /// - Parameters:
    ///   - username: username to query for
    ///   - completion: Result callback
    public func getUserInfo(
        username: String,
        completion: @escaping (UserInfo?) -> Void
    ) {
        let ref = database
            .collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    /// Set user info
    /// - Parameters:
    ///   - userInfo: UserInfo model
    ///   - completion: Callback
    public func setUserInfo(
        userInfo: UserInfo,
        completion: @escaping (Bool) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = userInfo.asDictionary() else {
            return
        }

        let ref = database
            .collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    /// Get followers for user
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Result callback
    public func followers(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database
            .collection("users")
            .document(username)
            .collection("followers")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    /// Get users that parameter username follows
    /// - Parameters:
    ///   - username: Query usernam
    ///   - completion: Result callback
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database
            .collection("users")
            .document(username)
            .collection("following")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    // MARK: - Comment

    /// Create a comment
    /// - Parameters:
    ///   - comment: Comment mmodel
    ///   - postID: post id
    ///   - owner: username who owns post
    ///   - completion: Result callback
    public func createComments(
        comment: Comment,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
            .document(newIdentifier)
        guard let data = comment.asDictionary() else { return }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }

    /// Get comments for given post
    /// - Parameters:
    ///   - postID: Post id to query
    ///   - owner: Username who owns post
    ///   - completion: Result callback
    public func getComments(
        postID: String,
        owner: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
        ref.getDocuments { snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }),
            error == nil else {
                completion([])
                return
            }

            completion(comments)
        }
    }

    // MARK: - Liking

    /// Like states that are supported
    enum LikeState {
        case like
        case unlike
    }

    /// Update like state on post
    /// - Parameters:
    ///   - state: State to update to
    ///   - postID: Post to update for
    ///   - owner: Owner username of post
    ///   - completion: Result callback
    public func updateLikeState(
        state: LikeState,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
        getPost(with: postID, from: owner) { post in
            guard var post = post else {
                completion(false)
                return
            }

            switch state {
            case .like:
                if !post.likers.contains(currentUsername) {
                    post.likers.append(currentUsername)
                }
            case .unlike:
                post.likers.removeAll(where: { $0 == currentUsername })
            }

            guard let data = post.asDictionary() else {
                completion(false)
                return
            }
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
