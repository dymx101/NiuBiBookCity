//
//  BookParsingItem.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/6/21.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class BookParsingItem: BaseModel {
    var inputParam : String = ""
    var inputKey : String = ""
    var isOnlyCalcResult : Bool = false
    var requestEncoding : String = ""
    var responseEncoding : String = ""
    var parsingFuntion : String = ""
    var parsingFuntionName : String = ""
    var parsing : String = ""
    var boolParam : Bool = false
    var userParamDic : Bool = false
    
    

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if(key == "boolParam")
        {
            self.boolParam = (value as? Bool)!
        }
        else if(key == "userParamDic")
        {
            self.userParamDic = (value as? Bool)!
        }
    }

    
    
    
}
