//
//  FSPublicUtil.swift
//  BookMountain
//
//  Created by 冯璇 on 2017/5/31.
//  Copyright © 2017年 Yiming Dong. All rights reserved.
//

import UIKit

class FSPublicUtil: NSObject {
    public static let DEF_ACTIONID_BOOKACTION = "BookAction"
    
    
    
    
    public static let DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT = "getSearchBookResultWithBaseParam:"
    
    
    
//    #define DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT @"getSearchBookResult:"
//    #define DEF_ACTIONIDCMD_GETCATEGORYBOOKSRESULT @"getCategoryBooksResult:"
//    #define DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST @"getBookChapterList:"
//    #define DEF_ACTIONIDCMD_GETBOOKCHAPTERDETAIL @"getBookChapterDetail:"
//    #define DEF_ACTIONIDCMD_DOWNLOADPLIST @"downloadplist:"
}


extension String {
    
//    /// 从String中截取出参数
//    var urlParameters: [String: AnyObject]? {
//        // 判断是否有参数
//        guard let start = self.range(of: "?")
//        else {
//            return nil
//        }
//        
//        var params = [String: AnyObject]()
//        // 截取参数
//        let index = start.lowerBound
//        
//        let paramsString = self.substring(from: index)
//        
//        // 判断参数是单个参数还是多个参数
//        if paramsString.contains("&") {
//            // 多个参数，分割参数
//            let urlComponents = paramsString.components(separatedBy:"&")
//            
//            // 遍历参数
//            for keyValuePair in urlComponents {
//                // 生成Key/Value
//                let pairComponents = keyValuePair.components(separatedBy: "=")
//                let key = pairComponents.first?.removingPercentEncoding
//                let value = pairComponents.last?.removingPercentEncoding
//                // 判断参数是否是数组
//                if let key = key, let value = value {
//                    // 已存在的值，生成数组
//                    if let existValue = params[key] {
//                        if var existValue = existValue as? [AnyObject] {
//                            
//                            existValue.append(value as AnyObject)
//                        } else {
////                            params[key] = [existValue,value]
//                            params[key] = "" as AnyObject
//                        }
//                        
//                    } else {
//                        
//                        params[key] = value as AnyObject
//                    }
//                    
//                }
//            }
//            
//        } else {
//            
//            // 单个参数
//            let pairComponents = paramsString.components(separatedBy: "=")
//            
//            // 判断是否有值
//            if pairComponents.count == 1 {
//                return nil
//            }
//            
//            let key = pairComponents.first?.removingPercentEncoding
//            let value = pairComponents.last?.removingPercentEncoding
//            if let key = key, let value = value {
//                params[key] = value as AnyObject
//            }
//            
//        }
//        
//        
//        return params
//    }
    
    var baseUrl: String? {
        // 判断是否有参数
        guard let start = self.range(of: "?")
            else {
                return nil
        }
//        let startPos = self.index(start.lowerBound, offsetBy: 1)
        return self.substring(to: start.lowerBound)
    }
    
    /// 从String中截取出参数
    var urlParameters: [String: String]? {
        // 判断是否有参数
        guard let start = self.range(of: "?")
            else {
                return nil
        }
        
        var params = [String: String]()
        // 截取参数
        
        let startPos = self.index(start.lowerBound, offsetBy: 1)

        
//        let index = start.lowerBound.advanceBy(1)
//        let index2:String.Index = advancedBy(index,1)
        
//        Range(uncheckedBounds: (lower: Comparable, upper: Comparable))
//        start.lowerBound.advancedBy(1)
        
        
        let paramsString = self.substring(from: startPos)
        
        // 判断参数是单个参数还是多个参数
        if paramsString.contains("&") {
            // 多个参数，分割参数
            let urlComponents = paramsString.components(separatedBy:"&")
            
            // 遍历参数
            for keyValuePair in urlComponents {
                // 生成Key/Value
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first?.removingPercentEncoding
                let value = pairComponents.last?.removingPercentEncoding
                // 判断参数是否是数组
                if let key = key, let value = value {
                    // 已存在的值，生成数组
                    if let existValue = params[key] {
                        if var existValue = existValue as? [String] {
                            
                            existValue.append(value as! String)
                        } else {
                            //                            params[key] = [existValue,value]
                            params[key] = ""
                        }
                        
                    } else {
                        
                        params[key] = value as String
                    }
                    
                }
            }
            
        } else {
            
            // 单个参数
            let pairComponents = paramsString.components(separatedBy: "=")
            
            // 判断是否有值
            if pairComponents.count == 1 {
                return nil
            }
            
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            if let key = key, let value = value {
                params[key] = value as String
            }
            
        }
        
        
        return params
    }
}
