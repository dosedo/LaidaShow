//
//  TSHomeProductionCtrl.h
//  ThreeShow
//
//  Created by cgw on 2018/9/25.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "XWPageViewCtrl.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSHomeProductionCtrl : XWPageViewCtrl
- (id)initWithSelectedItemIdx:(NSUInteger)idx;

-(void)reloadData;

-(void)setCurrSelectedItemIndex:(NSUInteger)idx;
@end

NS_ASSUME_NONNULL_END
