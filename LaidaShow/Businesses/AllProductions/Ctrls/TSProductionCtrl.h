//
//  TSProductionCtrl.h
//  ThreeShow
//
//  Created by cgw on 2018/9/25.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSProductionCtrl : UIViewController

- (id)initWithCategory:(NSString*)category;

- (void)reloadData;

- (void)cancleLoadingData;
@end

NS_ASSUME_NONNULL_END
