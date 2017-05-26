//
//  BookMountainSourceInterface.swift
//  BookMountain
//
//  Created by Yiming Dong on 26/05/2017.
//  Copyright © 2017 Yiming Dong. All rights reserved.
//

import Foundation

protocol BookMountainSourceInterface {
    
    var baseURL: String {get set}
    var requestEncoding: String.Encoding {get}
    var shouldPretendAsComputer: Bool {get}
    
    func searchURL(withKeyword keyword: String, page: Int) -> String
}
