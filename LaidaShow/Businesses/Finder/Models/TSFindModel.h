//
//  TSFindModel.h
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFindModel : NSObject

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *htmlContent;
@property (nonatomic, strong) NSString *count;
//格式化后的内容。列表页使用这个字段展示内容
@property (nonatomic, strong) NSString *content;

+ (TSFindModel*)findModelWithDic:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
