//
//  TSProductionShowView.m
//  ThreeShow
//
//  Created by hitomedia on 08/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductionShowView.h"
#import "TSHttpRequest.h"
#import "TSDataProcess.h"
#import "KError.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSHelper.h"
#import "MBProgressHUD.h"
#import "HTProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#define MaxSCale 6.0  //最大缩放比例
#define MinScale 1.0  //最小缩放比例
#define BOUNDCE_DURATION 0.3f

//产品动画的方向，向左切换，向右切换
typedef NS_ENUM(NSInteger,TSProductionAnimateDirection){
    TSProductionAnimateDirectionLeft = 0,
    TSProductionAnimateDirectionRight
};

@interface TSProductionShowView()
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, assign) CGRect latestFrame;


@end

@implementation TSProductionShowView{
    NSTimer                      *_timer;
    TSProductionAnimateDirection _animateDirection;
    
    NSInteger                    _showingImgIndex;  //正在展示的图片索引
    NSURLSessionDownloadTask     *_urlTask;
    UIView                       *_gestureView;  //手势视图
    CGFloat                      _lastTouchX;    //上个触摸点的X
    
    CGFloat                      pinScal;//缩放需要
    CGFloat                      _totalScale;// 为了限制缩放的比例
    CGPoint                      _totalMoveDis; //双指拖动移动的距离 可以为负
    BOOL                         _isOneFingerDrag; //仅仅一个手指拖动
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        _animateImgs = [NSMutableArray new];
        _animateDirection = TSProductionAnimateDirectionLeft;
        _showingImgIndex = 0;
        pinScal = 1;
        _totalScale = 1;
        _isAnimate = YES;
        [self resetFrame];
    }
    return self;
}

- (void)resetFrame{
    CGPoint moveDis = CGPointZero;//[self getTwoFingerMoveMaxDistance];
    self.imgView.frame = CGRectMake(-moveDis.x, -moveDis.y, self.width+moveDis.x*2, self.height+moveDis.y*2);
//    _gestureView.frame = self.imgView.bounds;
    CGFloat ih = 30;
    self.countNumL.frame = CGRectMake(0, (_imgView.height-ih)/2, _imgView.width, ih);
    
    _cropFrame = CGRectMake(0, 0, self.width, self.height);
    _largeFrame = CGRectMake(0, 0, MaxSCale*self.width, MaxSCale*self.height);
    _oldFrame = self.imgView.frame;
}

- (void)reloadData{
    _isAnimate = YES;
    _totalScale = 1;
    CGAffineTransform current=CGAffineTransformMakeScale(1, 1);
    [self.imgView setTransform:current];
    self.imgView.image = [UIImage imageNamed:@"work_placeholder"];
    [_animateImgs removeAllObjects];
    _showingImgIndex = 0;
    _animateDirection = TSProductionAnimateDirectionLeft;
//    _gestureView.hidden = YES;
    [self endAnimate];
    _isAnimate = YES;
    
    self.countNumL.hidden = NO;
 
    if( _imgs.count ){

        [_animateImgs addObjectsFromArray:_imgs];
        if([_imgs[0] isKindOfClass:[UIImage class]] ){
            self.imgView.image = _imgs[0];
            [self resetFrame];
        }
        [self startAnimate];
        return;
    }
    
    __weak typeof(self) weakself = self;
    [self loadImgFromLocalWithCompleteBlock:^(NSError *err) {
        [weakself loadImgFromLocalComplete];
    }];
}

- (void)loadImgFromLocalComplete{
    if( _animateImgs.count ){
        self.countNumL.hidden = YES;
        _gestureView.hidden = NO;
        
        self.imgs = _animateImgs;
        if( [_imgs isKindOfClass:[NSArray class]] && _imgs.count ){
            if([_imgs[0] isKindOfClass:[UIImage class]] ){
                self.imgView.image = _imgs[0];
                [self resetFrame];
            }
        }
        //下载完
        if( _animateImgs.count < self.imgUrls.count ){
            return;
        }else [self startAnimate];
        
        if(self.loadCompleteBlock ){
            self.loadCompleteBlock(self);
        }
    }else{
        //NSLog(@"===loadImgFromOnline====");
        //self.userInteractionEnabled = NO;
        [self loadImgFromOnline];
    }
}

