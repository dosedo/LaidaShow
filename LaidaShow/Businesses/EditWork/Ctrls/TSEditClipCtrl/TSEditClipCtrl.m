//
//  TSEditClipCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditClipCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSClipView.h"
#import "TSEditNaviView.h"
#import "TSEditWorkCtrl.h"
#import "HTProgressHUD.h"

@interface TSEditClipCtrl ()<UIScrollViewDelegate,TSClipViewDelegate>
@property (nonatomic, strong) TSClipView *clipView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIScrollView *imgScrollView;
@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSEditClipCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetDatas{
    self.imgView.image = _imgs[0];
    
    self.clipView.hidden = NO;
    
    [self updateLayout];
}

#pragma mark - Private

- (void)updateLayout{
    CGSize imgSize = self.imgView.image.size;
    CGSize cntSize = imgSize;
    CGFloat ix = 0,iy = 0;
    if( cntSize.width < self.imgScrollView.width ){
        cntSize.width = self.imgScrollView.width;
        ix = (self.imgScrollView.width-imgSize.width)/2;
    }
    if( cntSize.height < self.imgScrollView.height ){
        cntSize.height = self.imgScrollView.height;
        iy = (self.imgScrollView.height-imgSize.height)/2;
    }
    
    CGFloat iw = imgSize.width,ih = imgSize.height;
    CGFloat scale = 1.0;
    if( ix <=0 || iy <= 0 ){
        
        if( _imgScrollView.height/_imgScrollView.width > ih/iw ){
            //按宽缩放，即最大宽度为scrollview的宽度
            ih = ih/iw*_imgScrollView.width;
            scale = iw/_imgScrollView.width;
            iw = _imgScrollView.width;
        }
        else{
            //按高缩放
            iw = iw/ih*_imgScrollView.height;
            scale = ih/_imgScrollView.height;
            ih = _imgScrollView.height;
        }
    }
    
    ix = (_imgScrollView.width-iw)/2;iy=(_imgScrollView.height-ih)/2;
    self.imgView.frame = CGRectMake(ix, iy, iw, ih);

//暂时不缩放了
//    [self.imgScrollView setZoomScale:scale];
    
    ih = _imgView.height;
    iy = _imgView.y;
//    if( self.imgView.height > self.imgScrollView.height ){
//        ih = self.imgScrollView.height;
//        iy = 0;
//    }
    
    iw = _imgView.width;
    ix = self.imgView.x;
//    if( iw > self.imgScrollView.width ){
//        iw = self.imgScrollView.width;
//        ix = 0;
//    }
    
    [self.clipView setViewSize:CGSizeMake(iw, ih)];
    self.clipView.frame = CGRectMake(ix, iy, iw, ih);
}

- (NSArray*)clipImgWithRect:(CGRect)fr{
    NSMutableArray *newArr = [NSMutableArray new];
    
    NSUInteger i=0;
    for( UIImage *image in self.imgs ){

        CGFloat scale = (image.size.width/(self.imgView.width));
        CGRect rect = fr;
        rect.size.width *= scale;
        rect.size.height *= scale;
        rect.origin.x *= scale;
        rect.origin.y *= scale;
        
        @autoreleasepool{
            CGImageRef ir = CGImageCreateWithImageInRect([image CGImage], rect);
            UIImage *newImg =[UIImage imageWithCGImage:ir];
            CGImageRelease(ir);
            newImg = [self regetModifyImg:newImg atIndex:i];
    //        UIImageWriteToSavedPhotosAlbum(newImg, nil, nil, nil);
            if( newImg )
                [newArr addObject:newImg];
            
            i++;
        }
    }
    return newArr;
}
    
- (UIImage*)regetModifyImg:(UIImage*)myImage atIndex:(NSUInteger)idx{
    if( myImage ){
        NSString *tempImgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"editClipImgTemp%ld.jpg",idx]];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isExist = [fm fileExistsAtPath:tempImgPath];
        if( isExist ){
            [fm removeItemAtPath:tempImgPath error:nil];
        }
        
        //        NSData *data = [myImage initWithData:nil];
        [UIImageJPEGRepresentation(myImage, 1) writeToFile:tempImgPath atomically:YES];
        
        myImage = nil;
        
        NSData *imageData = [NSData dataWithContentsOfFile:tempImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage * img = [UIImage imageWithData:imageData];
        imageData = nil;
        
        return img;
    }
    return nil;
}

#pragma mark - TouchEvents
- (void)handleClose{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave{
    
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkEditSaveingImgs", nil) toView:self.view];
    [self dispatchAsyncQueueWithName:@"clipImgQ" block:^{
        NSArray *arr = nil;
        if( self.clipView.pointArr.count == 4 ){
            CGPoint pa = ((NSValue*)(_clipView.pointArr[0])).CGPointValue;
            CGPoint pc = ((NSValue*)(_clipView.pointArr[2])).CGPointValue;
            CGRect fr = CGRectMake(pa.x, pa.y, pc.x-pa.x, pc.y-pa.y);
            arr = [self clipImgWithRect:fr];
        }
        
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            [self.editWorkCtrl clipImgComplete:arr];
            [self handleClose];
        }];
    }];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imgView;
}

- (void)dragSelectAreaEnd:(TSClipView *)view{
    
}

#pragma mark - Propertys

- (TSClipView *)clipView {
    if( !_clipView ){
        _clipView = [[TSClipView alloc] initWithFrame:CGRectZero];
        _clipView.delegate = self;
        _clipView.isCanMove = NO; //选区不准超越边框
        [self.view addSubview:_clipView];
    }
    return _clipView;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.imgScrollView.height);
        _imgView.userInteractionEnabled = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imgScrollView addSubview:_imgView];
    }
    return _imgView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomClipText", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        
        [self.view addSubview:_naviView];
    }
    return _naviView;
}

- (UIScrollView *)imgScrollView {
    if( !_imgScrollView ){
        _imgScrollView = [[UIScrollView alloc] init];
        _imgScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.naviView.y);
        _imgScrollView.minimumZoomScale = 1;
        _imgScrollView.maximumZoomScale = 2;
        _imgScrollView.delegate = self;
        _imgScrollView.userInteractionEnabled = NO;
        [self.view addSubview:_imgScrollView];
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ){
            _imgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            _imgScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _imgScrollView;
}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

@end
