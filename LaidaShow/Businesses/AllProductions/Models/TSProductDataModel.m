//
//  TSProductDataModel.m
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductDataModel.h"
#import "MJExtension.h"
#import "NSString+Ext.h"

@implementation TSProductDataModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",@"isPublic":@"publicLevel"};
}

@end
