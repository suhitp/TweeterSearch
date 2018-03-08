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
        tweetTableView.estimatedRowHeight = 100
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.tableFooterView = footerView
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
        tweetTableView.beginUpdates()
        tweetTableView.insertRows(at: indexPaths, with: .fade)
        tweetTableView.endUpdates()
    }
    
    func showError(_ error: NetworkError) {
        switch error {
        case .noInternet: break
        case .failure(_): break
        case .timeout: break
        }
    }
    
    @IBAction func didTapFilterButton(_ sender: UIBarButtonItem) {
       // tweetsPresenter.didTapFilterButton()
    }
    
    func showFilterOptions(_ options: String) {
        
    }
    
    func updateLoadMoreState(_ state: LoadMoreState) {
        loadMoreState = state
    }
    
    //MARK:- HideFooter
    func hideFooter() {
        tweetTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.reuseIdentifier, for: indexPath) as! TweetTableViewCell
        cell.configure(with: tweets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard loadMoreState != .loading || loadMoreState == .finished else {
            return
        }
        if (tweets.count - 1 == indexPath.row) && tweetsPresenter.shouldLoadMoreTweets() {
            tweetsPresenter.loadMoreTweets()
            footerView.startAnimating()
        }
    }
}
