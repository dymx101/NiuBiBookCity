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
    var listPattern: String?
    
    /// 以下pattern用于解析出bookModel的信息
    var titlePattern: String?
    var bookLinkPattern: String?
    var authorPattern: String?
    var imageSrcPattern: String?
    var memoPattern: String?
    
    /// 章节容器pattern, 某些网站会在章节列表外面包一层
    var chapterContainterPattern: String?
    /// 用于从章节列表抓出一个章节
    var chapterItemPattern: String?
    /// 用于从章节string中解析出title和url
    var chapterDetailPattern: String?
    /// 用于解析出章节内容
    var chapterContentPattern: String?
}
