//
//  TSWorkReleaseView.h
//  ThreeShow
//
//  Created by hitomedia on 17/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSWorkReleaseView : UIView
+ (TSWorkReleaseView*)shareWorkReleaseView;

+ (void)showWithHandleIndexBlock:(void(^)(NSInteger index, BOOL isSaveToLocal, BOOL isOnlySelfSee))handleIndexBlock;
@end
