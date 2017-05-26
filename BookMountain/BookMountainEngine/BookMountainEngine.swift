//
//  BookMountainEngine.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

protocol BookMountainEngineInterface {
    func search(withKeyword keyword:String, page: Int)
}

class BookMountainEngine: BookMountainEngineInterface {
    
    var webSources: [BookMountainSource] = []
    
    func search(withKeyword keyword:String, page: Int) {
        
    }
    
    private func loadConfig() {
    
    }
}
