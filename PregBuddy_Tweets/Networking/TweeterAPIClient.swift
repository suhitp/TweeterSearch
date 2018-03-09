//
//  TweeterAPIClient.swift
//  PregBuddy_Tweets
//
//  Created by Suhit Patil on 07/03/18.
//  Copyright © 2018 Suhit Patil. All rights reserved.
//

import TwitterKit

enum Result {
    case success([TWTRTweet])
    case error(NetworkError)
}

enum NetworkError: Error {
    case failure(message: String)
    case loadMoreError
}

struct TweeterAPIClient {
    let client: TWTRAPIClient
    let url: String
    
    init(client: TWTRAPIClient, url: String) {
        self.client = client
        self.url = url
    }
    
    func loadTweets(forText text: String, maxId: Int?, completion: @escaping ((Result) -> Void)) {
        
        var params: [String: String] = ["q": text, "result_type": "recent", "include_entities": "false", "count": "20"]
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
                    let tweets = TWTRTweet.tweets(withJSONArray: tweetArray) as! [TWTRTweet]
                    completion(.success(tweets))
                }
            } catch {
                if maxId != nil {
                    completion(Result.error(.loadMoreError))
                } else {
                    completion(.error(.failure(message: error.localizedDescription)))
                }
            }
        }
    }
}
