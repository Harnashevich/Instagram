//
//  PostCaptionCollectionViewCell.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 31.05.24.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell)
}

final class PostCaptionCollectionViewCell: UICollectionViewCell {
    static let identifer = "PostCaptionCollectionViewCell"

    weak var delegate: PostCaptionCollectionViewCellDelegate?

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapCaption))
        label.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didTapCaption() {
        delegate?.postCaptionCollectionViewCellDidTapCaptioon(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(
            CGSize(
                width: contentView.bounds.size.width-12,
                height: contentView.bounds.size.height
            )
        )
        label.frame = CGRect(x: 12, y: 3, width: size.width, height: size.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {
        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
    }
}

