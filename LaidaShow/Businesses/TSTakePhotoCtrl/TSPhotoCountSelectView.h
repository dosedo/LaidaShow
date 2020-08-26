//
//  TSPhotoCountSelectView.h
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSPhotoCountSelectView : UIView
@property (nonatomic, strong) NSArray<NSString*> *titles;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UILabel *titleL;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)reloadDatas;

@end
