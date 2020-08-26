//
//  TSProductionDetailModel.h
//  ThreeShow
//
//  Created by hitomedia on 09/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSProductDataModel;
@class TSWorkModel;
/**
 作品详情数据模型
 */
@interface TSProductionDetailModel : NSObject

@property (nonatomic, strong) NSArray *imgUrls;

@property (nonatomic, strong) NSString *headImgUrl;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productCategory;   //商品类别
@property (nonatomic, strong) NSString *price; //价格和销量
@property (nonatomic, strong) NSString *saleCount;
@property (nonatomic, strong) NSString *productDes;
@property (nonatomic, strong) NSString *praiseCount;
@property (nonatomic, strong) NSString *collectCount;
@property (nonatomic, strong) NSString *musicName; //音乐名称 //若为空，隐藏音乐按钮
@property (nonatomic, strong) NSString *musicUrl; //若为空，隐藏音乐按钮
@property (nonatomic, strong) NSString *buyUrl; //购物的链接 若为空，隐藏buy按钮
@property (nonatomic, assign) BOOL isPraised; //是否点赞
@property (nonatomic, assign) BOOL isCollected; //是否收藏
@property (nonatomic, strong) NSString *videoUrl; //视频url
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, assign) BOOL isCanOnline; //是否可以在线服务。默认为NO
@property (nonatomic, strong) NSString *gifUrl;  //动图地址

//本地作品详情需要的字段
@property (nonatomic, strong) NSString *priceAndSaleCount; //价格和销量
//@property (nonatomic, strong) NSString *localWorkCategory; //本地作品类别

@property (nonatomic, strong) TSProductDataModel *dm;


/**
 将返回的url拼接上服务器地址 http://n.res.aipp3d.com

 @param tailStr 服务器返回的尾字符串
 @return 全URL
 */
- (NSString*)productVideoUrlWithTailStr:(NSString*)tailStr;

+ (TSProductionDetailModel*)productionDetailModelWithDm:(TSProductDataModel*)dm;


/**
 本地作品的详情model

 @param wm 本地model
 @return 视图model
 */
+ (TSProductionDetailModel*)productionDetailModelWithWorkModel:(TSWorkModel*)wm;
//更新detailModel的内容
//- (TSProductionDetailModel*)productionDetailModelWithNewDm:(TSProductDataModel*)dm;

@end


