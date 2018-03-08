//
//  TweeterAPIClient.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 07/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import TwitterKit

struct TweeterAPIClient {

    let url = "https://api.twitter.com/1.1/search/tweets.json"
    let consumerKey = "R6yWPRlg2WHgrwQdqMSNATHzM"
    let secret = "rfEsLFawxA1fa6RQiTPRZDP5h8gQuEzOuoQjY53nmXAQ0rnnff"
    let client = TWTRAPIClient()
    
    init() {}
    
    func loadTweets(forText text: String, maxId: Int?, completion: @escaping ((Result) -> Void)) {
        var params: [String: String] = ["q": text, "result_type": "mixed", "count": "20"]
        if let maxId = maxId {
            params["max_id"] = String(maxId)
        }
        
        let request = client.urlRequest(withMethod: "GET", url: url, parameters: params, error: nil)
        client.sendTwitterRequest(request) { (response, data, error) in
            if let error = error {
                completion(.error(.failure(message: error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.error(.failure(message: "invalied response code")))
                return
            }
            
            do {
               let json  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                if let tweetArray = (json["statuses"] as? [[String: Any]]) {
                    print(tweetArray)
                    let tweets = TWTRTweet.tweets(withJSONArray: tweetArray)
                    completion(.success(tweets as! [TWTRTweet]))
                }
            } catch {
                completion(.error(.failure(message: error.localizedDescription)))
            }
        }
    }
}


enum Result {
    case success([TWTRTweet])
    case error(NetworkError)
}

enum NetworkError: Error {
    case noInternet
    case failure(message: String)
    case timeout
}
