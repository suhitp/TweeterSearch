//
//  BookmarkPresenter.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 09/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit

protocol BookmarkPresenterType: class {
    func viewWillApear()
}

protocol BookViewInput: class {
    func displayBookmarkTweets(_ tweets: [TWTRTweet])
    func displayEmptyView(message: String)
    func hideEmptyView()
}

final class BookmarkPresenter: BookmarkPresenterType {
    weak var view: BookViewInput!
    
    func viewWillApear() {
        self.getBookmarks()
    }
    
    private func getBookmarks() {
        let userDefault = UserDefaults.standard
        if let data = userDefault.data(forKey: Constants.bookmarkTweets) {
            if let bookmarkTweets = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TWTRTweet] {
                view.hideEmptyView()
                view.displayBookmarkTweets(bookmarkTweets)
            } else {
                view.displayEmptyView(message: Constants.noBookmarkTweetsAvailable)
            }
        } else {
           view.displayEmptyView(message: Constants.noBookmarkTweetsAvailable)
        }
    }
}
