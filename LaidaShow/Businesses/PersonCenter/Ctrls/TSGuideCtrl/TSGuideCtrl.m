//
//  TSGuideCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 21/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSGuideCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "TSProductionShowView.h"
#import "TSLoginCtrl.h"
#import "TSHelper.h"
#import "TSCourseCtrl.h"
#import "UILabel+Ext.h"

@interface TSPageCtrl : UIPageControl

@end

@interface TSGuideCtrl ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bgView1;
@property (nonatomic, strong) UIView *bgView2;
@property (nonatomic, strong) UIView *bgView3;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, weak) TSProductionShowView *showView;


@end

@implementation TSGuideCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    
    @autoreleasepool{
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH*3, SCREEN_HEIGHT)];
        self.bgView1.hidden = NO;
        self.bgView2.hidden = NO;
        self.bgView3.hidden = NO;
    }
    
    if( BOTTOM_NOT_SAVE_HEIGHT > 0 ){
        UIView *topBlueView = [UIView new];
        topBlueView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [self.bgView1 viewWithTag:9912].y);
        topBlueView.backgroundColor = [UIColor colorWithR:246 G:152 B:79];
        [self.view addSubview:topBlueView];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.showView stopAnimate];
}

- (void)dealloc{
    
    [self.showView stopAnimate];
}

- (void)handleBtn:(UIButton*)btn{
    if( btn.tag == 100 ){
        //登录
        TSLoginCtrl *lc = [TSLoginCtrl new];
        lc.fromGuide = YES;
        [self.navigationController pushViewController:lc animated:YES];
    }else{
        //随便看看
        UIViewController *rt = [TSHelper rootCtrl];
    
        @autoreleasepool{
            [UIApplication sharedApplication].keyWindow.rootViewController = rt;
            
            [TSHelper sharedHelper].guideRootCtrl = nil;
        }
    }
}

- (void)handleCourse:(id)obj{
    TSCourseCtrl *cc = [TSCourseCtrl new];
    [self.navigationController pushViewController:cc animated:YES];
}

#pragma mark - GetBgImgViews
- (UIImageView*)getBgImgViewWithImgName:(NSString*)imgName{
    UIImageView *iv = [UIImageView new];
    NSString *allName = [NSString stringWithFormat:@"%@@%dx",imgName,(int)([UIScreen mainScreen].scale)];
    NSString *path = [[NSBundle mainBundle] pathForResource:allName ofType:@"png"];
    iv.image = [UIImage imageWithContentsOfFile:path];
    
    if( iv.image == nil ) return iv;
    
    CGSize imgSize = iv.image.size;
    imgSize.height = SCREEN_WIDTH/(imgSize.width/imgSize.height);
    imgSize.width = SCREEN_WIDTH;
    
    iv.frame = CGRectMake((SCREEN_WIDTH-imgSize.width)/2, (SCREEN_HEIGHT-imgSize.height)/2, imgSize.width, imgSize.height);
    
    return iv;
}

