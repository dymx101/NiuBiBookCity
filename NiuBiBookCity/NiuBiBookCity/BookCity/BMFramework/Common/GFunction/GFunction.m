//
//  GFunction.m
//  DYMReader
//
//  Created by apple on 6/3/16.
//  Copyright © 2016 Dong Yiming. All rights reserved.
//

#import "GFunction.h"

@implementation GFunction
DEF_SINGLETON(GFunction)



//初始化敏感字符
-(NSMutableDictionary*)addSensitiveWordToDic:(NSArray*) ary
{
    NSMutableDictionary *sensitiveWordDic = [NSMutableDictionary new];
    //    NSString *key = nil;
    NSMutableDictionary *nowDic = nil;
    NSMutableDictionary *newWordDic = nil;
    
    for(NSString* itemKeyWord in ary){
        NSLog(@"%@",itemKeyWord);
        nowDic = sensitiveWordDic;
        for (int i = 0; i<[itemKeyWord length]; i++) {
            //截取字符串中的每一个字符
            NSString *keyChar = [itemKeyWord substringWithRange:NSMakeRange(i, 1)];
            NSLog(@"string is %@",keyChar);
            
            NSMutableDictionary *wordDic = [nowDic objectForKey:keyChar];
            
            if(wordDic != nil)
            {
                nowDic = wordDic;
            }
            else
            {
                newWordDic = [NSMutableDictionary new];
                [newWordDic setObject:@"0" forKey:@"isEnd"];
                [nowDic setObject:newWordDic forKey:keyChar];
                nowDic = newWordDic;
                
            }
            
            if(i == [itemKeyWord length] - 1)
                
            {
                [nowDic setObject:@"1" forKey:@"isEnd"];
            }
        }
        
    }
    return sensitiveWordDic;
}





/**
 * 检查文字中是否包含敏感字符，检查规则如下：<br>
 * @author chenming
 * @date 2014年4月20日 下午4:31:03
 * @param txt
 * @param beginIndex
 * @param matchType
 * @return，如果存在，则返回敏感词字符的长度，不存在返回0
 * @version 1.0
 */
-(int)CheckSensitiveWord:(NSString*) txt
                   Begin:(int)beginIndex
           SensitiveWord:(NSMutableDictionary*)sensitiveWordDic
{
    Boolean flag = false;
    int matchFlag = 0;
    NSString *word = @"";
    NSMutableDictionary *nowDic = sensitiveWordDic;
    for (int i = beginIndex; i<[txt length]; i++)
    {
        word =  [txt substringWithRange:NSMakeRange(i, 1)];
        nowDic = [nowDic objectForKey:word];
        
        if(nowDic != nil)
        {
            matchFlag++;     //找到相应key，匹配标识+1
            if([[nowDic objectForKey:@"isEnd"]  isEqual: @"1"])
            {
                flag = true;
                
                //用最小规则直接返回
                break;
            }
            
            
            
        }
        else
        {
            matchFlag = 0;
            nowDic = sensitiveWordDic;
        }
    }
    
    if(matchFlag < 2 && !flag){
        matchFlag = 0;
    }
    
    return matchFlag;
}

@end
