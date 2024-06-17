//
//  PhotoCollectionViewCell.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 17.06.24.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoCollectionViewCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .label
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with image: UIImage?) {
        imageView.image = image
    }

    func configure(with url: URL?) {
        imageView.sd_setImage(with: url, completed: nil)
    }
}

