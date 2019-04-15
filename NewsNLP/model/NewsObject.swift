//
//  NewsObject.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 15/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import Foundation

struct NewsObject : Decodable {
    var status : String
    var totalResults : Int
    var articles : [ArticleObject]
}

struct ArticleObject : Decodable{
    var source : SourceObject
    var author : String
    var title : String
    var description : String
    var url : URL
    var urlToImage : URL
    var publishedAt : String
    var content : String?
}

struct SourceObject : Decodable{
    var id : String?
    var name : String
}