- (UIButton*)getBtnWithTag:(NSUInteger)tag title:(NSString*)title bgHighImg:(NSString*)bgHighImgName bgColor:(UIColor*)bgColor inView:(UIView*)inView{
    UIButton *btn = [UIButton new];
    [inView addSubview:btn];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:bgHighImgName] forState:UIControlStateHighlighted];
    [btn setBackgroundColor:bgColor];
    [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma mark  - Delegate

//／／scrollview的委托方法，当滚动时执行
- (void)scrollViewDidScroll:(UIScrollView *)scrollview {
    int page = scrollview.contentOffset.x / SCREEN_WIDTH;//／／通过滚动的偏移量来判断目前页面所对应的小白点
    _pageControl.currentPage = page;//／／pagecontroll响应值的变化
}

#pragma mark - propertys

- (UIScrollView *)scrollView {
    if( !_scrollView ){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
        [self.view addSubview:self.pageControl];
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ){
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _scrollView;
}

- (UIView *)bgView1 {
    if( !_bgView1 ){
        _bgView1 = [[UIView alloc] init];
        _bgView1.backgroundColor = [UIColor whiteColor];
        _bgView1.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.scrollView addSubview:_bgView1];
        
        @autoreleasepool{
        //添加
        UIImageView *iv = [self getBgImgViewWithImgName:@"guide_two"];
        [_bgView1 addSubview:iv];
            iv.tag = 9912;
//        UIImageView *boxIv = [UIImageView new];
//        boxIv.image = [UIImage imageNamed:@"box"];
        CGFloat iw = 200,ih = 190;
//        CGPoint center = iv.center; center.y = 280;
//        boxIv.frame = CGRectMake((iv.width-iw)/2, center.y-ih/2, iw, ih);
//        boxIv.contentMode = UIViewContentModeScaleAspectFit;
//        [iv addSubview:boxIv];
        
        UILabel *desL = [UILabel new];
            desL.textColor = [UIColor colorWithRgb_0_151_216];//[UIColor colorWithR:7 G:153 B:221];//[UIColor colorWithRgb102];
        desL.font = [UIFont systemFontOfSize:24];
        desL.textAlignment = NSTextAlignmentCenter;
        desL.text = NSLocalizedString(@"GuidePageTwoTitle", nil);//@"商品拍摄助手";
            
            
        CGFloat iy = SCREEN_HEIGHT-BOTTOM_NOT_SAVE_HEIGHT-210;
            
            CGFloat designY = 972/2.0+30;
            iy = (designY)*(SCREEN_WIDTH/[self.view baseWidth]);
            iy += iv.y;
            
        CGFloat ix = 15;iw = SCREEN_WIDTH-2*ix;
        ih = [desL labelSizeWithMaxWidth:iw].height;
        desL.frame = CGRectMake(ix, iy, iw, ih);
        desL.numberOfLines = 0;
        [_bgView1 addSubview:desL];

        UILabel *bottomL = [UILabel new];
        bottomL.textColor = [UIColor colorWithRgb102];
        bottomL.font = [UIFont systemFontOfSize:15];
        bottomL.textAlignment = NSTextAlignmentCenter;
        bottomL.text = NSLocalizedString(@"GuidePageTwoSubTitle", nil);//@"适用于各个行业的拍摄神器";
        iy = desL.bottom+10;
        ih = [bottomL labelSizeWithMaxWidth:desL.width].height;
        bottomL.frame = CGRectMake(desL.x, iy, desL.width, ih);
        bottomL.numberOfLines = 2;
        [_bgView1 addSubview:bottomL];
        }
    }
    return _bgView1;
}
    
- (UIView *)bgView2 {
    if( !_bgView2 ){
        _bgView2 = [[UIView alloc] init];
        _bgView2.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgView2.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:_bgView2];
        @autoreleasepool{
        //添加
        UIImageView *iv = [self getBgImgViewWithImgName:@"guide_one"];
        [_bgView2 addSubview:iv];
        
        CGFloat iw = 200+40,ih = 190+100;
        CGPoint center = iv.center; center.y = 280;
            
        CGFloat biiy = (center.y-ih/2)/[self.view baseHeight]*iv.height;;
        TSProductionShowView *boxIv = [[TSProductionShowView alloc] initWithFrame:CGRectMake((iv.width-iw)/2, biiy, iw, ih)];
        boxIv.imgView.backgroundColor = [UIColor clearColor];
        boxIv.imgView.contentMode = UIViewContentModeScaleAspectFit;
        boxIv.userInteractionEnabled = YES;
        boxIv.clipsToBounds = YES;
        [iv addSubview:boxIv];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:36];
        for( NSUInteger i=1; i<=36; i++ ){
            NSString *name = [NSString stringWithFormat:@"%02ld",i];
            NSLog(@"guidImgName=%@",name);
//            UIImage *img = [UIImage imageNamed:name];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
//            UIImage *img = [UIImage imageWithContentsOfFile:path];
            
            //解决了一个内存问题
            NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
            UIImage * img = [UIImage imageWithData:imageData];
            if( img ){
                [arr addObject:img];
            }
        }
        
        boxIv.imgs = arr;
        [boxIv reloadData];
            
            _showView = boxIv;
        
        UILabel *desL = [UILabel new];
        desL.textColor = [UIColor colorWithRgb_0_151_216];
        desL.font = [UIFont systemFontOfSize:24];
        desL.textAlignment = NSTextAlignmentCenter;
        desL.text = NSLocalizedString(@"GuidePageOneTitle", nil);//@"商品360度展示";
        CGFloat iy = SCREEN_HEIGHT-BOTTOM_NOT_SAVE_HEIGHT-210;//boxIv.bottom+iv.y+40*4-50;
        CGFloat ix = 15;iw = SCREEN_WIDTH-2*ix;
        ih = [desL labelSizeWithMaxWidth:iw].height;
            
            CGFloat designY = 972/2.0+30;
            iy = (designY)*(SCREEN_WIDTH/[self.view baseWidth]);
            iy += iv.y;
            
        desL.frame = CGRectMake(ix, iy, iw, ih);
        desL.numberOfLines = 0;
        [_bgView2 addSubview:desL];
        
        UILabel *bottomL = [UILabel new];
        bottomL.textColor = [UIColor colorWithRgb102];
        bottomL.font = [UIFont systemFontOfSize:15];
        bottomL.textAlignment = NSTextAlignmentCenter;
        bottomL.text = NSLocalizedString(@"GuidePageOneSubTitle", nil);//@"全方位高清晰的展示商品的360度";
        iy = desL.bottom+10;
        bottomL.numberOfLines = 2;
        ih = [bottomL labelSizeWithMaxWidth:desL.width].height;
        bottomL.frame = CGRectMake(desL.x, iy, desL.width, ih);
        [_bgView2 addSubview:bottomL];
        
        _bgView2.userInteractionEnabled = YES;
        iv.userInteractionEnabled = YES;
        }
    }
    return _bgView2;
}

