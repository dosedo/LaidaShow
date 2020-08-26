//
//  TSTakedPhotoListView.m
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSTakedPhotoListView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"

@interface TSTakedPhotoListView()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIImageView*> *itemViews;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) NSInteger lastImgIndex; //上一个图片所在的索引


@end

@implementation TSTakedPhotoListView

- (id)initWithItemSize:(CGSize)itemSize{
    self = [super initWithFrame:CGRectZero];
    if( self ){
        _itemSize = itemSize;
    }
    return self;
}

- (void)reloadData{
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _lastImgIndex = -1;
    CGFloat xGap = 5;
    CGFloat maxCountF = self.width/(_itemSize.width+xGap);
    
    NSInteger maxCount = (int)maxCountF;
    if( maxCountF > (int)maxCountF ){
        maxCount ++;
    }
    
    NSUInteger itemViewCount = maxCount +1;
    if( _itemCount < itemViewCount ){
        itemViewCount = _itemCount;
    }
    self.scrollView.contentSize = CGSizeMake(_itemCount*(_itemSize.width+xGap), self.height);
    [self.scrollView setContentOffset:CGPointZero];
    
    [self.itemViews removeAllObjects];
    for( NSUInteger i=0; i<itemViewCount; i++ ){
        UIImageView *iv = [UIImageView new];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        CGFloat ix = (_itemSize.width+xGap)*i;
        iv.frame = CGRectMake(ix, 0, _itemSize.width, _itemSize.height);
        [self.scrollView addSubview:iv];
        [self.itemViews addObject:iv];
    }
}

- (void)addImg:(UIImage *)img{
    _lastImgIndex ++;
    
    if( _lastImgIndex < _itemCount && _lastImgIndex >=0 ){
        CGFloat xGap = 5;
        UIImageView *iv = nil;
        if( _lastImgIndex < self.itemViews.count ){
            iv = _itemViews[_lastImgIndex];
            iv.image = img;
        }else{
        
            iv = _itemViews[0];
            iv.image = img;
            CGRect fr = iv.frame;
            fr.origin.x = _lastImgIndex*(_itemSize.width+xGap);
            iv.frame = fr;
            [_itemViews removeObjectAtIndex:0];
            [_itemViews addObject:iv];
        }
        
        CGFloat offX = iv.right+xGap-_scrollView.width;
        if( iv && offX > 0  ){
            [self.scrollView setContentOffset:CGPointMake(offX, 0) animated:YES];
        }
    }
}

#pragma mark - Propertys

- (UIScrollView *)scrollView {
    if( !_scrollView ){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.frame = CGRectMake(0, 0, self.width, self.height);
        _scrollView.scrollEnabled = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray<UIImageView *> *)itemViews {
    if( !_itemViews ){
        _itemViews = [[NSMutableArray alloc] init];
    }
    return _itemViews;
}

@end