- (void)cancleDownImg{
    if( _urlTask && _urlTask.state == NSURLSessionTaskStateRunning){
        [_urlTask cancel];
    }
}

//停止动画和图片加载
- (void)stopAnimate{
    [self cancleDownImg];
    [self endAnimate];
    
    self.countNumL.text = @"";
    
    [_timer invalidate];
    _timer = nil;
}

//- (BOOL)isAnimate{
//    return _timer;
//}


#pragma mark - Private
    
- (void)loadImgFromOnline{
    NSLog(@"===loadImgFromOnline====");
    //_gestureView.hidden = YES;
  //  http://n.res.aipp3d.com/r/2018/12/21/1142/c6bafd72e7e34c0a80a82c02f1cc66f3/0.png
    
    if( _imgUrls.count )
        self.countNumL.text = @(_imgUrls.count).stringValue;//图片的张数
    
    __weak typeof(self) weakself = self;
    dispatch_queue_t queue = dispatch_queue_create([@"downImg" UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        //NSLog(@"====loadImgFromOnline currentThread %@",[NSThread currentThread]);
        [self downImgWithIndex:0 completeBlock:^(NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself downImgComplete];
            });
        }];
    });
}

- (void)downImgComplete{
     
    self.countNumL.hidden = NO;
    _gestureView  .hidden = NO;
    //[self endAnimate];
    self.imgs = _animateImgs;
    if( [_imgs isKindOfClass:[NSArray class]] && _imgs.count ){
        if([_imgs[0] isKindOfClass:[UIImage class]] ){
            self.imgView.image = _imgs[0];
            [self resetFrame];
        }
    }
    //下载完
    if( self->_animateImgs.count != self.imgUrls.count ){
        return;
    }else [self startAnimate];

    if(self.loadCompleteBlock ){
        self.loadCompleteBlock(self);
        
    }else _isOneFingerDrag=NO;
}
    
- (void)loadImgFromLocalWithCompleteBlock:(void(^)(NSError *err))completeBlock{
    dispatch_queue_t queue = dispatch_queue_create([@"loadCacheQ" UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        [[TSDataProcess sharedDataProcess] loadLocalImgWithUrls:_imgUrls completeBlock:^(NSArray<UIImage *> *arr, NSError *err) {
            if( err==nil && arr ){
                _animateImgs = [NSMutableArray arrayWithArray:arr];
                self.imgs = _animateImgs;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( completeBlock ){
                    completeBlock(nil);
                }
            });
        }];
    });
}

- (void)downImgWithIndex:(NSUInteger)idx completeBlock:(void(^)(NSError *err))completeBlock{
    if( idx >= _imgUrls.count ){
        if( completeBlock ){
            completeBlock(nil);
        } 
        return;
    }

    NSString *url = _imgUrls[idx];
//    if( url ){
//      //url = [NSString stringWithFormat:@"%@%lu.%@",[[TSHelper productImgUrlPrefix] stringByAppendingString:url],(unsigned long)idx,@"png"];
//        url = [[TSHelper productImgUrlPrefix] stringByAppendingString:url];
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //子线程下载数据
        NSLog(@"====DowloadImg Thread is %@",[NSThread currentThread]);
        NSLog(@"**** downimg *** %@",url);
        _urlTask =
        [[TSDataProcess sharedDataProcess] dowloadImg:url completeBlock:^(UIImage *img, NSError *err) {
        
            NSLog(@"===UI Thread is %@",[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if( img ){
                    
                    //图片进行压缩处理
                    //[self resetSizeOfImageData:img maxsize: 30];
                    //                [_animateImgs addObject:[UIImage imageWithData:okdata]];
                    //                 self.imgView.image = [UIImage imageWithData:okdata];
                    
                    [_animateImgs addObject:img];
                    NSLog(@"===_animateImgs count %lu",(unsigned long)_animateImgs.count);
                    
                    self.imgView.image = img;
                    if( idx == 0 ){
                        [self resetFrame];
                    }
                    self.countNumL.text = @(_imgUrls.count-idx).stringValue;
                    
                    [self downImgWithIndex:idx+1 completeBlock:completeBlock];
                }else{
                    if( completeBlock ){
                        completeBlock([KError errorWithCode:KErrorCodeDefault msg:@"获取图片失败"]);
                    }
                }
                
            });
        }];
    });
    
    