- (UIView *)bgView3 {
    if( !_bgView3 ){
        _bgView3 = [[UIView alloc] init];
        _bgView3.backgroundColor = [UIColor whiteColor];
        _bgView3.frame = CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.scrollView addSubview:_bgView3];
        @autoreleasepool{
        //添加
        UIImageView *iv = [self getBgImgViewWithImgName:@"guide_three"];
        [_bgView3 addSubview:iv];
        
        UIImageView *boxIv = [UIImageView new];
//        boxIv.image = [UIImage imageNamed:@"computer"];
            CGFloat iw = 230,ih = 195;//iw/(boxIv.image.size.width/boxIv.image.size.height);
        CGPoint center = iv.center; center.y = 280;
            CGFloat biy = 192/[self.view baseHeight]*iv.height;
        boxIv.frame = CGRectMake((iv.width-iw)/2, biy, iw, ih);
//        boxIv.contentMode = UIViewContentModeScaleAspectFit;
        [iv addSubview:boxIv];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCourse:)];
        [boxIv addGestureRecognizer:tap];
        boxIv.userInteractionEnabled = YES;
        iv.userInteractionEnabled = YES;
        _bgView3.userInteractionEnabled = YES;
        
        UILabel *desL = [UILabel new];
        desL.textColor = [UIColor colorWithRgb102];
        desL.font = [UIFont systemFontOfSize:14];
        desL.textAlignment = NSTextAlignmentCenter;
//        desL.text = @"点击视频了解更多";
        desL.text = NSLocalizedString(@"GuidePageThreeKnowMoreText", nil);
        CGFloat iy = boxIv.bottom;
//            //若是PLus，则加高度
//            if( [UIScreen mainScreen].scale == 3 && BOTTOM_NOT_SAVE_HEIGHT <=0 ){
//                iy = boxIv.bottom+15;
//            }
            CGFloat originYAtPhoto = 755/2.0+5; //图片上的Y
            iy = (originYAtPhoto)*(SCREEN_WIDTH/[self.view baseWidth]);
            
        desL.frame = CGRectMake(0, iy, iv.width, 40);
        [iv addSubview:desL];
        
        UIButton *loginBtn = [self getBtnWithTag:100 title:NSLocalizedString(@"GuidePageThreeLoginBtnTitle", nil) bgHighImg:@"btn_bg_blue_hi" bgColor:[UIColor colorWithRgb_0_151_216] inView:_bgView3];
        
        UIButton *seeBtn = [self getBtnWithTag:101 title:NSLocalizedString(@"GuidePageThreeGotoHomePageBtnTitle", nil) bgHighImg:@"btn_bg_disable220" bgColor:[UIColor colorWithWhite:0 alpha:0.35] inView:_bgView3];
        
        ih = 35;iw = [loginBtn.titleLabel labelSizeWithMaxWidth:160].width+20;
        if( iw < 120 ) iw = 120;
        CGFloat yGap = 15;
        iy = SCREEN_HEIGHT-(130+BOTTOM_NOT_SAVE_HEIGHT)-2*ih-yGap;
            
            CGFloat designY = 972/2.0+30;
            iy = (designY)*(SCREEN_WIDTH/[self.view baseWidth]);
            iy += iv.y;
            
        loginBtn.frame = CGRectMake((SCREEN_WIDTH-iw)/2, iy, iw, ih);
        seeBtn.frame = CGRectMake(loginBtn.x, loginBtn.bottom+yGap, loginBtn.width, loginBtn.height);
        
        [seeBtn cornerRadius:ih/2];
        [loginBtn cornerRadius:ih/2];
        }
    }
    return _bgView3;
}

- (UIPageControl *)pageControl {
    if( !_pageControl ){
        _pageControl = [[TSPageCtrl alloc] init];
        CGFloat ih = 20,iw = 20;
        CGFloat iy = SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT-30;
        _pageControl.frame = CGRectMake((SCREEN_WIDTH-iw)/2, iy, iw, ih);//指定位置大小
        _pageControl.numberOfPages = 3;//指定页面个数
        _pageControl.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.2];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRgb_0_151_216];
//    [_pageControl addTarget:selfaction:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        //添加委托方法，当点击小白点就执行此方法
        
//        [_pageControl setTransform:CGAffineTransformMakeScale(2.5, 1)];
    }
    return _pageControl;
}

@end


@implementation TSPageCtrl

//- (void)setCurrentPage:(NSInteger)currentPage{
//    [super setCurrentPage:currentPage];
//
//    for( NSUInteger i=0; i<self.subviews.count; i++ ){
//        UIView *subView = self.subviews[i];
//        CGRect fr = subView.frame;
//        fr.size.width = 5;
//        subView.frame = fr;
//    }
//}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat iw = 16,gap = 8;
    NSInteger i=0;
    CGFloat startX = self.width/2-iw/2-iw-gap;
    for( UIView *subView in self.subviews ){
        CGRect fr = subView.frame;
        fr.size.width = iw;
        fr.origin.x = i*(iw+gap)+startX;
        fr.size.height = 5;
        fr.origin.y = (self.height-5)/2;
        subView.frame = fr;
        
        [subView cornerRadius:2.5];
        
        i++;
    }
}

@end
