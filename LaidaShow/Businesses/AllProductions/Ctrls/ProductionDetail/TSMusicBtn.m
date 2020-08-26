//
//  TSMusicBtn.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSMusicBtn.h"

@implementation TSMusicBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGSize imgSize = self.currentImage.size;
    return CGRectMake(15, (contentRect.size.height-imgSize.height)/2, imgSize.width, imgSize.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGSize imgSize = self.currentImage.size;
    CGFloat ix = 15;
    ix = imgSize.width+2*ix;
    return CGRectMake(ix, 0, contentRect.size.width-ix, contentRect.size.height);
}

@end
