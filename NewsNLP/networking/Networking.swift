//
//  Networking.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 15/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import Foundation

class Networking {
    typealias completionHandler = (Result<NewsObject,Error>) -> Void
    
    static func getNews(completionHandler : @escaping completionHandler){
        let urlOpt = URL(string: "https://newsapi.org/v2/everything?q=a&apiKey=9bb10c9febb943c3b9aa09de7a9e2a71")
        guard let url = urlOpt else{
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let res = response, let data = data else{
                completionHandler(.failure(error!))
                return
            }
            //print("Response is \(res.debugDescription)")
            let httpRes = res as! HTTPURLResponse
            guard httpRes.statusCode == 200 else{
                print("Failed here")
                return
            }
            let decoder = JSONDecoder()
            let newsObject = try! decoder.decode(NewsObject.self, from: data)
            completionHandler(.success(newsObject))
            //completionHandler(.failure(NewsObject))
        }
        
        task.resume()
        
    }
}


//class NetworkError
