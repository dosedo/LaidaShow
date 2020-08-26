//
//  TSSelectWaterMarkView.m
//  ThreeShow
//
//  Created by DeepAI on 2019/1/27.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import "TSSelectWaterMarkView.h"
#import "UIButton+WebCache.h"
#import "UIView+LayoutMethods.h"
#import "TSHttpRequest.h"
#import "TSDataProcess.h"
#import "TSUserModel.h"
#import "UIViewController+Ext.h"

static NSInteger const gBaseTag = 100;
static CGFloat   const gBtnWidth = 60;

@interface TSSelectWaterMarkView()

//@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIScrollView *waterMarkScollView;

@end

@implementation TSSelectWaterMarkView

#pragma mark - Public

- (void)addWatermarkWithImg:(UIImage *)img{
    
    if( [self isLimitToMaxCount] ) return;
    
    NSMutableArray *arr = nil;
    if( self.datas.count == 0 ){
        arr = [NSMutableArray new];
    }else{
        arr = [NSMutableArray arrayWithArray:_datas];
    }
    
    [arr insertObject:img atIndex:0];
    
    _datas = arr;
    
    [self reloadData];
}

- (void)reloadData{
    
    //每次重新加载数据，都将所有Btn隐藏
    for( UIButton *btn in self.waterMarkScollView.subviews ){//scrollView中的button
        if( [btn isKindOfClass:[UIButton class]] ){
            btn.hidden = YES;
        }
    }
    
    CGFloat btnW = gBtnWidth;
    CGFloat btnGap = 15;
    CGFloat waterMarkViewH = CGRectGetHeight(_waterMarkScollView.frame);
    if( waterMarkViewH <=0 ) waterMarkViewH = gBtnWidth;
    for( NSInteger i=0; i<self.datas.count; i++ ){
        
        NSInteger tag = i+gBaseTag;
        UIButton *btn = [self.waterMarkScollView viewWithTag:tag];
        if( btn == nil ){
            btn = [TSSelectWaterMarkViewBtn new];
            btn.tag = tag;
            //给这些button添加长按删除手势
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
            //长按等待时间
            longPressGest.minimumPressDuration = 1;
            [btn  addGestureRecognizer:longPressGest];
            [self.waterMarkScollView addSubview:btn];
            
            //设置按钮的基本属性
            btn.frame = CGRectMake((btnW+btnGap)*i, 0, btnW, waterMarkViewH);
            [btn addTarget:self action:@selector(hanleImgBtn:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            btn.hidden = NO;
        }
        
        btn.selected = NO;
        
        UIImage *img = _datas[i];
        if( [img isKindOfClass:[UIImage class]] ){
            //图片
            [btn setBackgroundImage:img forState:UIControlStateNormal];
        }
        else if( [img isKindOfClass:[NSString class]] ){
            NSString *imgUrl = (NSString*)img;
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal];
        }
    }
    
    CGFloat cw = btnW*_datas.count + btnGap*(_datas.count);
    [self.waterMarkScollView setContentSize:CGSizeMake(cw, waterMarkViewH)];
    
    //每次加载数据，更新图片视图的frame
    [self updateWaterMarkViewFrameWithIsToMax:[self isLimitToMaxCount]];
}

#pragma mark - Private

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.addBtn.frame = CGRectMake(0, 0, gBtnWidth, self.height);
    [self updateWaterMarkViewFrameWithIsToMax:[self isLimitToMaxCount]];
}

- (BOOL)isLimitToMaxCount{
    NSInteger maxCount = self.imgMaxCount;
    if( maxCount <=0 ) maxCount = 5;
    if( self.datas.count >= maxCount ){
        return YES;
    }
    return NO;
}

- (void)updateWaterMarkViewFrameWithIsToMax:(BOOL)isToMax{
    CGFloat ix = 0;
    if( isToMax ){
        ix = self.addBtn.x;
    }else{
        ix = self.addBtn.right+15;
    }
    self.addBtn.hidden = isToMax;
    self.waterMarkScollView.frame = CGRectMake(ix, 0, self.width-ix, self.height);
}

#pragma mark - TouchEvents
- (void)hanleImgBtn:(UIButton*)btn{
    
    //将所有的其他按钮都置为不选中，即边框为灰色
    for( UIButton *tempBtn in self.waterMarkScollView.subviews ){
        if( [tempBtn isKindOfClass:[UIButton class]] ){
            tempBtn.selected = NO;
        }
    }
    btn.selected = YES;
    
    if( self.selectBlock ){
        
        _selectedIndex = btn.tag - gBaseTag;
        self.selectBlock((btn==self.addBtn), [btn backgroundImageForState:UIControlStateNormal]);
    }
}

#pragma mark - Propertys

- (UIButton *)addBtn{
    if( !_addBtn ){
        _addBtn = [UIButton new];
        
        //_addBtn.backgroundColor = [UIColor redColor];
        [_addBtn setBackgroundImage:[UIImage imageNamed:@"refoot_add"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(hanleImgBtn:) forControlEvents:UIControlEventTouchUpInside];
//        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
//        //长按等待时间
//        longPressGest.minimumPressDuration = 0.2;
//        [_addBtn  addGestureRecognizer:longPressGest];
        [self addSubview:_addBtn];
        
        [self bringSubviewToFront:self.waterMarkScollView];
    }
    return _addBtn;
}

- (UIScrollView *)waterMarkScollView{
    if( !_waterMarkScollView ){
        _waterMarkScollView = [HTScrollView new];
        
        [self addSubview:_waterMarkScollView];
    }
    return _waterMarkScollView;
}

-(void)longPress:(UILongPressGestureRecognizer*)gestureRecognizer{
    
    UIView *tapView = gestureRecognizer.view;
    if( [tapView isKindOfClass:[UIButton class]] ){
        NSInteger idx = tapView.tag - gBaseTag;
        if( self.deleteBlock ){
            self.deleteBlock(idx);
        }
    }
//    if([gestureRecognizer state] ==UIGestureRecognizerStateBegan){
//        
//        NSLog(@"长按事件");
//        for (NSUInteger i = self.datas.count;i > 0 ; i--) {
//            NSInteger tag = i+gBaseTag;
//            [[self.waterMarkScollView viewWithTag:tag] removeFromSuperview];
//        }
//    }
}

@end



@implementation HTScrollView

- (id)init{
    self = [super init];
    if( self )
    {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initSelf];
    }
    return self;
}

- (void)initSelf{
    //为了防止，uibutton 加在tableview上后，没有效果的问题
    self.canCancelContentTouches = YES;
    self.delaysContentTouches = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}




//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    UIView *view = touch.view;
//    if ([view isKindOfClass:[UITableView class]] || [@"UITableViewCellContentView" isEqualToString:[[view class] description]] )
//    {
//        return NO;
//    }
//
//    return YES;
//}

@end


@implementation TSSelectWaterMarkViewBtn

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRgb221].CGColor;
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    if( self.selected == selected ) return;
    
    if( selected ){
        self.layer.borderColor = [UIColor colorWithRgb_20_150_216 ].CGColor;
    }else
        self.layer.borderColor = [UIColor colorWithRgb221].CGColor;
    
    [super setSelected:selected];
}

@end
