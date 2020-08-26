//
//  TSMyWorkCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "XWPageViewCtrl.h"

/**
 我的作品集合。本地，线上，和收藏。
 */
@interface TSMyWorkCtrl : XWPageViewCtrl
- (id)initWithSelectedItemIdx:(NSUInteger)idx;

-(void)reloadData;

-(void)setCurrSelectedItemIndex:(NSUInteger)idx;
@end
