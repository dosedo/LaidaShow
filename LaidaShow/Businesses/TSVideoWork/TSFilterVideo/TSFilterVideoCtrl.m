//
//  TSFilterVideoCtrl.m
//  ThreeShow
//
//  Created by cgw on 2019/7/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFilterVideoCtrl.h"
#import "SBPlayer.h"
#import "UIView+LayoutMethods.h"
#import "TSEditNaviView.h"
#import "UIColor+Ext.h"
#import "TSVideoFilterTypeView.h"

//Filter
#import "FilterHelper.h"
#import "GPUImageView.h"
#import "GPUImageMovie.h"
#import "GPUImageMovieWriter.h"
#import "HTProgressHUD.h"

@interface TSFilterVideoCtrl ()<SBPlayerDelegate>

@property (nonatomic, strong) SBPlayer *player;
@property (nonatomic, strong) TSFilterVideoNaviView *naviView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) TSVideoFilterTypeView *filterTypeSelectView;
@property (nonatomic, strong) TSVideoFilterTypeView *adjustTypeSelectView;

#pragma mark - Filter
//@property(strong, nonatomic)AVPlayer * videoPlayer;//视频播放

@property (nonatomic,strong)GPUImageMovie * gpuMovie;//滤镜效果展示movie
@property (nonatomic,strong)GPUImageView * gpuView;//视频预览图层

@property(nonatomic,strong)MHFilterInfo * commonFilterInfo;//当前选中普通滤镜信息(默认为空滤镜)
@property(nonatomic,strong)MHFilterInfo * adjustFilterInfo;//调整滤镜信息(默认为调整亮度滤镜)

@property (nonatomic,strong)GPUImageOutput<GPUImageInput> * commonFilter;//新添加的普通滤镜
@property (nonatomic,strong)GPUImageOutput<GPUImageInput> * adjustFilter;//新添加的特效滤镜
@property (nonatomic, strong) NSMutableArray *adjustFilters; //保存所有调整滤镜
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) GPUImageMovie *movieComposition;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@end

@implementation TSFilterVideoCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.player resetWithUrl:self.videoUrl];
    
    [self updateViewStateWithShowType:0];
    
    [self commit_movie];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.gpuView endProcessing];
    [self.gpuMovie endProcessing];
    [self.player stop];
}

#pragma mark - Private

/**
 更新视图的显示

 @param showType 0滤镜，1调节
 */
- (void)updateViewStateWithShowType:(NSInteger)showType{
    self.filterTypeSelectView.hidden = (showType==1);
    self.adjustTypeSelectView.hidden = (showType==0);
    self.slider.hidden = (showType==0);
    [self.naviView buttonWithIndex:0].selected = (showType==0);
    [self.naviView buttonWithIndex:1].selected = (showType==1);
}

////判断某个类是否存在某属性
//+ (BOOL) getVariableWithClass:(Class) myClass varName:(NSString *)name{
//    unsigned int outCount, i;
//    Ivar *ivars = class_copyIvarList(myClass, &outCount);
//    for (i = 0; i < outCount; i++) {
//        Ivar property = ivars[i];
//        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
//        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
//        if ([keyName isEqualToString:name]) {
//            return YES;
//        }
//    }
//    return NO;
//}

#pragma mark - TouchEvents
- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
//    UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:100];
//    lbl.text = [NSString stringWithFormat:@"%d%%", (int)slider.value];
//
//    @autoreleasepool{
//        [self modifyimg];
//    }
    [self.adjustFilter setValue:@(slider.value) forKey:self.adjustFilterInfo.propertyNameOfadjustValue];
}

- (void)handleSave{
    _hud = [HTProgressHUD showMessage:@"制作中" toView:self.view];
    [self compositionFilterWithCallBack:^(BOOL success, NSURL * _Nonnull outUrl) {
        [self.player pause];
        if( success ){
            //重命名视频，为了解决二次添加滤镜 获取不到视频size的问题
            NSString *path = outUrl.path;
            NSString *toPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempResultFilterVideo.mp4"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if( [fm fileExistsAtPath:toPath] ){
                [fm removeItemAtPath:toPath error:nil];
            }
            [fm moveItemAtPath:path toPath:toPath error:nil];
            [fm removeItemAtPath:path error:nil];
            
            [self.hud hide];
            
            [HTProgressHUD showSuccess:@"制作成功"];
            [self.navigationController popViewControllerAnimated:YES];
            if( _completeBlock ){
                _completeBlock([NSURL fileURLWithPath:toPath]);
            }
        }
        else{
            [self.hud hide];
            if( success == NO ){
                [HTProgressHUD showError:@"制作失败"];
            }
        }
    }];
}

