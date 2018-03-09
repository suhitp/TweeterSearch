//
//  TweetCell.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 09/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit
import Kingfisher

protocol BookmarkTweetEventDelegate: class {
    func didTapBookmarkTweetWith(tweetId : String)
}

final class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLbl: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    static let reuseIdentifier = "TweetTableViewCell"
    weak var delegate: BookmarkTweetEventDelegate?
    private (set) var tweetId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        profileImageView.layer.cornerRadius = 8
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFit
    }
    
    // MARK: - Public Methods
    func configure(with tweet: TWTRTweet, delegate: BookmarkTweetEventDelegate? = nil) {
        self.delegate = delegate
        self.tweetId = tweet.tweetID
        profileImageView.kf.setImage(with: URL(string: tweet.author.profileImageURL), placeholder: nil)
        nameLabel.text = tweet.author.name
        screenNameLbl.text = "@" + tweet.author.screenName
        tweetLabel.text = tweet.text
        retweetCount.text = "\(tweet.retweetCount)"
        likeCount.text = "\(tweet.likeCount)"
    }
    
    @IBAction func didTapBookmark(_ sender: UIButton) {
        self.delegate?.didTapBookmarkTweetWith(tweetId: tweetId)
    }
}
