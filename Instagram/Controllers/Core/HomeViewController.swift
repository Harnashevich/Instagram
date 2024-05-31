//
//  HomeViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()
    
    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .yellow,
        .systemPink,
        .orange
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        configureCollectionView()
        fetchPosts()
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
        let postData: [HomeFeedCellType] = [
            .poster(
                viewModel: PosterCollectionViewCellViewModel(
                    username: "iosAcademy",
                    profilePictureURL: URL(string: "https://iosacademy.io/assets/images/brand/icon.jpg")!
                )
            ),
            .post(
                viewModel: PostCollectionViewCellViewModel(
                    postUrl: URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png")!
                )
            ),
            .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true)),
            .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: ["kanyewest"])),
            .caption(viewModel: PostCaptionCollectionViewCellViewModel(username: "iosacademu", caption: "first post")),
            .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(date: Date()))
        ]
        viewModels.append(postData)
        collectionView?.reloadData()
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
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default))
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
        let vc = PostViewController()
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        let vc = UIActivityViewController(
            activityItems: ["Sharing from Instagram"],
            applicationActivities: []
        )
        present(vc, animated: true)
    }
}

// MARK: - PostLikesCollectionViewCellDelegate

extension HomeViewController: PostLikesCollectionViewCellDelegate {
    
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        let vc = ListViewController()
        vc.title = "Liked By"
        navigationController?.pushViewController(vc, animated: true)
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