- (void)handleClose{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleBottomBtn:(UIButton*)btn{
    if( btn.selected ) return;
    
    if( btn.tag -100 == 0 ){
        //滤镜
        [self handleFilterChange];
    }else{
        //调节
        [self addAdjustFilters];
    }
    
    NSInteger showType = btn.tag-100;
    [self updateViewStateWithShowType:showType];
}

- (void)handleFilterBtnAtIndex:(NSInteger)index{
    self.commonFilterInfo = self.filterTypeSelectView.filters[index];
    [self handleFilterChange];
}

- (void)handleAdjustBtnAtIndex:(NSInteger)index{
    self.adjustFilterInfo = self.adjustTypeSelectView.filters[index];
    self.adjustFilter = self.adjustFilters[index];
    
    self.slider.minimumValue = self.adjustFilterInfo.minValue;
    self.slider.maximumValue = self.adjustFilterInfo.maxValue;
    
    NSNumber *currValue = (NSNumber*)[self.adjustFilter valueForKey:self.adjustFilterInfo.propertyNameOfadjustValue];
    if( [currValue isKindOfClass:[NSNumber class]] ){
        self.slider.value = currValue.floatValue;
    }else{
        self.slider.value = self.slider.minimumValue;
    }
}

#pragma mark - SBPlayerDelegate
//暂停播放
- (void)playerPausePlay:(SBPlayer*)player{
    
}
//结束播放
- (void)playerEndPlay:(SBPlayer*)player{
    [self.player play];
}

#pragma mark - getter
- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
        _player.largerBtn.enabled = NO;
        _player.isShowControlView = NO;
        _player.delegate = self;
        //        _player.allowsRotateScreen = NO;
        //设置标题
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        //        _player.mode = SBLayerVideoGravityResize;
        //添加播放器到视图
        [self.view addSubview:_player];
        //约束，也可以使用Frame
        CGFloat iw = self.view.frame.size.width;
        _player.frame = CGRectMake(0, 0, iw, SCREEN_HEIGHT);
    }
    return _player;
}

- (TSFilterVideoNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSFilterVideoNaviView alloc] initWithTarget:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave) titles:@[NSLocalizedString(@"滤镜", nil),NSLocalizedString(@"调节", nil)] handleTitleSel:@selector(handleBottomBtn:)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        _naviView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_naviView];
    }
    return _naviView;
}

- (UISlider *)slider {
    if( !_slider ){
        _slider = [self getSlider];
        _slider.hidden = YES;
        CGFloat ix = 50, ih = 40;
        _slider.frame = CGRectMake(ix, self.adjustTypeSelectView.top-ih, SCREEN_WIDTH-2*ix, ih);
        [self.view addSubview:_slider];
    }
    return _slider;
}

- (UISlider*)getSlider{
    UISlider *sli = [[UISlider alloc] init];
    sli.value = 0;
    sli.maximumValue = 2.0;
    sli.minimumValue = 0;
    sli.minimumTrackTintColor = [UIColor colorWithRgb_0_151_216];
    sli.thumbTintColor = [UIColor colorWithRgb_0_151_216];
    [sli addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateNormal];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateHighlighted];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateSelected];
    return sli;
}

