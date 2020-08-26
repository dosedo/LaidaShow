//
//  WXWPhotoPicker.m
//  wxw
//
//  Created by wxw on 16/7/4.
//  Copyright © 2016年 wxw. All rights reserved.
//

#import "WXWPhotoPicker.h"
#import <AVFoundation/AVFoundation.h>
#import "LDImagePicker.h"
#import "TZImagePickerController.h"

#define kGlobalThread dispatch_get_global_queue(0, 0)
#define kMainThread   dispatch_get_main_queue()

#define kIsIOS7OrLater ([UIDevice currentDevice].systemVersion.floatValue>=7.0)

@interface UIImagePickerController(Photo)

+(BOOL)isCameraAvailable;
+(BOOL)isPhotoLibraryAvailable;
+(BOOL)canTakePhoto;

@end

@interface WXWPhotoPicker()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LDImagePickerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, weak)     UIViewController  *fromController;
@property (nonatomic, copy)     CancelBlock       cancelBlock;
@property (nonatomic, assign)   BOOL              allowImgEdit;
@property (nonatomic, assign)   CGFloat           editImgScale; //宽为固定，编辑的图片框的scale，宽为屏幕宽度
@property (nonatomic, strong) TZImagePickerController *imagePickController;

@end

@implementation WXWPhotoPicker

+ (WXWPhotoPicker *)sharedPhotoPicker{
    static WXWPhotoPicker *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}

- (void)showActionSheetInController:(UIViewController *)inController editScale:(CGFloat)editScale completion:(CompletionBlock)completion cancelBlock:(CancelBlock)cancelBlock{
    [self showActionSheetInView:inController.view fromController:inController allowImgEdit:YES completion:completion cancelBlock:cancelBlock];
    self.editImgScale = editScale;
}

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                 allowImgEdit:(BOOL)allowImgEdit
                   completion:(CompletionBlock)completion
                  cancelBlock:(CancelBlock)cancelBlock{
    self.completion = [completion copy];
    self.cancelBlock = [cancelBlock copy];
    self.fromController = fromController;
    self.allowImgEdit = allowImgEdit;
    self.editImgScale = 1;
    dispatch_async(kGlobalThread, ^{

        dispatch_async(kMainThread, ^{
            UIActionSheet *actionSheet = nil;
            if ([UIImagePickerController isCameraAvailable]) {
                actionSheet  = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:(id<UIActionSheetDelegate>)self
                                                  cancelButtonTitle:NSLocalizedString(@"取消", nil)                                           destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"拍照", nil) ,NSLocalizedString(@"从相册选择", nil),  nil];
            } else {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:(id<UIActionSheetDelegate>)self
                                                 cancelButtonTitle:@"取消"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"从相册选择", nil];
            }
            [actionSheet showInView:inView];
        });
    });
}

#pragma mark - Private

- (BOOL)isHaveCameraAuthorization{
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted
            || authorizationStatus == AVAuthorizationStatusDenied) {
            
            // 没有权限
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"不能访问相机，请在(设置-隐私-相机)中允许访问!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Delegatge
#pragma mark __UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if( buttonIndex == 2 ){
        //点击了取消
        return;
    }
    
    LDImagePicker *imagePicker = [LDImagePicker sharedInstance];
    imagePicker.delegate = self;
    if( self.allowImgEdit ){
        [imagePicker showImagePickerWithType:buttonIndex InViewController:self.fromController Scale:self.editImgScale];
    }
    else{
        [imagePicker showOriginalImagePickerWithType:buttonIndex InViewController:self.fromController];
    }
}


#pragma mark __UIImagePickerControllerDelegate
// 选择了图片或者拍照了
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if( image == nil )
        image = info[UIImagePickerControllerOriginalImage];
    
    if (image && self.completion) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.fromController setNeedsStatusBarAppearanceUpdate];
        
        if( image && self.completion ){
            self.completion(@[image]);
        }
    }
}

// 取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    
    if (self.cancelBlock) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.fromController setNeedsStatusBarAppearanceUpdate];
        
        self.cancelBlock();
    }
    [aPicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 修改编辑框的大小 LDImagePickerDelegate

- (void)imagePicker:(LDImagePicker *)imagePicker didFinished:(UIImage *)editedImage{
    if (editedImage && self.completion) {
        self.completion(@[editedImage]);
    }
}
- (void)imagePickerDidCancel:(LDImagePicker *)imagePicker{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark - Propertys

- (TZImagePickerController *)imagePickController {
    if( !_imagePickController ){
        TZImagePickerController *imagePickController = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        //是否 在相册中显示拍照按钮
        imagePickController.allowTakePicture = NO;
        //是否可以选择显示原图
        imagePickController.allowPickingOriginalPhoto = NO;
        //是否 在相册中可以选择视频
        imagePickController.allowPickingVideo = NO;
        imagePickController.allowPreview = NO;
        imagePickController.autoDismiss = NO;
        
        _imagePickController = imagePickController;
    }
    return _imagePickController;
}

@end

#pragma mark -  ------- OtherCategory --------

@implementation UIImagePickerController(photo)
+(BOOL)isCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]            //后置摄像头
    ||
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];          //前置摄像头
}

+(BOOL)isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

