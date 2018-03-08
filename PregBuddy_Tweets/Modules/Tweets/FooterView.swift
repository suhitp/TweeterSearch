//
//  FooterView.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 08/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import UIKit

//MARK: FooterView
final class FooterView: UIView {
    private(set) var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let topInset: CGFloat = -5
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spinner)
        self.spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: topInset).isActive = true
    }
    
    public func startAnimating() {
        self.spinner.startAnimating()
    }
    
    public func stopAnimating() {
        self.spinner.stopAnimating()
    }
}

