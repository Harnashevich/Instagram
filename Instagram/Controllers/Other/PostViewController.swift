//
//  PostViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import UIKit

final class PostViewController: UIViewController {

    // MARK: - Variables
    
    private let post: Post
    private let owner: String
    
    // MARK: - Initialization
    
    init(
        post: Post,
        owner: String
    ) {
        self.owner = owner
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - Methods

extension PostViewController {
    
}
