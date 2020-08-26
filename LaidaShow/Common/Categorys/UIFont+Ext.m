//
//  UIFont+Ext.m
//  Hitu
//
//  Created by hitomedia on 16/6/21.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "UIFont+Ext.h"

typedef NS_ENUM(NSInteger, HTFontSizeType){
    HTFontSizeTypeMoreBig = -1,                 //较大字号
    HTFontSizeTypeBig,                          //大字号
    HTFontSizeTypeNormal,                       //正常字号
    HTFontSizeTypeSmall,                        //小字号
    HTFontSizeTypeLessSmall,                    //较小字号
    HTFontSizeTypeOther                         //其他字号
};

@implementation UIFont (Ext)

+ (UIFont *)fontMoreBig{
    return [UIFont pFontWithSizeType:HTFontSizeTypeMoreBig];
}

+ (UIFont *)fontBig{
    return [UIFont pFontWithSizeType:HTFontSizeTypeBig];
}

+ (UIFont *)fontNormal{
    return [UIFont pFontWithSizeType:HTFontSizeTypeNormal];
}

+ (UIFont *)fontSmall{
    return [UIFont pFontWithSizeType:HTFontSizeTypeSmall];
}

+ (UIFont*)fontLessSmall{
    return [UIFont pFontWithSizeType:HTFontSizeTypeLessSmall];
}

+ (UIFont*)pFontWithSizeType:(HTFontSizeType)sizeType{
    CGFloat fontSize = 14.0;
    switch (sizeType) {
        case HTFontSizeTypeMoreBig:
            fontSize = 18.0;
            break;
        case HTFontSizeTypeBig:
            fontSize = 16.0;
            break;
        case HTFontSizeTypeNormal:
            fontSize = 14.0;
            break;
        case HTFontSizeTypeSmall:
            fontSize = 12.0;
            break;
        case HTFontSizeTypeLessSmall:
            fontSize = 10.0;
            break;
        case HTFontSizeTypeOther:
            fontSize = 0;
            break;
    }
    
    return [UIFont systemFontOfSize:fontSize];
}

@end
