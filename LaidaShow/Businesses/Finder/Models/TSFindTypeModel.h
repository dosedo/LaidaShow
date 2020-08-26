//
//  TSFindTypeModel.h
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 发现频道的新闻配型。如公司动态，行业新闻，产品资讯
 */
@interface TSFindTypeModel : NSObject

@property (nonatomic, strong) NSString *des;
@property (nonatomic, strong) NSString *ID; //id
@property (nonatomic, strong) NSString *keyWord;//": "",
@property (nonatomic, strong) NSString *typeName;//": "行业新闻",
@property (nonatomic, strong) NSString *title;//": "行业新闻-三维成像分享平台",
@property (nonatomic, strong) NSString *ywdesccript;//": "Industry news",
@property (nonatomic, strong) NSString *ywTypeName;//": "Industry news",
@property (nonatomic, strong) NSString *ywtitle;//": "Industry news"

+ (TSFindTypeModel*)findTypeModelWithDic:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
