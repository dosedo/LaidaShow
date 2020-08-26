//
//  PPLocalFileManager.h
//  PaiPai
//
//  Created by wkun on 12/22/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  图片信息的本地缓存 管理
 */
@interface PPLocalFileManager : NSObject



+(PPLocalFileManager*)shareLocalFileManager;
/**
 *  得到所有本地文件信息
 *
 *  @return TSWorkModel实例的集合
 */
-(NSArray*)getLocalFilesInfo;
/**
 *  保存文件信息到本地
 *
 *  @param fileInfoModel TSWorkModel实例
 */
-(void)saveFileToLocal:(id)fileInfoModel;

///移除文件根据INDEX
-(BOOL)removeFileWithIndex:(NSUInteger)index;

//更新某索引下的数据模型
-(BOOL)updateModel:(id)model atIndex:(NSUInteger)index;

@end
