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

protocol TweetsPresenterType: class {
    func loadTweets()
    func shouldLoadMoreTweets() -> Bool
    func loadMoreTweets()
}

protocol TweetViewInput: class {
    func displayTweets(_ tweets: [TWTRTweet])
    func insert(_ tweets: [TWTRTweet], at indexPaths: [IndexPath])
    func showError(_ error: NetworkError)
    func updateLoadMoreState(_ state: LoadMoreState)
    func showLoader()
    func hideLoader()
    func hideFooter()
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
                if let lastTweet = tweets.last, let tweetId = Int(lastTweet.tweetID) {
                    strongSelf.maxId = tweetId - 1
                }
            case .error(let error):
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
        if self.tweets.count == Constants.maxTweetDisplayCount {
            view.updateLoadMoreState(.finished)
            view.hideFooter()
        } else {
            view.updateLoadMoreState(.ready)
        }
    }
}

struct Constants {
    static let tweetSearchKeyword = "Swift programming"
    static let maxTweetDisplayCount = 100
}