- (TSVideoFilterTypeView *)filterTypeSelectView{
    if( !_filterTypeSelectView ){
        CGFloat ih = 103;
        CGRect fr = CGRectMake(0, self.naviView.y-ih+15, SCREEN_WIDTH, ih);
//        NSArray *tis = @[@"原图",@"高亮",@"青苔",@"灰色空间",@"浓郁"];
//        NSArray *imgs = @[@"",@"",@"",@"",@""];
        _filterTypeSelectView = [[TSVideoFilterTypeView alloc] initWithFrame:fr filters:[FilterHelper readAllCommonFiltersArr] typeImgHeight:54];
        __weak typeof(self) wk = self;
        _filterTypeSelectView.selectBlock = ^(NSInteger index) {
            [wk handleFilterBtnAtIndex:index];
        };
        [self.view addSubview:_filterTypeSelectView];
        _filterTypeSelectView.hidden = YES;
        _filterTypeSelectView.backgroundColor = [UIColor whiteColor];
    }
    return _filterTypeSelectView;
}

- (TSVideoFilterTypeView *)adjustTypeSelectView{
    if( !_adjustTypeSelectView ){
        CGFloat ih = 75;
        CGRect fr = CGRectMake(0, self.naviView.y-ih+15, SCREEN_WIDTH, ih);
        NSArray *tis = @[@"亮度",@"色温",@"对比度",@"饱和度",@"锐化"];
        //对应的值的范围 -1~1|0, 1000~10000|5000, 0.0-4.0|1.0, 0.0~2.0|1.0, -4.0~4.0|0.0
        NSArray *classNames = @[@"GPUImageBrightnessFilter",@"GPUImageWhiteBalanceFilter",
                                @"GPUImageContrastFilter",@"GPUImageSaturationFilter",
                                @"GPUImageSharpenFilter"];
        NSArray *paraNames= @[@"brightness",@"temperature",@"contrast",@"saturation",@"sharpness"];
        NSArray *imgs = @[@"adjust_liangdu_n",@"adjust_sewen_n",@"adjust_duibidu_n",@"adjust_baohedu_n",@"adjust_ruihua_n"];
        NSArray *simgs = @[@"adjust_liangdu_s",@"adjust_sewen_s",@"adjust_duibidu_s",@"adjust_baohedu_s",@"adjust_ruihua_s"];
        NSArray *minValues = @[@(-1),@(1000),@(0.0),@(0.0),@(-4.0)];
        NSArray *maxValues = @[@(1),@(10000),@(4.0),@(2.0),@(4.0)];
        NSArray *normalValues = @[@(0),@(5000),@(1.0),@(1.0),@(0.0)];
        NSMutableArray *filters = [NSMutableArray new];
        for( NSUInteger i=0; i<tis.count; i++ ){
            MHFilterInfo *fi = [MHFilterInfo new];
            fi.filterName = tis[i];
            fi.filterClassName = classNames[i];
            fi.propertyNameOfadjustValue = paraNames[i];
            fi.imgName = imgs[i];
            fi.sImgName = simgs[i];
            fi.minValue = ((NSNumber*)minValues[i]).floatValue;
            fi.maxValue = ((NSNumber*)maxValues[i]).floatValue;
            fi.normalValue = ((NSNumber*)normalValues[i]).floatValue;
            [filters addObject:fi];
        }
        _adjustTypeSelectView = [[TSVideoFilterTypeView alloc] initWithFrame:fr filters:filters typeImgHeight:21];
        __weak typeof(self) wk = self;
        _adjustTypeSelectView.selectBlock = ^(NSInteger index) {
            [wk handleAdjustBtnAtIndex:index];
        };
        [self.view addSubview:_adjustTypeSelectView];
        _adjustTypeSelectView.hidden = YES;
        _adjustTypeSelectView.backgroundColor = [UIColor whiteColor];
    }
    return _adjustTypeSelectView;
}

@end

#import "MHVideoTool.h"

@implementation TSFilterVideoCtrl(Filter)

#pragma mark - 初始化movie
-(void)commit_movie
{
    //初始化默认滤镜信息（空滤镜）
    self.commonFilterInfo = [MHFilterInfo customEmptyInfo];
//    self.adjustFilterInfo = [self.adjustTypeSelectView.filters objectAtIndex:0];
    
    //初始化 gpuMovie
    self.gpuMovie = [[GPUImageMovie alloc] initWithPlayerItem:self.player.item];
    self.gpuMovie.runBenchmark = YES;
    self.gpuMovie.playAtActualSpeed = YES;//滤镜渲染方式
    self.gpuMovie.shouldRepeat = YES;//是否循环播放
    //初始化视频预览图层
    self.gpuView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.gpuView];
    
    GPUImageOutput<GPUImageInput> * commonfilter = [[NSClassFromString(self.commonFilterInfo.filterClassName) alloc] init];
    self.commonFilter = commonfilter;
    
