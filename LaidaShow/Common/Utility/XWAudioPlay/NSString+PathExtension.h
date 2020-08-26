//
//  NSString+PathExtension.h
//  PaiPai
//
//  Created by wkun on 12/22/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  NSString(PathExtension )

/**
 *  获取path的文件名，不含有扩展名
 *
 *  @return path的文件名
 */
-(NSString*)pathLastName;

@end
