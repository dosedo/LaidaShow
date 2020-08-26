//
//  TSPathManager.h
//  ThreeShow
//
//  Created by cgw on 2019/1/30.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 路径管理，所有的本地路径。由该类进行管理，返回的路径最后的一个路径都不带/
 */
@interface TSPathManager : NSObject

+ (TSPathManager*)sharePathManager;


#pragma mark - Public

/**
 得到Document的路径
 
 @return document的全路径
 */
- (NSString *)getDocPath;


/**
 得到document和pathSuffix拼接后的路径,若路径不存在，则创建；存在，则直接放回
 
 @param pathSuffix 路径后缀
 @return document拼接pathSuffix后的全路径
 */
- (NSString*)getDocPathWithSuffix:(NSString*)pathSuffix;

#pragma mark - 拍照的作品的名字
- (NSString*)takePhotoWorkImgDirName;

#pragma mark - 本地作品路径

/**
 新的作品目录名，生成规则：workimg+时间戳

 @return 新的作品目录名
 */
- (NSString*)getNewWorkDirName;

/**
 作品原图的路径

 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 原图文件所在的全路径
 */
- (NSString*)getWorkOriginImgPathWithWorkDirName:(NSString*)workDirName fileAllName:(NSString*)fileAllName;

/**
 作品去底的遮罩图(也叫去底中间图)的路径
 
 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 这招图文件所在的全路径
 */
- (NSString*)getWorkMaskImgPathWithWorkDirName:(NSString *)workDirName fileAllName:(NSString *)fileAllName;

/**
 作品去底图的路径
 
 @param workDirName 作品的目录名
 @param fileAllName 图片文件的全名，包含扩展名
 @return 去底图文件所在的全路径
 */
- (NSString*)getWorkClearImgPathWithWorkDirName:(NSString *)workDirName fileAllName:(NSString *)fileAllName;

/**
 作品原图的父路径，即图片所在的目录，带有 /
 
 @param workDirName 作品的目录名
 @return 原图文件所在的全路径
 */
- (NSString*)getWorkOriginImgPathWithWorkDirName:(NSString*)workDirName;

/**
 作品去底的遮罩图(也叫去底中间图)的父路径，即图片所在的目录
 
 @param workDirName 作品的目录名
 @return 这招图文件所在的全路径
 */
- (NSString*)getWorkMaskImgPathWithWorkDirName:(NSString *)workDirName;

/**x
 作品去底图的父路径，即去底图所在的目录
 
 @param workDirName 作品的目录名
 @return 去底图文件所在的全路径
 */
- (NSString*)getWorkClearImgPathWithWorkDirName:(NSString *)workDirName;

/**
 将path中包含的沙盒doc路径 替换为 当前沙盒的doc路径

 @param path 待替换的路径
 @return 返回替换沙盒doc后的新路径
 */
- (NSString*)getNewPathByReplaceOldDocPathWithPath:(NSString*)path;

- (NSString*)getLocalWorkDocNameFromWorkPath:(NSString*)workPath;

@end

NS_ASSUME_NONNULL_END
