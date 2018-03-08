//
//  TweetTableViewCell.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 08/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit
import Kingfisher

final class TweetTableViewCell: UITableViewCell {
    
    // MARK: - Private Variables
    static let reuseIdentifier = "TweetTableViewCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLbl: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
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
    func configure(with tweet: TWTRTweet) {
        profileImageView.kf.setImage(with: URL(string: tweet.author.profileImageURL), placeholder: nil)
        nameLabel.text = tweet.author.name
        screenNameLbl.text = "@" + tweet.author.screenName
        tweetTextView.text = tweet.text
        retweetCount.text = "\(tweet.retweetCount)"
        likeCount.text = "\(tweet.likeCount)"
    }
}
