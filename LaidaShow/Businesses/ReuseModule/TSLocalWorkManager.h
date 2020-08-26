//
//  TSLocalWorkManager.h
//  ThreeShow
//
//  Created by cgw on 2019/1/30.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TSWorkModel;

/**
 本地作品管理
 */
@interface TSLocalWorkManager : NSObject

- (void)saveWorkToLocalWithWorkModel:(TSWorkModel*)workModel localWorkModel:(TSWorkModel*)localWorkModel;

@end

NS_ASSUME_NONNULL_END
