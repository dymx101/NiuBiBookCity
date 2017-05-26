//
//  BookParsingPatterns.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

/// BookParsingPatterns 用于配置图书解析时的正则表达式
class BookParsingPatterns {
    
    /// 用于解析出图书列表
    var list: String?
    
    /// 以下pattern用于解析出bookModel的信息
    var title: String?
    var bookLink: String?
    var author: String?
    var imageSrc: String?
    var memo: String?
    
    /// 章节容器pattern, 某些网站会在章节列表外面包一层
    var chapterContainter: String?
    /// 用于从章节列表抓出一个章节
    var chapterItem: String?
    /// 用于从章节string中解析出title和url
    var chapterDetail: String?
    /// 用于解析出章节内容
    var chapterContent: String?
}