//    self.adjustFilter = [[NSClassFromString(self.adjustFilterInfo.filterClassName) alloc] init];

    [self.gpuMovie addTarget:self.commonFilter];
    [self.commonFilter addTarget:self.gpuView];

//    //旋转视频方向
//    [self.gpuView setInputRotation:(kGPUImageRotateRight) atIndex:0];
    
    [self.player play];
    [self.gpuMovie startProcessing];
    
    [self.view sendSubviewToBack:self.gpuView];
    [self.view sendSubviewToBack:self.player];
}

#pragma mark - 响应 滤镜变化
-(void)handleFilterChange
{
    [self.gpuMovie removeAllTargets];
    [self.commonFilter removeAllTargets];

    GPUImageOutput<GPUImageInput> * commonfilter = [[NSClassFromString(self.commonFilterInfo.filterClassName) alloc] init];
    
    self.commonFilter = commonfilter;
    
    [self.gpuMovie addTarget:self.commonFilter];
    [self.commonFilter addTarget:self.gpuView];
    
//    //旋转视频方向
//    [self.gpuView setInputRotation:(kGPUImageRotateRight) atIndex:0];
}

-(void)addAdjustFilters
{
    for( GPUImageOutput *filter in self.adjustFilters ){
        [filter removeAllTargets];
    }
    [self.adjustFilters removeAllObjects];
    
    [self.gpuMovie removeAllTargets];
    [self.commonFilter removeAllTargets];

//    //旋转视频方向
//    [self.gpuView setInputRotation:(kGPUImageRotateRight) atIndex:0];
    
    NSInteger i = 0;
    GPUImageOutput *lastFilter = nil;
    for( MHFilterInfo *fi in self.adjustTypeSelectView.filters ){
        
        GPUImageOutput<GPUImageInput> * adjustfilter = [[NSClassFromString(fi.filterClassName) alloc] init];
        [adjustfilter removeAllTargets];
        
        if( i==0 ){
            [self.gpuMovie addTarget:adjustfilter];
            self.adjustFilterInfo = fi;
            self.adjustFilter = adjustfilter;
            
        }else if( i==_adjustTypeSelectView.filters.count-1 ){
            [lastFilter addTarget:adjustfilter];
            [adjustfilter addTarget:self.gpuView];
        }else{
            [lastFilter addTarget:adjustfilter];
        }
        
        lastFilter = adjustfilter;
        
        [self.adjustFilters addObject:adjustfilter];
        
        i++;
    }
    
    //每次进入调节滤镜，则设置slider的值为该滤镜的正常值
    self.slider.minimumValue = self.adjustFilterInfo.minValue;
    self.slider.maximumValue = self.adjustFilterInfo.maxValue;
    NSNumber *currValue = (NSNumber*)[self.adjustFilter valueForKey:self.adjustFilterInfo.propertyNameOfadjustValue];
    if( [currValue isKindOfClass:[NSNumber class]] ){
        self.slider.value = currValue.floatValue;
    }else{
        self.slider.value = self.slider.minimumValue;
    }
}

- (NSMutableArray*)adjustFilters{
    if( !_adjustFilters ){
        _adjustFilters = [NSMutableArray arrayWithCapacity:5];
    }
    return _adjustFilters;
}

