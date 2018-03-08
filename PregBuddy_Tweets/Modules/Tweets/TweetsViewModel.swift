//
//  TweetsViewModel.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 08/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import TwitterKit

struct TweetsViewModel {
    var tweets: [TWTRTweet]
    
    init(tweets: [TWTRTweet]) {
        self.tweets = tweets
    }
}
