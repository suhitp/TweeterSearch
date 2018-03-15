//
//  ViewController.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 06/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit

class TweetsViewController: UIViewController, TweetViewInput {
    
    @IBOutlet weak var tweetTableView: UITableView!
    @IBOutlet weak var filterTweetButton: UIBarButtonItem!
    lazy var footerView = FooterView()
    var tweetsPresenter: TweetsPresenterType!
    var tweets: [TWTRTweet] = []
    var loadMoreState: LoadMoreState = .none
    
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndictor = UIActivityIndicatorView()
        activityIndictor.translatesAutoresizingMaskIntoConstraints = false
        activityIndictor.activityIndicatorViewStyle = .gray
        activityIndictor.hidesWhenStopped = true
        activityIndictor.startAnimating()
        return activityIndictor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        loadTweets()
    }

    private func setupViews() {
        title = "Tweets"
        filterTweetButton.isEnabled = false
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 143
        tweetTableView.tableFooterView = footerView
        let nib = UINib.init(nibName: "TweetCell", bundle: Bundle.main)
        tweetTableView.register(nib, forCellReuseIdentifier: TweetCell.reuseIdentifier)
    }
    
    func showLoader() {
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.startAnimating()
    }
    
    func hideLoader() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    private func loadTweets() {
        tweetsPresenter.loadTweets()
    }
    
    func displayTweets(_ tweets: [TWTRTweet]) {
        self.tweets = tweets
        filterTweetButton.isEnabled = true
        tweetTableView.reloadData()
    }
    
    func insert(_ tweets: [TWTRTweet], at indexPaths: [IndexPath]) {
        self.tweets += tweets
        if #available(iOS 11, *) {
            tweetTableView.performBatchUpdates({
                tweetTableView.insertRows(at: indexPaths, with: .none)
            }, completion: nil)
        } else {
            tweetTableView.beginUpdates()
            tweetTableView.insertRows(at: indexPaths, with: .none)
            tweetTableView.endUpdates()
        }
    }
    
    func showError(_ error: NetworkError) {
        switch error {
        case .failure(let message):
            let errorViewController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let retryAction = UIAlertAction.init(title: "Retry", style: .default, handler: { [unowned self] _ in
                self.loadTweets()
            })
            errorViewController.addAction(retryAction)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            errorViewController.addAction(cancelAction)
            present(errorViewController, animated: true, completion: nil)
        case .loadMoreError:
            let errorViewController = UIAlertController(title: "Error", message: "Failed to load more tweets", preferredStyle: .alert)
            let retryAction = UIAlertAction.init(title: "Retry", style: .default, handler: { [unowned self] _ in
                self.tweetsPresenter.loadMoreTweets()
            })
            errorViewController.addAction(retryAction)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            errorViewController.addAction(cancelAction)
            present(errorViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapFilterButton(_ sender: UIBarButtonItem) {
        guard loadMoreState != .loading else { return }
        tweetsPresenter.configureFilterOptions()
    }
    
    func updateLoadMoreState(_ state: LoadMoreState) {
        loadMoreState = state
    }
    
    func showFooter() {
        tweetTableView.tableFooterView = footerView
    }
    
    func hideFooter() {
        tweetTableView.tableFooterView = nil
    }
    
    //MARK: ShowFilterActions
    func showFilterOptions(_ options: [TweetFilterAction]) {
        let actionSheet = UIAlertController(title: "Filter Tweets by", message: nil, preferredStyle: .actionSheet)
        for action in options {
            let actionItem = UIAlertAction(title: action.rawValue, style: .default, handler: { [weak self] _ in
                self?.tweetsPresenter.filterTweets(by: action)
            })
            actionSheet.addAction(actionItem)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showBookmarkActionSheet(title: String, forTweet tweet: TWTRTweet) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let bookmarkAction = UIAlertAction(title: title, style: .default, handler: { [unowned self] _ in
            self.tweetsPresenter.bookmark(tweet: tweet)
        })
        actionSheet.addAction(bookmarkAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.reuseIdentifier, for: indexPath) as! TweetCell
        cell.configure(with: tweets[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard loadMoreState == .none || loadMoreState == .ready else {
            return
        }
        if (tweets.count - 1 == indexPath.row) && tweetsPresenter.shouldLoadMoreTweets() {
            tweetsPresenter.loadMoreTweets()
            footerView.startAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollToTop() {
        tweetTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
}

extension TweetsViewController: BookmarkTweetEventDelegate {
    func didTapBookmarkTweetWith(tweetId : String) {
        self.tweetsPresenter.didTapBookmarkButtonWith(tweetId: tweetId)
    }
}
