//
//  TSLanguageModel.h
//  ThreeShow
//
//  Created by wkun on 2020/1/1.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 语言数据
@interface TSLanguageModel : NSObject

@property (nonatomic, strong) NSString *languageName;  //语言名称
@property (nonatomic, strong) NSString *languageCode;  //语言编码

@end

@interface TSLanguageModel(Manager)

/// 语言数据，暂写死在本地
+ (NSArray<TSLanguageModel*>*)languageDatas;

+ (TSLanguageModel*)currLanguageModel;

+ (NSInteger)currLanguageModelIndex;

//更新当前语言
+ (void)setLanguageWithModel:(TSLanguageModel*)model;

@end

@interface NSBundle(Language)
// 设置语言
+ (void)setLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
