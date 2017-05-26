//
//  BookMountainSourceInterface.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

class BookMountainSource {
    
    var baseURL: String?
    var requestEncoding: String.Encoding?
    var shouldPretendAsComputer: Bool?
    var parsingPatterns: BookParsingPatterns?
    
    func searchURL(withKeyword keyword: String, page: Int) -> String {
        return ""
    }
}
