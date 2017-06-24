//  The converted code is limited by 1 KB.
//  Please Sign Up (Free!) to remove this limitation.

//  Converted with Swiftify v1.0.6341 - https://objectivec2swift.com/
//
//  Created by apple on 15/12/29.
//
//

import Foundation
import SDWebImage

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
    
    
    
    
    func toDic() -> [String: Any] {
        var retDic = [String: Any]()
        retDic["author"] = self.author
        retDic["cover"] = "no_cover.png"
        retDic["isbn"] = ""
        retDic["order"] = "-999"
        retDic["src"] = "default.png"
        retDic["status"] = "已完成"
        retDic["title"] = title
        var aryPartTitle = [Any]()
        aryPartTitle.append("章节列表")
        retDic["partTitleArr"] = aryPartTitle
        var aryChapter = [Any]()
        var aryChapter2 = [Any]()
        for i in 0..<aryChapterList.count {
            let bookchaptermodel: BCTBookChapterModel? = (aryChapterList[i] as? BCTBookChapterModel)
            var chapterDic = [AnyHashable: Any]()
            chapterDic["chapterContent"] = bookchaptermodel?.content
            chapterDic["chapterSrcs"] = ""
            chapterDic["chapterTitle"] = bookchaptermodel?.title
            chapterDic["href"] = ""
            aryChapter2.append(chapterDic)
            
        }
        
        aryChapter.append(contentsOf: aryChapter2)
        
        
        
//        [retDic setObject:aryChapter forKey:@"chapterArrArr"];

        retDic["chapterArrArr"] = aryChapter
        
        return retDic
    }
    
    
    
    class func downloadPath() -> String {
        
        
        //let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        
        var  downloadPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        
        //+"/download_books"
        
        //        downloadPath = String(format: "%@/%@", [downloadPath,"download_books"])
        
        downloadPath = downloadPath! + "/download_books"
        //downloadPath = "\(DocumentsDir)/download_books"
        if !FileManager.default.fileExists(atPath: downloadPath!) {
            do {
                try FileManager.default.createDirectory(atPath: downloadPath!, withIntermediateDirectories: true, attributes: nil)
            }
            catch _ {
            }
        }
        return downloadPath!
    }
    
    
    
    func savePlist() -> Bool {
        let downloadPath = BCTBookModel.downloadPath()
//        var plistFile = "\(downloadPath)/\(self.title).plist"
        
//        let plistFile = String(format: "%s/%@.plist", [downloadPath,self.title])
//                print("plist Adress==================================>")
//                print("\(plistFile)")
        let plistFile = downloadPath + "/"+self.title+".plist"
        let bookDic = self.toDic()
        //self.saveImgSrc()
        //        DYMBookDownloadManager.sharedInstance().recordDownloadedBook(self)
        //        do {
        //            try NSFileManager.defaultManager().removeItemAtPath(plistFile)
        //        }
        //        catch let error {
        //        }
        //        return bookDic.writeToFile(plistFile, atomically: true)
        
        let nsBookDic = NSDictionary(dictionary: bookDic, copyItems: true)
        nsBookDic.write(toFile: plistFile, atomically: true)
        
        return true
        
    }
    func saveImgSrc() {
        if imgSrc.isEmpty {
            return
        }
        SDWebImageManager.shared().downloadImage(with:URL(string:imgSrc), options: SDWebImageOptions(rawValue: 0), progress: {(_ receivedSize: Int, _ expectedSize: Int) -> Void in
        }, completed: {(_ image: UIImage, _ error: Error?, _ cacheType: SDImageCacheType, _ finished: Bool, _ imageURL: URL) -> Void in
            if finished {
                let imagedata:Data? = UIImageJPEGRepresentation(image,1.0)
                //            NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                //            NSString *documentsDirectory=[paths objectAtIndex:0];
                let downloadPath: String = BCTBookModel.downloadPath()
                let imgPath: String = "\(downloadPath)/\(self.title).jpeg"
//                imagedata?.write(to: URL(string:imgPath)!, options: true)
//                imagedata?.write(to: URL(string:imgPath, options: Data.WritingOptions.atomicWrite)
                
                do {
                    try  imagedata?.write(to: URL(string:imgPath)!, options: Data.WritingOptions.atomicWrite)
                    
                }
                catch _ {
                }
                
            }
        } as! SDWebImageCompletionWithFinishedBlock)
        
        
    }
    
}
