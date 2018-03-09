//
//  BookmarkViewController.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 06/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit

class BookmarkViewController: UITableViewController, BookViewInput {
    var bookmarkPresenter: BookmarkPresenterType!
    var tweets: [TWTRTweet] = []
    
    lazy var noBookmarksLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var emptyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "hourglass")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookmarkPresenter.viewWillApear()
    }
    
    private func setupViews() {
        tableView.tableFooterView = UIView()
        let nib = UINib.init(nibName: "TweetCell", bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: TweetCell.reuseIdentifier)
    }

    func displayBookmarkTweets(_ tweets: [TWTRTweet]) {
        self.tweets = tweets
        tableView.reloadData()
    }
    
    func displayEmptyView(message: String) {
        noBookmarksLabel.text = message
        view.addSubview(emptyIcon)
        view.addSubview(noBookmarksLabel)
        
        NSLayoutConstraint.activate([
            emptyIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 175),
            emptyIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 64),
            emptyIcon.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        NSLayoutConstraint.activate([
            noBookmarksLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 15),
            noBookmarksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noBookmarksLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noBookmarksLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func hideEmptyView() {
        noBookmarksLabel.removeFromSuperview()
        emptyIcon.removeFromSuperview()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        cell.configure(with: tweets[indexPath.row])
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
