//
//  TSEditModifyCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditModifyCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "TSEditWorkCtrl.h"
#import "TSEditNaviView.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"

static NSUInteger const gTagBase = 100;
@interface TSEditModifyCtrl ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UISlider *whiteBalanceSlider;  //白平衡
@property (nonatomic, strong) UISlider *lightSlider;  //亮度
@property (nonatomic, strong) UISlider *compareSlider;//对比度
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) dispatch_queue_t modifyQueue;
@property (nonatomic, strong) UIButton *resetBtn;

@end

@implementation TSEditModifyCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    
    self.modifyQueue = dispatch_queue_create("ModifyImageQ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetDatas{
    self.bottomView.hidden = NO;
    self.imgView.image = _imgs[0];
    self.lightSlider.value = 50;
    self.whiteBalanceSlider.value = 50;
    self.compareSlider.value = 0;
    
//    [self modifyimg];
    
    self.resetBtn.enabled = YES;
    self.lightSlider.enabled = YES;
    self.whiteBalanceSlider.enabled = YES;
    self.compareSlider.enabled = YES;
    NSArray *values = @[@50,@50,@0];
    for( NSUInteger i=0; i<3; i++ ){
        UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:i+gTagBase];
        NSNumber *num = values[i];
        lbl.text = [NSString stringWithFormat:@"%ld", (long)num.integerValue];
    }
}

#pragma mark - Private
- (UISlider*)getSlider{
    UISlider *sli = [[UISlider alloc] init];
    sli.value = 50;
    sli.maximumValue = 100;
    sli.minimumTrackTintColor = [UIColor colorWithRgb_0_151_216];
    sli.thumbTintColor = [UIColor colorWithRgb_0_151_216];
    [sli addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateNormal];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateHighlighted];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateSelected];
    return sli;
}

- (UILabel*)getLabelWithTextAlignt:(NSTextAlignment)align text:(NSString*)text inView:(UIView*)inView{
    UILabel *lbl = [UILabel new];
    [inView addSubview:lbl];
    
    lbl.textAlignment = align;
    lbl.text = text;
    lbl.textColor = [UIColor colorWithRgb51];//_0_151_216];
    lbl.font = [UIFont systemFontOfSize:14];
    
    return lbl;
}


/**
 修改图片的对比度，白平衡，亮度

 @param value 白平衡的值 0 - 100
 @param light 亮度的值 0 - 100
 @param compare 对比度 0 - 100
 @return 返回新的图片
 */
- (UIImage*)modifyImgWhiteBalance:(CGFloat)value light:(CGFloat)light compare:(CGFloat)compare img:(UIImage*)img{
    UIImageOrientation ori = img.imageOrientation;
    if( [img isKindOfClass:[UIImage class]] == NO ) return nil;
    
    UIImage *myImage = img;//[UIImage imageNamed:@"Superman"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:myImage.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    
    if( light >= 0 ){
        // 修改亮度   -1---1   数越大越亮
        CGFloat li = (light-50)/(50);
        
        [lighten setValue:@(li) forKey:@"inputBrightness"];
    }
    if( value >=0 ){
    // 修改饱和度  0---2 白平衡
        CGFloat balance = value/(100/2);
        [lighten setValue:@(balance) forKey:@"inputSaturation"];
    }
    
    if( compare >= 0 ){
    // 修改对比度  0---4
        CGFloat compareValue = compare/(100/3) + 1;
        [lighten setValue:@(compareValue) forKey:@"inputContrast"];
    }
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];

    // 得到修改后的图片

    myImage = [UIImage imageWithCGImage:cgImage scale:1 orientation:ori];
    // 释放对象
   CGImageRelease(cgImage);

    return myImage;
}

- (void)modifyimg{
    self.naviView.sureBtn.enabled = NO;
    dispatch_async(self.modifyQueue, ^{
        if( _imgs.count ){
            UIImage *oriImg = _imgs[0];
            UIImage *img =
            [self modifyImgWhiteBalance:self.whiteBalanceSlider.value light:self.lightSlider.value compare:self.compareSlider.value img:oriImg];
            
            
            [self dispatchAsyncMainQueueWithBlock:^{
                self.naviView.sureBtn.enabled = YES;
                self.imgView.image = img;
                
                self.compareSlider.enabled = YES;
                self.lightSlider.enabled = YES;
                self.whiteBalanceSlider.enabled = YES;
                self.resetBtn.enabled = YES;
            }];
        }
    });
}

//保存所有修改的图片
- (void)saveModifyImgs{
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkEditSaveingImgs", nil) toView:self.view];
    [self dispatchAsyncQueueWithName:@"modifyImgsQ" block:^{
        NSMutableArray *arr = [NSMutableArray new];
        NSUInteger idx= 0;
        for( UIImage *oriImg in _imgs ){
            @autoreleasepool {
                UIImage *img =
                [self modifyImgWhiteBalance:self.whiteBalanceSlider.value light:self.lightSlider.value compare:self.compareSlider.value img:oriImg];
                img = [self regetModifyImg:img atIndex:idx];
                if( img ){
                    [arr addObject:img];
                }
                
                idx ++;
            }
        }
        
        [self dispatchAsyncMainQueueWithBlock:^{

            [_hud hide];
            
            [self.editWorkCtrl modifyImgCompete:arr];
            [self handleClose];
        }];
    }];
}
    
