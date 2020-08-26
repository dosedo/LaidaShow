//
//  TSTakedPhotoListView.h
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 一个作品，已拍下的照片的list，横向列表
 */
@interface TSTakedPhotoListView : UIView

@property (nonatomic, assign) NSInteger itemCount; //总数量

- (id)initWithItemSize:(CGSize)itemSize;

//设置完frame 方可调用 以及总数量
- (void)reloadData;

- (void)addImg:(UIImage*)img;

@end
