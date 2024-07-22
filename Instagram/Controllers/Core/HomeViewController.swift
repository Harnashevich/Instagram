//
//  HomeViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - UI
    
    /// CollectionView for feed
    private var collectionView: UICollectionView?
    
    // MARK: - Variables

    /// Feed viewModels
    private var viewModels = [[HomeFeedCellType]]()

    /// Notification observer
    private var observer: NSObjectProtocol?

    /// All post models
    private var allPosts: [(post: Post, owner: String)] = []
    
    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .yellow,
        .systemPink,
        .orange
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        configureCollectionView()
        fetchPosts()
        
        observer = NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchPosts()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
}

// MARK: - Methods

extension HomeViewController {
    
}


// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    private func fetchPosts() {
        // mock data
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let userGroup = DispatchGroup()
        userGroup.enter()

        var allPosts: [(post: Post, owner: String)] = []

        DatabaseManager.shared.following(for: username) { usernames in
            defer {
                userGroup.leave()
            }
            let users = usernames + [username]
            
            for current in users {
                userGroup.enter()
                DatabaseManager.shared.posts(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }

                        switch result {
                        case .success(let posts):
                            allPosts.append(contentsOf: posts.compactMap({
                                (post: $0, owner: current)
                            }))
                        case .failure:
                            break
                        }
                    }
                }
            }
        }

        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allPosts = allPosts
            allPosts.forEach { model in
                group.enter()
                self.createViewModel(
                    model: model.post,
                    userName: model.owner,
                    completion: { success in
                        defer {
                            group.leave()
                        }
                        if !success {
                            print("failed to create VM")
                        }
                    }
                )
            }

            group.notify(queue: .main) {
                self.sortData()
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func sortData() {
        allPosts = allPosts.sorted(by: { first, second in
            let date1 = first.post.date
            let date2 = second.post.date
            return date1 > date2
        })

        viewModels = viewModels.sorted(by: { first, second in
            var date1: Date?
            var date2: Date?
            first.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date1 = vm.date
                default:
                    break
                }
            }
            second.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date2 = vm.date
                default:
                    break
                }
            }

            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            }

            return false
        })

    }
    
    private func createViewModel(
        model: Post,
        userName: String,
        completion: @escaping (Bool) -> Void
    ) {
        StorageManager.shared.profilePictureURL(for: userName) { [weak self] profilePictureURL in
            guard let postURL = URL(string: model.postUrlString),
                  let profilePictureURL else {
                return
            }
            
            let postData: [HomeFeedCellType] = [
                .poster(
                    viewModel: PosterCollectionViewCellViewModel(
                        username: userName,
                        profilePictureURL: profilePictureURL
                    )
                ),
                .post(
                    viewModel: PostCollectionViewCellViewModel(
                        postUrl: postURL
                    )
                ),
                .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false)),
                .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: [])),
                .caption(viewModel: PostCaptionCollectionViewCellViewModel(
                    username: userName,
                    caption: model.caption
                )),
                .timestamp(
                    viewModel: PostDatetimeCollectionViewCellViewModel(
                        date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
                    )
                )
            ]
            self?.viewModels.append(postData)
            completion(true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType {
            
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifer,
                for: indexPath
            ) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifer,
                for: indexPath
            ) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .actions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifer,
                for: indexPath
            ) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifer,
                for: indexPath
            ) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifer,
                for: indexPath
            ) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .timestamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifer,
                for: indexPath
            ) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
    
}

// MARK: - PosterCollectionViewCellDelegate

extension HomeViewController: PosterCollectionViewCellDelegate {
    
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let sheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self]  _ in
            DispatchQueue.main.async {
//                let cellType = self?.viewModels[index]
//                switch cellType {
//                case .post(let viewModel):
//                    let vc = UIActivityViewController(
//                        activityItems: ["Check out this cool post!", viewModel.postUrl],
//                        applicationActivities: []
//                    )
//                    self?.present(vc, animated: true)
//
//                default:
//                    break
//                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive))
        present(sheet, animated: true)
    }
    
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int) {
        let vc = ProfileViewController(user: User(username: "west", email: "west@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PostCollectionViewCellDelegate

extension HomeViewController: PostCollectionViewCellDelegate {
    
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        print("did tap to like")
    }
}

// MARK: - PostActionsCollectionViewCellDelegate

extension HomeViewController: PostActionsCollectionViewCellDelegate {
    
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        // call DB to like state
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
//        let vc = PostViewController()
//        vc.title = "Post"
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        let section = viewModels[index]
        section.forEach { cellType in
            switch cellType {
            case .post(let viewModel):
                let vc = UIActivityViewController(
                    activityItems: ["Check out this cool post!", viewModel.postUrl],
                    applicationActivities: []
                )
                present(vc, animated: true)
            default:
                break
            }
        }
    }
}

// MARK: - PostLikesCollectionViewCellDelegate

extension HomeViewController: PostLikesCollectionViewCellDelegate {
    
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
//        HapticManager.shared.vibrateForSelection()
//        let vc = ListViewController(type: .likers(usernames: allPosts[index].post.likers))
//        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PostCaptionCollectionViewCellDelegate

extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell) {
       print("tapped caption")
    }
}



// MARK: - CollectionView

extension HomeViewController {
    
    func configureCollectionView() {
        let sectionHeight: CGFloat = 240 + view.width
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ ->
                NSCollectionLayoutSection? in
                
                // Item
                
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                
                let postItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                
                let actionsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                let likeCountItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                let captionItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                
                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                // Group
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)),
                    subitems: [
                        posterItem,
                        postItem,
                        actionsItem,
                        likeCountItem,
                        captionItem,
                        timestampItem
                    ]
                )
                
                // Section
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                return section
            })
        )
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            PosterCollectionViewCell.self,
            forCellWithReuseIdentifier: PosterCollectionViewCell.identifer
        )
        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifer
        )
        collectionView.register(
            PostActionsCollectionViewCell.self,
            forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifer
        )
        collectionView.register(
            PostLikesCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifer
        )
        collectionView.register(
            PostCaptionCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifer
        )
        collectionView.register(
            PostDateTimeCollectionViewCell.self,
            forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifer
        )
        
        self.collectionView = collectionView
    }
}
