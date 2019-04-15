//
//  ViewController.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 15/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import UIKit
import PINRemoteImage

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var newsObject : NewsObject?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: "NewsTableViewCell")
        
        Networking.getNews { (result) in
            switch result {
            case .success(let newsObject):
                self.newsObject = newsObject
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failure in receiving with error:\(error.localizedDescription) ")
            }
        }
        
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let news = newsObject else{
            return 0
        }
        return news.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellOpt = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell
        guard let cell = cellOpt, let news = newsObject, news.articles.count > 0 else{
            return UITableViewCell()
        }
        
        cell.newsImageView.pin_updateWithProgress = true
        cell.newsImageView.pin_setImage(from: news.articles[indexPath.row].urlToImage)
        cell.newsTitle.text = news.articles[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 194
    }
    
    
}

