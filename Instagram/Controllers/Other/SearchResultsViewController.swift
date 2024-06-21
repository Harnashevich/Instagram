//
//  SearchResultsViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 21.06.24.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User)
}

final class SearchResultsViewController: UIViewController {
    
    // MARK: - UI
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        return tableView
    }()
    
    // MARK: - Variables
    
    private var users = [User]()
    
    public weak var delegate: SearchResultsViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - Methods

extension SearchResultsViewController  {
    
    public func update(with results: [User]) {
        self.users = results
        tableView.reloadData()
        tableView.isHidden = users.isEmpty
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewController(self, didSelectResultWith: users[indexPath.row])
    }
}
