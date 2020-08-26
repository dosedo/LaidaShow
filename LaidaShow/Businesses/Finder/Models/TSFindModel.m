//
//  TSFindModel.m
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFindModel.h"
#import "TSHelper.h"
#import "TSConstants.h"
#import "NSString+Ext.h"

@implementation TSFindModel
//advertiseUrl = admin;
//content = "";
//desccript = "";
//draft = 0;
//firstPage = "";
//id = 509;
//keyWord = "";
//languageType = 0;
//name = "公司动态";
//newId = 61;
//picture = "shenyi/image/new_modulars/20161221150204.png";
//title = "申义集团广州珠宝展进行时";
//tittle = "";
//type = 30;
//updateTime = 1482249600000;
//ywdesccript = "";
//ywkeyWord = "";
//ywtittle = "";

+ (TSFindModel *)findModelWithDic:(NSDictionary *)dic{
    if( [dic isKindOfClass:[NSDictionary class]] == NO ) return nil;
    
    BOOL isEnglish = [TSHelper isEnglishLanguage];
    
    TSFindModel *tm = [TSFindModel new];
    tm.newsId = [NSString stringWithObj:dic[@"id"]];
    tm.imgUrl = [NSString stringWithFormat:@"%@/%@",TSConstantServerUrl,dic[@"icon"]];
    tm.title = [NSString stringWithObj:dic[isEnglish?@"ywtittle":@"title"]];
    tm.htmlContent = [NSString stringWithObj:dic[@"content"]];
    tm.count = [self countWithString:dic[@"updateTime"]];
    
    tm.content = [self formatHtmlContent:tm.htmlContent];
    
    return tm;
}


+ (NSString*)countWithString:(NSString*)str{
    NSString *time = [NSString stringWithObj:str];
    if( time ){
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000];
        NSString *dateStr = [NSString stringWithDate:date format:@"yyyy-MM-dd HH:mm:ss"];
        return dateStr;
    }
    return nil;
}

+ (NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }

    return html;
}

+ (NSString *)filterCommentHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<!--" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@"-->" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",text] withString:@""];
    }
    
    return html;
}

+ (NSString*)formatHtmlContent:(NSString*)text{
    if( [text isKindOfClass:[NSString class]] ){
        
        NSString *nt  = [self filterCommentHTML:text];
        nt = [self filterHTML:nt];
        
        NSInteger wordCount = 500;
        if( nt.length > wordCount ){
            nt = [nt substringToIndex:wordCount];
        }
        
        nt =
        [self deleteText:@"&nbsp;" originText:nt];

        wordCount = 50;
        if( nt.length > wordCount ){
            nt = [nt substringToIndex:wordCount];
        }
        
        nt =
        [self deleteText:@"&ldquo;" originText:nt];

        nt =
        [self deleteText:@"&rdquo;" originText:nt];

        nt =
        [self deleteText:@"&middot;" originText:nt];

        nt =
        [self deleteText:@"&mdash;" originText:nt];
        
        return nt.filterOutSpace;
    }
    
    return nil;
}

+ (NSString*)deleteText:(NSString*)deleteText originText:(NSString*)text{
    NSString *markP = deleteText;
    if( [text containsString:markP] ){
        return
        [text stringByReplacingOccurrencesOfString:markP withString:@""];
    }
    
    return text;
}


@end
