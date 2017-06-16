//
//  BCTBookCategoryModel.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/15.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

let DESCRIPTION = "description"
let ORDER = "order"
let CATEGORYNAME = "categoryname"
let URL = "url"
let URLARY = "urlAry"

class BCTBookCategoryModel: NSObject {
    var name: String = ""
    var strUrl: String = ""
    var categoryDescription: String = ""
    var curIndex: Int = 0
    var bgColor: UIColor?
    var aryUrl:[String] = []
}
