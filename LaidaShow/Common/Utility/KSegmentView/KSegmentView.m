//
//  KSegmentView.m
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/16.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import "KSegmentView.h"

static NSUInteger  const defaultSelIndex = 0;

@implementation KSegmentView{
    UISegmentedControl *_segment;
    NSInteger _selectedItemIndex;
}

@synthesize seletedItemIndex = _selectedItemIndex;

-(id)initWithFrame:(CGRect)frame titles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if( self){
        _defalutSelctIndex = defaultSelIndex;
        
        self.frame = frame;
        
        CGFloat gap = 10;
        CGSize viewSize = frame.size;
        CGFloat iw = 240;//328;
        CGFloat ih = 35;
        if( viewSize.width <= iw ){
            iw = viewSize.width-2*2*gap;
        }
        
        CGRect fr = CGRectMake((viewSize.width - iw)/2, (viewSize.height-ih)/2, iw, ih);
        _segment = [[UISegmentedControl alloc] initWithFrame:fr];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
        [_segment setTitleTextAttributes:dic forState:UIControlStateNormal];
        [self addSubview:_segment];
        NSUInteger i=0;
        for( NSString *title in titles ){
            if( [title isKindOfClass:[NSString class]] )
                [_segment insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
            i++;
        }
        [self configSegment];
        
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    
    _segment.backgroundColor = self.backgroundColor;
}

-(void)handleSegment:(UISegmentedControl*)segment{
    if( _delegate && [_delegate respondsToSelector:@selector(segmentView:didSelectItemAtIndex:)] ){
        _selectedItemIndex = _segment.selectedSegmentIndex;
        [_delegate segmentView:self didSelectItemAtIndex:_segment.selectedSegmentIndex];
    }
}

-(void)setDefalutSelctIndex:(NSInteger)defalutSelctIndex{
    _defalutSelctIndex = defalutSelctIndex;
    
    [_segment setSelectedSegmentIndex:_defalutSelctIndex];
    _selectedItemIndex = _defalutSelctIndex;
}

- (NSInteger)seletedItemIndex{
    return _selectedItemIndex;
}

/**
 *  设置segment的风格颜色等
 */
-(void)configSegment{
    [_segment setSelectedSegmentIndex:_defalutSelctIndex];
    _selectedItemIndex = _defalutSelctIndex;
    _segment.tintColor = [self segmentColor];
    _segment.backgroundColor = [UIColor whiteColor];
    [_segment addTarget:self action:@selector(handleSegment:) forControlEvents:UIControlEventValueChanged];
}

-(UIColor*)segmentColor{
    return [UIColor colorWithRed:24/255.0 green:148/255.0 blue:209.0/255 alpha:1.0];
}

@end
