//
//  TSCategoryModel.h
//  ThreeShow
//
//  Created by wkun on 2018/9/25.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCategoryModel : NSObject

@property (nonatomic, strong) NSString *categoryCode;
@property (nonatomic, strong) NSString *categoryName;

+ (TSCategoryModel*)categoryWithCode:(NSString*)code name:(NSString*)name;

+ (NSArray<NSString*>*)categoryCodes;

+ (NSArray<NSString*>*)categoryNames;

/**
 发布商品时，选择类别

 @return 类别模型数组
 */
+ (NSArray<TSCategoryModel*>*)categoryModels;

@end
