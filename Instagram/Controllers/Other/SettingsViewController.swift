//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 15.04.24.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
