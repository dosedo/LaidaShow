//
//  TSProductModel.h
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSProductDataModel;
@interface TSProductModel : NSObject

@property (nonatomic, strong) NSString *productImgUrl; //网络路径或者本地路径
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userImgUrl;
@property (nonatomic, strong) NSString *praiseCount;
@property (nonatomic, assign) BOOL     isPraised;  //是否已经赞过
@property (nonatomic, assign) BOOL     isCanOnlineService;  //是否可以申请在线服务
@property (nonatomic, assign) BOOL     isVideoWork;         //是否为视频作品

@property (nonatomic, strong) TSProductDataModel *dm;

+ (TSProductModel*)productModelWithDm:(TSProductDataModel*)dm;

@end



