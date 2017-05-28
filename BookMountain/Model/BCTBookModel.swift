//  The converted code is limited by 1 KB.
//  Please Sign Up (Free!) to remove this limitation.

//  Converted with Swiftify v1.0.6341 - https://objectivec2swift.com/
//
//  Created by apple on 15/12/29.
//
//

import Foundation

class BCTBookModel: NSObject {
    var bookId: String = ""
    var chapterId: String = ""
    var title: String = ""
    var author: String = ""
    var imgSrc: String = ""
    var wordCount: String = ""
    var cateogryName: String = ""
    var subCategoryName: String = ""
    var isFinally: String = ""
    var memo: String = ""
    var lastModify: String = ""
    var bookLink: String = ""
    var chapterList: String = ""
    var aryChapterList = [Any]()
    var finishChapterNumber: Int = 0
    var isPendingDownload: Bool = false
    //网页浏览的时候调用。
    var curChapter: Int = 0
    

}
