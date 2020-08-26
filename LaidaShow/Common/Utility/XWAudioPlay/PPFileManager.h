//
//  PPFileManager.h
//  PaiPai
//
//  Created by wkun on 12/27/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  文件管理类，主要管理合成的360度长图片资源以及抠图合成的图片资源，和抠图模板资源。录音文件管理。
 */
@interface PPFileManager : NSObject


+(PPFileManager*)sharedFileManager;

#pragma mark - 得到路径


/**
 得到三围秀缓存本地作品的路径。不计入缓存大小中。

 @param imgAllName 图片全名
 @return 图片存储路径。
 */
- (NSString *)getSanWorkImgPathWithImgAllName:(NSString *)imgAllName;
- (NSString *)getSanWorkLocalImgPathWithImgAllName:(NSString *)imgAllName localPath:(NSString*)localPath;

- (BOOL)saveSanweishowLocalImgToNotClearPath:(UIImage*)img type:(NSInteger)type paths:(NSString *)paths imgAllName:(NSString*)imgAllName;


- (NSString*)getDocumentsDir;

/**
 得到某个作品的某个图片的本地全路径

 @param imgAllName 图片的全名，包括扩展名
 @return 图片path ,若图片不存在，则返回nil
 */
- (NSString*)getSanweishowWorkImgWithImgAllName:(NSString*)imgAllName;

/**
 *  得到制作360度图片过程时，用到的结果图片路径
 *
 *  @index 制作过程的索引。每次进入拍照界面，都会清空result图片
 *  @return 制作360度图片过程时，存放结果图片的路径。
 */
-(NSString*)getMakeResultImgPathWithIndex:(NSUInteger)index;

/**
 *  得到制作(360度图片制作和抠图制作)结果的路径，
 *
 *  @return 360度图片与抠图图片的路径
 */
-(NSString*)getResultImgPath;

/**
 *  根据模板名字得到其路径
 *
 *  @param templateName 模板的名字
 *
 *  @return 模板img的路径
 */
-(NSString*)getTemplateImgPathWithImgName:(NSString*)templateName;

/**
 *  得到抠图结果的路径
 *
 *  @return 抠图结果路径
 */
-(NSString*)getKouTuResultImgPath;

/**
 *  得到抠图时背景图片的路径
 *
 *  @param imgPath 图片的名字
 *
 *  @return 背景图路径
 */
-(NSString*)getKouTuBgImgPathWithName:(NSString*)imgName;

/**
 *  得到录音文件的全路径
 *
 *  @param fileName 文件的全名，含有扩展名
 *  @param isCanClear 是否能够被清除
 *  @return 文件的全路径
 */
-(NSString*)getAudioFilePathWithFileAllName:(NSString*)fileName isCanClear:(BOOL)isCanClear;

/**
 *  得到录音文件的临时路径
 *
 *  @param fileName 录音文件名
 *
 *  @return 录音文件的临时路径
 */
-(NSString*)getAudioFileTmpPathWithFileAllName:(NSString*)fileName;

#pragma mark - 移动文件
/**
 *  移动音频文件到不可删除目录
 *
 *  @param fileAllName 待移动的文件的全名
 *
 *  @return 成功YES，失败NO
 */
-(BOOL)moveAuidoFileToNotClearPathWithFileName:(NSString*)fileAllName;

#pragma mark - 保存和移除

/**
 保存三维秀 的一个产品的所有图片到不可删除的图片缓存路径

 @param img 图片 以JPG的数据形式保存在本地
 @param imgAllName 图片名字 带有扩展名
 @return 成功yes 否则NO
 */
- (BOOL)saveSanweishowImgToNotClearPath:(UIImage*)img imgAllName:(NSString*)imgAllName;

/**
 根据图片全路径删除图片
 
 @param imgAllPath 图片的全路径，包括拓展名
 @return 成功YES 否则NO
 */
- (BOOL)removeSanwieshowImgWithImgAllPath:(NSString*)imgAllPath;

/**
 *  保存模板图片到本地
 *
 *  @param templateName 模板名字 
 *  @param tmpImg 模板图片
 *
 *  @return YES成功，NO失败
 */
-(BOOL)saveTemplateImgWithImgName:(NSString*)templateName image:(UIImage*)tmpImg;

/**
 *  保存图片到本地
 *
 *  @param img 将要保存的图片
 *
 *  @return YES,保存成功； NO，保存失败
 */
-(BOOL)saveResultImg:(UIImage*)img;

/**
 *  保存抠图背景图片
 *
 *  @param bgImg   将要保存的背景图
 *  @param imgName 将要保存的背景图的名字
 *
 *  @return YES成功，NO失败
 */
-(BOOL)saveKouTuBgImg:(UIImage*)bgImg imgName:(NSString*)imgName;

/**
 *  移除抠图所产生的文件。（除模板文件外的所有文件）
 *
 *  @return YES成功，NO失败
 */
-(BOOL)removeKouTuImg;

/**
 *  移除360度制作过程时，创建的图片
 *
 *  @return YES成功，NO失败
 */
-(BOOL)removeMakeResultImg;

/**
 *  移除模板图片
 *
 *  @return YES成功，NO失败
 */
-(BOOL)removeTemplateImg;

/**
 根据全路径移除文件

 @param fileAllPath 文件的全路径，包括扩展名
 @return 成功yes 失败no
 */
- (BOOL)removeFileAtAllPath:(NSString*)fileAllPath;

/**
 *  清除缓存
 */
-(void)clearCache;

@end
