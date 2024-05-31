//
//  PostCollectionViewCell.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 31.05.24.
//

import SDWebImage
import UIKit

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int)
}

final class PostCollectionViewCell: UICollectionViewCell {
    static let identifer = "PostCollectionViewCell"

    weak var delegate: PostCollectionViewCellDelegate?

    private var index = 0

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let image = UIImage(
            systemName: "suit.heart.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50)
        )
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didDoubleTapToLike() {
        heartImageView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.heartImageView.alpha = 1
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.4) {
                    self.heartImageView.alpha = 0
                } completion: { done in
                    if done {
                        self.heartImageView.isHidden = true
                    }
                }
            }
        }

        delegate?.postCollectionViewCellDidLike(self, index: index)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(
            x: (contentView.width-size)/2,
            y: (contentView.height-size)/2,
            width: size,
            height: size)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with viewModel: PostCollectionViewCellViewModel, index: Int) {
        self.index = index
        imageView.sd_setImage(with: viewModel.postUrl)
    }
}

