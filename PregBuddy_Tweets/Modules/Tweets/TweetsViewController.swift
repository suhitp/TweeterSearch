//
//  ViewController.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 06/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit

class TweetsViewController: UIViewController {
   
    @IBOutlet weak var tweetTableView: UITableView!
    var tweets = [TWTRTweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        themeViews()
        loadTweets()
    }

    private func setupViews() {
        title = "Tweets"
        navigationController?.navigationBar.tintColor = .black
        tweetTableView.tableFooterView = UIView()
        tweetTableView.estimatedRowHeight = 100
        tweetTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func themeViews() {
        self.view.backgroundColor = .white
        self.tweetTableView.backgroundColor = .lightGray
    }
    
    private func loadTweets() {
        let apiClient = TweeterAPIClient()
        apiClient.loadTweets(forText: "pregnancy", maxId: nil) { (result) in
            switch result {
            case .success(let tweets):
                self.tweets = tweets
                self.tweetTableView.reloadData()
            case .error(let error):
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate, TweetViewHeightDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.reuseIdentifier, for: indexPath) as! TweetTableViewCell
        cell.configure(with: tweets[indexPath.row], heightDelegate: self)
        return cell
    }
    
    func didFinishLoadingTweetView() {
        tweetTableView.beginUpdates()
        tweetTableView.endUpdates()
    }
}