//    _urlTask =
//    [[TSDataProcess sharedDataProcess] dowloadImg:url completeBlock:^(UIImage *img, NSError *err) {
//        NSLog(@"UI Thread is %@",[NSThread currentThread]);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if( img ){
//
//                //图片进行压缩处理
//                //[self resetSizeOfImageData:img maxsize: 30];
////                [_animateImgs addObject:[UIImage imageWithData:okdata]];
////                 self.imgView.image = [UIImage imageWithData:okdata];
//                [_animateImgs addObject:img];
//                self.imgView.image = img;
//                if( idx == 0 ){
//                    [self resetFrame];
//                }
//                self.countNumL.text = @(_imgUrls.count-idx).stringValue;
//                [self downImgWithIndex:idx+1 completeBlock:completeBlock];
//            }else{
//                if( completeBlock ){
//                    completeBlock([KError errorWithCode:KErrorCodeDefault msg:@"获取图片失败"]);
//                }
//            }
//
//        });
//    }];
    //});
}


//11.28添加
#pragma mark -- 图片压缩
- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxsize:(NSInteger)maxsize{
    NSLog(@"====压缩====");
    //先判断当前质量是否满足需求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(source_image, 1.0);
    NSUInteger sizeOrigin = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1000;
    if (sizeOriginKB <= maxsize) {//小余的就保持原本分辨率
        NSLog(@"====保持不压缩====");
        return finallImageData;
    }
    //获取原图片的宽高比
    CGFloat sourceImageAspectRatio = source_image.size.width / source_image.size.height;
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024/sourceImageAspectRatio);
    UIImage *newImage = [self newSizeImage:defaultSize image:source_image];
    
    finallImageData = UIImageJPEGRepresentation(newImage, 1.0);
    
    //保存压缩系数   compressionQualityArr压缩x系数数组，从大到小存储
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    //使用二分法实现调整大小
    finallImageData = [self halfFunction:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxsize];
    //如果未压缩到指定大小，则降低分辨率处理
    while (finallImageData.length == 0) {
        //每次降100分辨率
        CGFloat reduceWidth = 100.0;
        CGFloat reduceHeight = 100.0/sourceImageAspectRatio;
        if (defaultSize.width-reduceWidth <= 0 || defaultSize.height-reduceHeight <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-reduceWidth, defaultSize.height-reduceHeight);
        UIImage *image = [self newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        finallImageData = [self halfFunction:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image, 1.0) maxSize:maxsize];
    }
    
    return finallImageData;
}

#pragma mark 调整图片分辨率/尺寸（等比例缩放）
- (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage{
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    //
    if (tempWidth >1.0&&tempWidth>tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    }else if (tempHeight>1.0&&tempWidth<tempHeight){
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //结束绘图
    UIGraphicsEndImageContext();
    return newImage;
    
    
}
#pragma mark -- 二分法实现调整大小
- (NSData *)halfFunction:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize{
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
        NSLog(@"当前降到的质量：%ld", (unsigned long)sizeOriginKB);
        NSLog(@"\nstart：%zd\nend：%zd\nindex：%zd\n压缩系数：%lf", start, end, (unsigned long)index, [arr[index] floatValue]);
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }

    return  tempData;
}
 
- (void)startAnimate{
    //self.userInteractionEnabled = NO;
    //_gestureView.userInteractionEnabled = NO;
    _isAnimate = YES;
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(changeImg) userInfo:nil repeats:YES];
}