+(BOOL)canTakePhoto
{
    return [UIImagePickerController isCameraAvailable];
}
@end


@implementation WXWPhotoPicker(SelectPhoto)
//展示相册
- (void)showAlbumInCtrl:(UIViewController*)ctrl{
    _imagePickController = nil;
    TZImagePickerController *imagePickController = self.imagePickController;
//    [imagePickController gotoPhotoPickerCtrl];
    imagePickController.modalPresentationStyle = 0; //适配iOS13,设置全屏
    [ctrl presentViewController:imagePickController animated:YES completion:nil];
}

/** 相机 */
- (void)openCameraWithCtrl:(UIViewController*)ctrl{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        if([self isHaveCameraAuthorization]==NO) return;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        
        [ctrl presentViewController:picker animated:YES completion:nil];
        
    }else{

//        [UIAlertController showAlertWithTitle:@"该设备不支持拍照" message:nil actionTitles:@[@"确定"] cancelTitle:nil style:UIAlertControllerStyleAlert completion:nil];
    }
}

- (void)showImagePickerViewInCtrl:(UIViewController *)ctrl{
    [self showAlbumInCtrl:ctrl];
//    return;
//    self.fromController = ctrl;
//    [self showImagePickerAtIndex:1];
}


/**
 展示选择图片视图

 @param buttonIndex 0相机 ，1 相册
 */
- (void)showImagePickerAtIndex:(NSUInteger)buttonIndex{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = self.allowImgEdit;
    if (buttonIndex == 1) { // 从相册选择
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if (buttonIndex == 0) { // 拍照
        if (![UIImagePickerController isCameraAvailable]){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
        }else {
            if ([UIImagePickerController canTakePhoto]) {
                
                if( [self isHaveCameraAuthorization] == NO ){
                    return;
                }
                
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
            }else{
                return;
            }
        }
    }
    else if( buttonIndex == 2 ){
        return;
    }
    
    picker.delegate = self;
    if (kIsIOS7OrLater) {
        picker.navigationBar.barTintColor = [UIColor whiteColor];// self.fromController.navigationController.navigationBar.barTintColor;
    }
    // 设置导航默认标题的颜色及字体大小
//    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
//                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
//    picker.navigationItem.rightBarButtonItem.title = @"aa";//[UIColor whiteColor];
    picker.modalPresentationStyle = 0; //适配iOS13,设置全屏
    [self.fromController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController Delegate
//处理从相册单选或多选的照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    
    if( photos.count ){
        if( self.completion ){
            self.completion(photos);
        }
    }
    
    if( _delegate && [_delegate respondsToSelector:@selector(photoPicker:didFinishSelectImg:)] ){
        if( photos.count )
        {
            UIImage *img = photos[0];
            if( [img isKindOfClass:[UIImage class]] == NO ){
                img = nil;
            }
            [_delegate photoPicker:self didFinishSelectImg:img];
        }
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
//    if ([_selectedImageAssets isEqualToArray: assets]) {
//        return;
//    }
    //每次回传的都是所有的asset 所以要初始化赋值
//    if (!_allowMultipleSelection) {
//        _selectedImageAssets = [NSMutableArray arrayWithArray:assets];
//    }
//    NSMutableArray *models = [NSMutableArray array];
//    //2次选取照片公共存在的图片
//    NSMutableArray *temp = [NSMutableArray array];
//    NSMutableArray *temp2 = [NSMutableArray array];
    for (NSInteger index = 0; index < assets.count; index++) {
//        PHAsset *asset = assets[index];
//        [[LLImagePickerManager manager] getMediaInfoFromAsset:asset completion:^(NSString *name, id pathData) {
//
//            LLImagePickerModel *model = [[LLImagePickerModel alloc] init];
//            model.name = name;
//            model.uploadType = pathData;
//            model.image = photos[index];
//            //区分gif
//            if ([NSString isGifWithImageData:pathData]) {
//                model.image = [UIImage ll_setGifWithData:pathData];
//            }
//
//            if (!_allowMultipleSelection) {
//                //用数组是否包含来判断是不成功的。。。
//                for (LLImagePickerModel *md in _selectedImageModels) {
//                    // 新方法
//                    if ([md isEqual:model] ) {
//                        [temp addObject:md];
//                        [temp2 addObject:model];
//                        break;
//                    }
//                }
//            }
//
//            [models addObject:model];
//        }];
    }
}
///选取视频后的回调
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
///拍照、选视频图片、录像 后的回调（这种方式选择视频时，会自动压缩，但是很耗时间）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf didFinishPickingMediaWithInfo:info];
    }];
}

- (void)didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if( image )
        {
            image = [self getLocalSelectImgWithImg:image];
        }
        
        if( image ){

            if( self.completion ){
                self.completion(@[image]);
            }
        }
    }
}

- (UIImage*)getLocalSelectImgWithImg:(UIImage*)img{
    if( img ){
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"editAddImgForSelectedImg88888.jpg"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:path] ){
            [fm removeItemAtPath:path error:nil];
        }
        
        [UIImagePNGRepresentation(img) writeToFile:path atomically:YES];
        
        img = nil;
        NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        UIImage* newimg = [UIImage imageWithData:imageData];
        
        return newimg;
    }
    
    return nil;
}

@end

