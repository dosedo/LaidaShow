//
//  TSWorkModel.h
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
// metwen

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef TSWORKMODEL
#define TSWORKMODEL

typedef NS_ENUM(NSUInteger, TSWorkClearBgState){
    TSWorkClearBgStateNotBegin = 0,//未开始
    TSWorkClearBgStateClearing, //去底中
    TSWorkClearBgStateCleared   //去底完成
};

typedef NS_ENUM(NSInteger, TSWorkEditObject){
    TSWorkEditObjectOriginWork = 0,//编辑原图
    TSWorkEditObjectClearedBgWork, //编辑去地图
};

#endif

@class ImgInfoModel;
@interface TSWorkModel : NSObject<NSCopying>

#pragma mark - 视频作品部分
@property (nonatomic, assign) BOOL isVideoWork;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *coverPath;
//正在编辑的视频地址
@property (nonatomic, strong) NSURL *editingVideoUrl;

#pragma mark - new
@property (nonatomic, assign) BOOL isLocalWork;   //是否是本地作品

/**
 正在处理的对象，即原图或去底图。每对其操作一次，就更新本地图片。
 */
@property (nonatomic, assign) TSWorkEditObject editingObject;
@property (nonatomic, strong) NSArray<UIImage*> *editingImgs;  //正在编辑或等待编辑的图片，即当前展示的图片，原图或者去底图。

/*
 * 作品的基本信息
 */
@property (nonatomic, strong) NSString *recordPath;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicUrl;
@property (nonatomic, strong) NSString *workName;
@property (nonatomic, strong) NSString *workPrice;
@property (nonatomic, strong) NSString *workSaleCount;
@property (nonatomic, strong) NSString *workBuyUrl;
@property (nonatomic, strong) NSString *workDes;
@property (nonatomic, strong) NSString *workCategory;    //作品类别
@property (nonatomic, strong) NSString *workCategoryCode;//修改为作品的类别code


/*
 * 作品的图片数据
 */
@property (nonatomic, strong) NSArray<NSString*> *imgPathArr;         //图片的本地路径
@property (nonatomic, strong) NSArray<NSString*> *maskImgPathArr;     //退底时的中间结果路径也叫遮罩层
@property (nonatomic, strong) NSArray<NSString*> *clearBgImgPathArr;  //退底图片的路径

/*
 * 本地缓存作品独有的数据
 */
@property (nonatomic, assign) NSInteger imgDataIndex;    //图片数据的索引,-1代表没有缓存
@property (nonatomic, strong) NSString *workDirName;     //作品的目录名，由固定前缀和时间戳生成， 如。workimgrpath1232fsd

/*
 * 存放临时编辑的图片。 该字段保存作品时，不需要缓存，但需要清除其内的数据。
 * 保存时，若存在编辑后的图片，将该编辑的图片保存至作品路径，若不存在编辑的图片，则保存“作品的图片数据”下的路径。
 */
@property (nonatomic, strong) NSArray<NSString*> *tempEditOriginImgPaths;    //图片的本地路径
@property (nonatomic, strong) NSArray<NSString*> *tempEditClearImgPaths;     //退底时的中间结果路径也叫遮罩层

//是否已经去底
- (BOOL)isCleared;

//保存时，得到需要保存的原图路径
- (NSArray*)getOriginImgPathsWhenSavework;

//保存时，得到需要保存的去底图路径
- (NSArray*)getClearImgPathsWhenSavework;


/**
 拍摄作品时，生成的作品数据

 @param imgs 拍摄的图片
 @return 作品数据
 */
+ (TSWorkModel*)workModelForTakePhotoWithImgs:(NSArray*)imgs;

#pragma mark - old 待删除或优化

@property (nonatomic, strong) NSArray<UIImage*> *imgArr; //图片数据，新建的作品，用其传递数据
@property (nonatomic, strong) NSArray<UIImage*> *imgMaskArr;

//@property (nonatomic, assign) BOOL     isSavedToLocal; //该数据信息是否已经缓存在本地了 。默认为NO

//退底部分

@property (nonatomic, strong) NSArray<UIImage*> *clearBgImgArr; //退底图片编辑后，保存到该数组，用来传递给发布页面。
@property (nonatomic, assign) BOOL isCanClearBg; //是否可以退底，即图片是否为原图。
@property (nonatomic, assign) TSWorkClearBgState clearState;  //去底状态。
@property (nonatomic, strong) NSString *clearBgWorkId; //退底作品的ID

/**
 若作品去底后，展示切换去底图和原图的按钮，保存时，存储下当前正在展示的是原图还是去底图。
 若为去底图，则showClearBg为yes，默认为NO
 */
@property (nonatomic, assign) BOOL showClearBg;

/**  退底的逻辑处理
 *   isCanClearBg 是否可以退底。当原图被破坏后便不可退底，如添加了贴图，修改了透明度等
     clearBgImgPathArr 退底之后的图片的路径保存数组。
     clearBgWorkId 退底的作品的ID,根据此ID 去服务器查找退底成功后的图片。
 
     用户退底成功，则将退底图片保存至clearBgImgPathArr 该集合的路径下
 
     编辑页面：
     用户从本地作品进入编辑页面，首先展示原图。
     若已经退底，用户点击退底，则直接从本地路径读取退底图片，并展示。
     若用户开始编辑退底图片，则将编辑后的退底图片临时保存在内存中。
     若用户点击保存，进入 发布页面，此时将退底保存的图片和原始图片都传入发布页面。
     若用户在发布页面点击保存，则对原图操作的和退底操作的作品分别直接保存。
 
     若未退底，测试用户点击退底，则直接将原图上传至服务器，且此时退底按钮不可操作。
     若用户已经编辑了本地原图图片，且未退底情况下，则退底按钮不可操作。
 */

@end