- (void)endAnimate{
    [_timer invalidate];
    _timer = nil;
    
    _isAnimate = NO;
}

- (NSInteger)getNextImgIndexWithCurrIndex:(NSInteger)currIndex dirction:(TSProductionAnimateDirection)direction{
    NSInteger index = currIndex;
    if( currIndex >=0 && _animateImgs.count > currIndex){
        if( direction == TSProductionAnimateDirectionLeft ){
            //动画向左，索引应该增大
            index ++;
            if( index >= _animateImgs.count ){
                index = 0;
            }
        }else {
            //动画向右侧，索引应减小
            index--;
            if( index < 0 ){
                index = _animateImgs.count-1;
            }
        }
        
        return index;
    }
    
    return 0;
}

- (void)updateImg{
    if( _animateImgs.count > _showingImgIndex ){
        
        self.imgView.image = _animateImgs[_showingImgIndex];
    }
}

//获取双指拖动的最大距离，在X和Y方向上的
- (CGPoint)getTwoFingerMoveMaxDistance{
    if( self.imgView.image == nil ) return CGPointZero;
    
    CGSize imgSize = self.imgView.image.size;
    CGSize ivSize = CGSizeMake(self.width, self.height);
    CGPoint point = CGPointZero;
    if( ivSize.width/imgSize.width > ivSize.height/imgSize.height ){
        CGFloat iw = ivSize.width;
        CGFloat ih = iw * (imgSize.height/imgSize.width);
        
        point.y = (ih-ivSize.height)/2;
    }else{
        CGFloat ih = ivSize.height;
        CGFloat iw = ih * (imgSize.width/imgSize.height);
        
        point.x = (iw-ivSize.width)/2;
    }
    
    return point;
}

#pragma mark - TouchEvents

- (void)changeImg{
    
    _showingImgIndex = [self getNextImgIndexWithCurrIndex:_showingImgIndex dirction:_animateDirection];
    [self updateImg];
}

- (void)tapImgView{
    if( _timer == nil ){
        [self startAnimate];
    }else{
        [self endAnimate];
    }
    //此回调才能实现手势事件
    if( self.handleTapBlock ){
        self.handleTapBlock(self);
    }
}

