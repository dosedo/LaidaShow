//
//  TSNoticeModel.h
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSNoticeModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *des;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSDictionary *originDic;

+ (TSNoticeModel*)noticeModelWithDic:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
