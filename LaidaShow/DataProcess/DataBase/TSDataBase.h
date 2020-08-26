//
//  TSDataBase.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class TSWorkModel;
@class TSUserModel;
@interface TSDataBase : NSObject

+ (TSDataBase*)sharedDataBase;

- (NSString*)getDbPathWithName:(NSString*)name;

//得到图片缓存的目录
- (NSString*)getImgCacheDir;

#pragma mark - Cache

//清除本地缓存
- (void)clearCache;

//缓存大小,单位M
- (CGFloat)cacheSize;

#pragma mark - User
- (TSUserModel*)userModel;

- (void)updateUserModel:(TSUserModel*)um;

- (void)removeUserModel;

#pragma mark - 历史搜索记录缓存

- (BOOL)insertHistorySearchWord:(NSString*)word;

- (NSArray<NSString *> *)historySearchDatas;

- (BOOL)deleteHistorySearchDatas;

- (BOOL)deleteHistoryWithText:(NSString*)text;

#pragma mark - 视频作品的本地缓存

/**
 获取本地作品

 @param pageIndex 第几页
 @param isVideoWork 是否为视频作品
 @return 作品集合
 */
- (NSArray<TSWorkModel*>*)localWorkDatasWithPageIndex:(NSInteger)pageIndex isVideoWork:(BOOL)isVideoWork;
- (BOOL)insertLocalWorkModel:(TSWorkModel*)wm;
- (BOOL)updateLocalWorkModel:(TSWorkModel*)wm;
- (BOOL)deleteLocalWorkWithWorkId:(NSString*)wid;

@end