//双指拖动
- (void)handleTwoFinger:(UIPanGestureRecognizer *)pan{
    
    if(pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        UIView *aView=pan.view;
        CGPoint transform=[pan translationInView:[aView superview]];
        [aView setCenter:CGPointMake([aView center].x+transform.x, [aView center].y+transform.y)];
        //设置要改变的视图,并开始移动
        [pan setTranslation:CGPointZero inView:[aView superview]];
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.imgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.imgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

//滑动手势（里面有手势的不同状态，根据需要进行灵活运用）
- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    //双指拖拽
    if( recognizer.numberOfTouches == 2 ){
        //双指拖动
        _isOneFingerDrag = NO;
        [self handleTwoFinger:recognizer];
        return;
    }
    

    //UITapGestureRecognizer
    if (recognizer.state == UIGestureRecognizerStateChanged){
        NSLog(@"UIGestureRecognizerStateChanged");
        if( _isOneFingerDrag == NO ) return;
        
        CGFloat touchX = [recognizer locationInView:_gestureView].x;
        float touchDisance  = touchX-_lastTouchX;
        
        CGFloat oneImgDistance = 5;
        //滑动的距离 小于5，则不更改图片
        if( fabsf(touchDisance) < oneImgDistance ){
            return;
        }
        
        if( touchDisance < 0 ){
            touchDisance = -touchDisance;
            _animateDirection = TSProductionAnimateDirectionLeft;
        }else{
            _animateDirection = TSProductionAnimateDirectionRight;
        }
        
        
        //计算应该滚动到某个图片
        NSInteger scrollImgCount = (NSInteger)(touchDisance/oneImgDistance);
        for( NSUInteger i=0; i<scrollImgCount; i++ ){
            _showingImgIndex = [self getNextImgIndexWithCurrIndex:_showingImgIndex dirction:_animateDirection];
        }

        [self updateImg];
        
        _lastTouchX = touchX;
    
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"UIGestureRecognizerStateEnded");
        if( _isOneFingerDrag ){
            [self startAnimate];
            _isOneFingerDrag = NO;
        }else{
            [self handleTwoFinger:recognizer];
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan");
        
        _isOneFingerDrag = YES;
        _lastTouchX = [recognizer locationInView:_gestureView].x;
        [self endAnimate];
        
    }else if(recognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"UIGestureRecognizerStateCancelled");
    }else if(recognizer.state == UIGestureRecognizerStateFailed){
        NSLog(@"UIGestureRecognizerStateFailed");
    }else if(recognizer.state == UIGestureRecognizerStatePossible){
        NSLog(@"UIGestureRecognizerStatePossible");
    }else if(recognizer.state == UIGestureRecognizerStateRecognized){
        NSLog(@"UIGestureRecognizerStateRecognized");
    }
}

//捏合
-(void)doPinchGesture:(UIPinchGestureRecognizer *)pinch{
    

    UIView *aView=pinch.view;
    
    CGFloat pinchScle = [pinch scale];
    if (pinch.state == UIGestureRecognizerStateBegan || pinch.state == UIGestureRecognizerStateChanged) {
        //放大情况
        if(pinchScle > 1.0){
            if(_totalScale >= MaxSCale) return;
        }
        
        //缩小情况
        if (pinchScle < 1.0) {
            if (_totalScale < MinScale) return;
        }
        
        _totalScale *= pinchScle;
        
        CGAffineTransform current1=CGAffineTransformScale(aView.transform,pinchScle, pinchScle);
        [aView setTransform:current1];
        pinch.scale = 1;
    }
    else if (pinch.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.imgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.imgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

//长按
- (void)handleLongPress:(UILongPressGestureRecognizer*)gestureRecognizer{
    
    if( _animateImgs.count != self.imgUrls.count ){
        return;
    }
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
         [self endAnimate];
        
        if( self.handleLongPressBlock ){
            self.handleLongPressBlock(self);
        }
    }
}

#pragma mark - Handle

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.imgView.frame.size.width > self.imgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

#pragma mark - Layout

- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - Propertys

- (UIImageView *)imgView {
    if( !_imgView ){

        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor whiteColor];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
//        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.image = [UIImage imageNamed:@"work_placeholder"];

        [self addSubview:_imgView];
        
        _gestureView = _imgView;
        _imgView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [_imgView addGestureRecognizer:gestureRecognizer];
        
        //添加点击手势事件
        _gestureView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView)];
        [_imgView addGestureRecognizer:tap];
        
        UIImageView *personImgView = _imgView;
        //捏合
        UIPinchGestureRecognizer *pinchGesture=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(doPinchGesture:)];
        [personImgView addGestureRecognizer:pinchGesture];
        
        //长按
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [personImgView addGestureRecognizer:longGes];
    }
    return _imgView;
}

- (UILabel *)countNumL {
    if( !_countNumL ){
        _countNumL = [[UILabel alloc] init];
        _countNumL.font = [UIFont systemFontOfSize:40];
        _countNumL.textColor = [UIColor colorWithRgb_0_151_216];
        _countNumL.textAlignment = NSTextAlignmentCenter;
        _countNumL.hidden = NO;
        //暂时不加数字
//        [self.imgView addSubview:_countNumL];
    }
    return _countNumL;
}

@end
