//
//  WXWPhotoPicker.h
//  wxw
//
//  Created by wxw on 16/7/4.
//  Copyright © 2016年 wxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WXWPhotoPickerDelegate;
@interface WXWPhotoPicker : NSObject

+ (WXWPhotoPicker *)sharedPhotoPicker;

/*!
 * @brief 选择图片或者拍照完成选择使用拍照的图片后，会调用此block
 * @param images 选择的图片或者拍照后选择使用的图片
 */
typedef void (^CompletionBlock)(NSArray *images);
/*!
 * @brief 用户点击取消时的回调block
 */
typedef void (^CancelBlock)(void);

/*!
 * @brief 此方法为调起选择图片或者拍照的入口，当选择图片或者拍照后选择使用图片后，回调completion，
 *        当用户点击取消后，回调cancelBlock
 * @param inView UIActionSheet呈现到inView这个视图上
 * @param fromController 用于呈现UIImagePickerController的控制器
 * @param completion 当选择图片或者拍照后选择使用图片后，回调completion
 * @param cancelBlock 当用户点击取消后，回调cancelBlock
 */
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                 allowImgEdit:(BOOL)allowImgEdit
                   completion:(CompletionBlock)completion
                  cancelBlock:(CancelBlock)cancelBlock;


/*!
 * @brief 此方法为调起选择图片或者拍照的入口，当选择图片或者拍照后选择使用图片后，回调completion，
 *        当用户点击取消后，回调cancelBlock
 * @param editScale 编辑区域的缩放比例，宽度为屏幕宽度 editScale(height/Width)
 * @param inController 用于呈现UIImagePickerController的控制器
 * @param completion 当选择图片或者拍照后选择使用图片后，回调completion
 * @param cancelBlock 当用户点击取消后，回调cancelBlock
 */
- (void)showActionSheetInController:(UIViewController *)inController
                          editScale:(CGFloat)editScale
                         completion:(CompletionBlock)completion
                        cancelBlock:(CancelBlock)cancelBlock;


@property (nonatomic, copy)     CompletionBlock   completion;
@property (nonatomic, weak) id<WXWPhotoPickerDelegate> delegate;


@end

@interface WXWPhotoPicker (SelectPhoto)
- (void)showAlbumInCtrl:(UIViewController*)ctrl;
- (void)openCameraWithCtrl:(UIViewController*)ctrl;

//调用系统的 照片选择视图
- (void)showImagePickerViewInCtrl:(UIViewController*)ctrl;
@end

@protocol WXWPhotoPickerDelegate <NSObject>
@optional
- (void)photoPicker:(WXWPhotoPicker*)picker didFinishSelectImg:(UIImage*)img;
@end
