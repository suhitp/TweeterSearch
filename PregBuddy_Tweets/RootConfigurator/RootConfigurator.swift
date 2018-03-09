//
//  RootConfigurator.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 08/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit

final class RootConfigurator {
    private let window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func configureRootViewController() {
        let rootTabBatVC = window?.rootViewController as! UITabBarController
        let tweetNavigationController = rootTabBatVC.viewControllers![0] as? UINavigationController
        let bookmarkNavigationController = rootTabBatVC.viewControllers![1] as? UINavigationController
        
        let tweetVC = tweetNavigationController?.topViewController as? TweetsViewController
        configureTweetsView(tweetVC)
        
        let bookmarkVC = bookmarkNavigationController?.topViewController as? BookmarkViewController
        configureBookmarkView(bookmarkVC)
    }
    
    func configureTweetsView(_ tweetVC: TweetsViewController?) {
        let client = TweeterAPIClient(client: TWTRAPIClient(), url: Constants.tweeterApiUrl)
        let tweetsPresenter = TweetsPresenter(client: client)
        tweetVC?.tweetsPresenter = tweetsPresenter
        tweetsPresenter.view = tweetVC
    }
    
    func configureBookmarkView(_ bookmarkVC: BookmarkViewController?) {
        let bookmarkPresenter = BookmarkPresenter()
        bookmarkVC?.bookmarkPresenter = bookmarkPresenter
        bookmarkPresenter.view = bookmarkVC
    }
}
