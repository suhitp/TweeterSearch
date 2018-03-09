//
//  TweetsPresenter.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 08/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import TwitterKit

enum LoadMoreState {
    case none
    case loading
    case ready
    case finished
}

enum TweetFilterAction: String {
    case likes = "Likes"
    case retweet = "Retweet"
    case all = "All"
}

protocol TweetsPresenterType: class {
    func loadTweets()
    func shouldLoadMoreTweets() -> Bool
    func loadMoreTweets()
    func configureFilterOptions()
    func filterTweets(by action: TweetFilterAction)
    func bookmark(tweet: TWTRTweet)
    func didTapBookmarkButtonWith(tweetId: String)
}

protocol TweetViewInput: class {
    func displayTweets(_ tweets: [TWTRTweet])
    func insert(_ tweets: [TWTRTweet], at indexPaths: [IndexPath])
    func showError(_ error: NetworkError)
    func updateLoadMoreState(_ state: LoadMoreState)
    func showFilterOptions(_ options: [TweetFilterAction])
    func showLoader()
    func hideLoader()
    func hideFooter()
    func scrollToTop()
    func showBookmarkActionSheet(title: String, forTweet tweet: TWTRTweet)
}

final class TweetsPresenter: TweetsPresenterType {
    
    private let apiClient: TweeterAPIClient
    var tweets: [TWTRTweet] = []
    weak var view: TweetViewInput!
    var maxId: Int?
    
    init(client: TweeterAPIClient) {
        self.apiClient = client
    }
    
    func loadTweets() {
        view.showLoader()
        apiClient.loadTweets(forText: Constants.tweetSearchKeyword, maxId: maxId) { [weak self] (result) in
            switch result {
            case .success(let tweets):
                guard let strongSelf = self else { return }
                guard  tweets.count > 0 else {
                    strongSelf.view.showError(.failure(message: "No tweets available"))
                    return
                }
                strongSelf.updateTweetModel(tweets: tweets)
                strongSelf.view.hideLoader()
                strongSelf.view.displayTweets(tweets)
            case .error(let error):
                self?.view.hideLoader()
                self?.view.showError(error)
            }
        }
    }
    
    func shouldLoadMoreTweets() -> Bool {
        return tweets.count <= Constants.maxTweetDisplayCount
    }
    
    func loadMoreTweets() {
        view.updateLoadMoreState(.loading)
        apiClient.loadTweets(forText: Constants.tweetSearchKeyword, maxId: maxId) { [weak self] (result) in
            switch result {
            case .success(let tweets):
                guard let strongSelf = self else { return }
                strongSelf.updateTweetModel(tweets: tweets)
                let previousCount = strongSelf.tweets.count - tweets.count
                let indexPaths: [IndexPath] = (previousCount..<strongSelf.tweets.count)
                    .map { IndexPath(row: $0, section: 0) }
                strongSelf.view.insert(tweets, at: indexPaths)
            case .error(let error):
                self?.view.showError(error)
            }
        }
    }
    
    func updateTweetModel(tweets: [TWTRTweet]) {
        self.tweets += tweets
        if let lastTweet = tweets.last, let tweetId = Int(lastTweet.tweetID) {
            maxId = tweetId
        }
        if self.tweets.count >= Constants.maxTweetDisplayCount {
            view.updateLoadMoreState(.finished)
            view.hideFooter()
        } else {
            view.updateLoadMoreState(.ready)
        }
    }
}

extension TweetsPresenter {

    func configureFilterOptions() {
        let options: [TweetFilterAction] = [.likes, .retweet, .all]
        self.view.showFilterOptions(options)
    }
    
    func filterTweets(by action: TweetFilterAction) {
        switch action {
        case .likes:
            let mostLikedTweets = tweets.sorted(by: { $0.likeCount > $1.likeCount }).prefix(10)
            self.view.displayTweets(Array(mostLikedTweets))
            self.view.updateLoadMoreState(.finished)
        case .retweet:
            let mostRetweetedTweets = tweets.sorted(by: { $0.retweetCount > $1.retweetCount }).prefix(10)
            self.view.displayTweets(Array(mostRetweetedTweets))
            self.view.updateLoadMoreState(.finished)
        case .all:
            self.view.displayTweets(tweets)
            if self.tweets.count == Constants.maxTweetDisplayCount {
                view.updateLoadMoreState(.finished)
            } else {
                view.updateLoadMoreState(.ready)
            }
        }
    }
    
    func didTapBookmarkButtonWith(tweetId: String) {
        if let tweet = tweets.filter ({ $0.tweetID == tweetId }).first {
            self.view.showBookmarkActionSheet(title: Constants.bookmarkTweetTitle, forTweet: tweet)
        }
    }
    
    func bookmark(tweet: TWTRTweet) {
        let userDefault = UserDefaults.standard
        if let data = userDefault.data(forKey: Constants.bookmarkTweets) {
             if var bookmarkTweets = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TWTRTweet] {
                guard !bookmarkTweets.contains(tweet) else { return }
                bookmarkTweets.append(tweet)
                let encodedTweets = NSKeyedArchiver.archivedData(withRootObject: bookmarkTweets)
                userDefault.set(encodedTweets, forKey: Constants.bookmarkTweets)
            }
        } else {
            let bookmarkTweets: [TWTRTweet] = [tweet]
            let encodedTweets = NSKeyedArchiver.archivedData(withRootObject: bookmarkTweets)
            userDefault.set(encodedTweets, forKey: Constants.bookmarkTweets)
        }
    }
}