#pragma mark - 合成滤镜视频
//设置合成的滤镜
- (NSArray*)setFiltersForImageMovie:(GPUImageMovie*)movieComposition{
    BOOL isCommonFilter = ([self.naviView buttonWithIndex:0].isSelected);
    if( isCommonFilter ){
        GPUImageOutput<GPUImageInput> * commonFilter = [[NSClassFromString(self.commonFilterInfo.filterClassName) alloc] init];
        [movieComposition addTarget:commonFilter];
        return @[commonFilter];
    }else{
        GPUImageOutput *lastFilter = nil;
        NSMutableArray *filters = [NSMutableArray new];
        NSInteger i=0;
        for( MHFilterInfo *fi in self.adjustTypeSelectView.filters ){
            
            GPUImageOutput<GPUImageInput> * adjustfilter = [[NSClassFromString(fi.filterClassName) alloc] init];
            
            GPUImageOutput *originAdjustFilter = self.adjustFilters[i];
            [adjustfilter setValue:[originAdjustFilter valueForKey:fi.propertyNameOfadjustValue] forKey:fi.propertyNameOfadjustValue];
            
            if( i==0 ){
                [movieComposition addTarget:adjustfilter];
                
            }else{
                [lastFilter addTarget:adjustfilter];
            }
            
            lastFilter = adjustfilter;
            
            [filters addObject:adjustfilter];
            
            i++;
        }
        
        return filters;
    }
}

- (void)compositionFilterWithCallBack:(void(^)(BOOL success,NSURL * outUrl))callBack
{
    NSLog(@"-----开始视频滤镜处理----");
    NSURL * videoUrl = self.videoUrl;
    GPUImageMovie *movieComposition = [[GPUImageMovie alloc] initWithURL:videoUrl];
    _movieComposition = movieComposition;
    movieComposition.runBenchmark = YES;
    movieComposition.playAtActualSpeed = NO;
    
    NSArray *filters = [self setFiltersForImageMovie:movieComposition];

    //合成后的视频路径
    NSString * outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempFilterVideo.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:outPath] ){
        [fm removeItemAtPath:outPath error:nil];
    }
    NSLog(@"添加滤镜后的保存路径：%@",outPath);
    NSURL * outPutUrl = [NSURL fileURLWithPath:outPath];
    
    //视频角度
    NSUInteger a = [MHVideoTool mh_getDegressFromVideoWithURL:videoUrl];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(a / 180.0 * M_PI );
    //获取视频尺寸
    CGSize videoSize = [MHVideoTool mh_getVideoSize:videoUrl];
//    if (a == 90 || a == 270) {
//        videoSize = CGSizeMake(videoSize.height, videoSize.width);
//    }
    
    NSLog(@"size:%f-%f",videoSize.width,videoSize.height);
    
    if( videoSize.width ==0 || videoSize.height ==0 ){
        NSLog(@"error:视频尺寸为0");
        for( GPUImageOutput *filter in filters ){
            [filter removeAllTargets];
        }
        if( callBack ){
            callBack(NO,nil);
        }
        return;
    }
    
    GPUImageMovieWriter *movieWriter  = [[GPUImageMovieWriter alloc] initWithMovieURL:outPutUrl size:videoSize];// fileType:AVFileTypeMPEG4 outputSettings:nil];
//                                         initWithMovieURL:outPutUrl size:videoSize];
    _movieWriter = movieWriter;
    movieWriter.transform = rotate;
    movieWriter.shouldPassthroughAudio = YES;
//    //有时候会因为视频文件没有音频轨道报错.....不知道为啥
    movieComposition.audioEncodingTarget = movieWriter;
    
    GPUImageOutput<GPUImageInput> * lastFilter = [filters lastObject];
    [lastFilter addTarget:movieWriter];
    
    [movieComposition enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [movieComposition startProcessing];
    
    __weak GPUImageMovieWriter *weakmovieWriter = movieWriter;
    [movieWriter setCompletionBlock:^{
        NSLog(@"滤镜添加成功");
      
        for( GPUImageOutput *filter in filters ){
            [filter removeAllTargets];
        }
        
        [weakmovieWriter finishRecording];
//        [movieComposition removeAllTargets];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack(YES,outPutUrl);
        });
    }];
    [movieWriter setFailureBlock:^(NSError *error) {
//        [specialFilter removeAllTargets];
//        [commonFilter removeAllTargets];
        for( GPUImageOutput *filter in filters ){
            [filter removeAllTargets];
        }
        [movieComposition removeAllTargets];
        [weakmovieWriter finishRecording];
        NSLog(@"滤镜添加失败 %@",error.description);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack(NO,nil);
        });
    }];
}

@end
