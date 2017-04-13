//
//  DefineHeader.h
//  BMFrameworkDemo
//
//  Created by fx on 14-8-21.
//  Copyright (c) 2014年 bluemobi. All rights reserved.
//

#ifndef BMFrameworkDemo_DefineHeader_h
#define BMFrameworkDemo_DefineHeader_h



//---所有命令的调用
#define DEF_ACTIONIDCMD_GETSEARCHBOOKRESULT @"getSearchBookResult:"
#define DEF_ACTIONIDCMD_GETCATEGORYBOOKSRESULT @"getCategoryBooksResult:"
#define DEF_ACTIONIDCMD_GETBOOKCHAPTERLIST @"getBookChapterList:"
#define DEF_ACTIONIDCMD_GETBOOKCHAPTERDETAIL @"getBookChapterDetail:"
#define DEF_ACTIONIDCMD_DOWNLOADPLIST @"downloadplist:"



//所有命令
#define DEF_ACTIONID_BOOKACTION @"BookAction"



// Error Code
typedef NS_ENUM(NSInteger, BCTErrorCode) {
    kBCTErrorSearchBook = 10000
    , kBCTErrorGetBookChapters
};



//cell
#define BOOKCELLID @"BOOKCELLID"





#endif