- (UIImage*)regetModifyImg:(UIImage*)myImage atIndex:(NSUInteger)idx{
    if( myImage ){
        NSString *tempImgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"editModifyTemp%ld.jpg",idx]];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isExist = [fm fileExistsAtPath:tempImgPath];
        if( isExist ){
            [fm removeItemAtPath:tempImgPath error:nil];
        }

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
    [self saveModifyImgs];
}

- (void)handleResetBtn{
    self.lightSlider.value = 50;
    self.whiteBalanceSlider.value = 50;
    self.compareSlider.value = 0;
    
    [self modifyimg];
    
    NSArray *values = @[@50,@50,@0];
    for( NSUInteger i=0; i<3; i++ ){
        UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:i+gTagBase];
        NSNumber *num = values[i];
        lbl.text = [NSString stringWithFormat:@"%ld", (long)num.integerValue];
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:slider.tag+gTagBase];
    lbl.text = [NSString stringWithFormat:@"%d", (int)slider.value];
    
    self.whiteBalanceSlider.enabled = NO;
    self.lightSlider.enabled = NO;
    self.compareSlider.enabled = NO;
    self.resetBtn.enabled = NO;
    [self modifyimg];
}

#pragma mark - Propertys

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat ih = self.naviView.height + 140;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        CGRect fr = self.naviView.frame;
        fr.origin.y = _bottomView.height-fr.size.height;
        self.naviView.frame = fr;
        [_bottomView addSubview:self.naviView];
        
        
        NSArray *titles = @[NSLocalizedString(@"WorkEditBottomModifyWhiteBalance", nil),
                            NSLocalizedString(@"WorkEditBottomModifyLight", nil),
                            NSLocalizedString(@"WorkEditBottomModifyDuibidu", nil)];//@[@"白平衡",@"明暗",@"对比度"];
        NSArray *values = @[@"50",@"50",@"0"];
        NSArray *sliders = @[self.whiteBalanceSlider,self.lightSlider,self.compareSlider];
        for( NSUInteger i=0; i<titles.count; i++ ){
            CGFloat ix = 20,iw = 80,ih = 30;
            CGFloat iy = i*ih;
            UILabel *markL = [self getLabelWithTextAlignt:NSTextAlignmentLeft text:titles[i] inView:_bottomView];
            markL.frame = CGRectMake(ix, iy, iw, ih);
            
            UILabel *valueL = [self getLabelWithTextAlignt:NSTextAlignmentRight text:values[i] inView:_bottomView];
            iw = 50;
            ix = _bottomView.width-iw-ix;
            valueL.frame = CGRectMake(ix, markL.y, iw, markL.height);
            valueL.tag = i+gTagBase;
            
            UISlider* slider = sliders[i];
            slider.tag = i;
            iw = valueL.x - markL.right;
            ih = 20;
            slider.frame = CGRectMake(markL.right, markL.center.y-ih/2, iw, ih);
            [_bottomView addSubview:slider];
        }
        
        UIButton *resetBtn = [UIButton new];
        CGFloat iw = 70;ih  = 35;
        CGFloat ix = (_bottomView.width-iw)/2;
        CGFloat topH = 90;
        resetBtn.frame = CGRectMake(ix, (self.naviView.y-topH-ih)/2+topH, iw, ih);
        [resetBtn setTitle:NSLocalizedString(@"WorkEditBottomModifyResetTitle", nil) forState:UIControlStateNormal];
        [resetBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [resetBtn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateHighlighted];
        [resetBtn cornerRadius:ih/2];
        resetBtn.layer.borderColor = [UIColor colorWithRgb102].CGColor;
        resetBtn.layer.borderWidth = 0.5;
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [resetBtn addTarget:self action:@selector(handleResetBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:resetBtn];
        _resetBtn = resetBtn;
        
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
        _imgView.userInteractionEnabled = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomModify", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    }
    return _naviView;
}

- (UISlider *)whiteBalanceSlider {
    if( !_whiteBalanceSlider ){
        _whiteBalanceSlider = [self getSlider];
        _whiteBalanceSlider.value = 50;
    }
    return _whiteBalanceSlider;
}

- (UISlider *)lightSlider {
    if( !_lightSlider ){
        _lightSlider = [self getSlider];
        _lightSlider.value = 50;
    }
    return _lightSlider;
}

- (UISlider *)compareSlider {
    if( !_compareSlider ){
        _compareSlider = [self getSlider];
        _compareSlider.value = 0;
    }
    return _compareSlider;
}

@end
