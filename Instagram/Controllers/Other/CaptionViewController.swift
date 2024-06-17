//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import UIKit

final class CaptionViewController: UIViewController {
    
    // MARK: - UI
    
    private let imageVIew: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Add caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 22)
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return textView
    }()
    
    // MARK: - Variables
    
    private let image: UIImage
    
    // MARK: - Initialization
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageVIew)
        imageVIew.image = image
        view.addSubview(textView)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/4
        imageVIew.frame = CGRect(
            x: (view.width-size)/2,
            y: view.safeAreaInsets.top + 10,
            width: size,
            height: size
        )
        textView.frame = CGRect(
            x: 20,
            y: imageVIew.bottom+20,
            width: view.width-40,
            height: 100
        )
    }
}

// MARK: - Methods

extension CaptionViewController {
    
    @objc
    private func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == "Add caption..." {
            caption = ""
        }
    }
}

// MARK: - UITextViewDelegate

extension CaptionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add caption..." {
            textView.text = nil
        }
    }
}
