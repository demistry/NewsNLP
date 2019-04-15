//
//  NewsTableViewCell.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 15/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

   
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    
    class var nib : UINib {
        return UINib(nibName: "NewsTableViewCell", bundle: Bundle.main)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        cellContentView.layer.cornerRadius = 8
        cellContentView.clipsToBounds = true
    }
    
}
