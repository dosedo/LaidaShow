//
//  KCommon.h
//  JLTravel
//
//  Created by 端倪 on 15/9/9.
//  Copyright (c) 2015年 端倪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <WebKit/WebKit.h>

#ifndef KCOMMON_DEVICE_CATEGORY
#define KCOMMON_DEVICE_CATEGORY
typedef enum{
    DeviceCategoryIPhone4 = 0,
    DeviceCategoryIPhone4s,
    DeviceCategoryIPhone5,
    DeviceCategoryIPhone5s,
    DeviceCategoryIPhone5c,
    DeviceCategoryIPhone6,
    DeviceCategoryIPhone6Plus,
    DeviceCategoryIPhone6s,
    DeviceCategoryIPhone6sPlus,
    DeviceCategoryOther
}DeviceCategory;
#endif

@interface KCommon : NSObject

#pragma mark - View 相关

/*   设置view圆角 边框颜色 边框宽度   */
+(void)setViewRadius:(CGFloat)radius view:(UIView*)view;
+(void)setViewBorderWidth:(CGFloat)width view:(UIView*)view;
+(void)setViewBorderWidth:(CGFloat)width borderColor:(UIColor*)color view:(UIView*)view;
+(void)setViewRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor*)color view:(UIView*)view;
/**
 *  设置lbl 多行的行间距，lbl必须要先设置text 文本才可生效
 *
 *  @param lbl       要设置的label
 *  @param lineSpace 行间距
 */
+(void)setLabelRowsSpcaceWithLabel:(UILabel*)lbl lineSpace:(CGFloat)lineSpace;

#pragma mark - UIImage相关

+(NSString *)UIImageToBase64Str:(UIImage *) image;

//字符串转图片
+(UIImage *)Base64StrToUIImage:(NSString *)_encodedImageStr;

///裁剪本地图片jpg
+(UIImage*)cutImgToSize:(CGSize)targetSize imgPath:(NSString*)imgPath;

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize);

CGImageRef MyCreateCGImageFromFile (NSString* path);

#pragma mark JSON相关
+(NSString*)dataToJsonString:(id)object;

+(id)jsonStringToData:(NSString*)jsonString;

#pragma mark size
/**
 *  得到label的高度，根据字体，宽度
 *
 *  @param str   label的字串
 *  @param font  label字体
 *  @param width label宽度
 *
 *  @return label的高度
 */
+(CGSize)getLblSizeWithStr:(NSString*)str font:(UIFont*)font width:(CGFloat)width;



#pragma mark 颜色

+(UIColor*)getColorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b;
/**
 *  父视图半透明,子视图不透明
 *
 *  @param r r
 *  @param g g
 *  @param b b
 *
 *  @return color
 */
+(UIColor*)getColorAlphaComponentWithAlpha:(CGFloat)alpha;

#pragma mark - sandbox相关
/**
 *  得到沙盒下的Documents文件夹
 *
 *  @return 沙盒documents全路径
 */
+(NSString*)getSandBoxDocPath;

#pragma mark - /*  导航栏   */
/**
 *  设置导航栏背景色
 *
 *  @param color 背景色
 */
+(void)setNavigationBgColor:(UIColor*)color naviCtrl:(UINavigationController*)naviCtrl;

#pragma mark - /*   工具类 方法     */

/**
 *  验证手机号是否有效
 *
 *  @param mobile 手机号码
 *
 *  @return 有效返回YES. 否则NO
 */
+(BOOL) validateMobile:(NSString *)mobile;
/**
 *  验证是否为6位数字
 *
 *  @param digital 待验证的数字
 *
 *  @return 是6位数字返回YES， 否则NO
 */
+(BOOL)validateDigital:(NSString*)digital;


/**
 *  验证是否是邮箱
 *
 *  @param Email mail

 */

+ (BOOL)ValidateEmail:(NSString *)Email;
/**
 *  验证密码是否包含数字或字母密码 6-10
 *
 *  @param pass password
 */

+ (BOOL)validatePassWordLegal:(NSString *)pass;


//scale 压缩比例
+(UIImage *)compressImage:(UIImage *)imgSrc scale:(CGFloat)scale;

//appId : 应用程序在app store的id
+(void)checkinVersionUpdateWithAppId:(NSString *)appId completeBlock:(void(^)(NSError*err, BOOL haveNewVersion , NSString* newVersionUrlStr ) )completeBlock;
/**
 *  计算strtemp 字符串的长度，英文和字符按1个字符，中文按2个字符
 *
 *  @param strtemp 需要计算的字符串
 *
 *  @return 中文按2字符，其他1字符所计算的 长度
 */
+(int)convertToInt:(NSString*)strtemp;

/**
 *  截取固定长度的字符串，其中汉字算2个字符，其他1个字符
 *
 */
+(NSString*)subStringToIndex:(int)index  srcStr:(NSString *)srcStr;

+(CGPoint)imgToViewWithImgOri:(CGPoint)imgOri viewSize:(CGSize)viewSize imgSize:(CGSize)imgSize;

+(CGPoint)viewToImgWithViewOri:(CGPoint)viewOri imgSize:(CGSize)imgSize viewSize:(CGSize)viewSize;


///获取设备内存信息，大小M
+(NSUInteger)getDeviceMemorySize;

+(DeviceCategory)getDeviceCategory;

#pragma mark -##提示类方法

/*    提示类 方法    */

/**
 *  错误提示视图，只含有一个取消按钮
 *
 *  @param title    提示框的标题
 *  @param msg      错误提示内容
 *  @param del      提示框的代理，用户按钮点击时，事件处理
 *  @param bntTitle 按钮的标题
 */
+(void)showErrorAlertViewWithTitle:(NSString*)title msg:(NSString*)msg delegate:(id)del cancelBtnTitle:(NSString*)bntTitle;

/**
 *  加载本地Html页面，
 *
 *  @param htmlName html页面的名字
 *  @param webView  加载html的webView
 */
+(void)loadHtmlWithHtmlName:(NSString*)htmlName webView:(WKWebView*)webView;

//+(void)showHUDAddToView:(UIView*)view title:(NSString*)title tag:(NSUInteger)tag;

+(NSString*)dateToString:(NSTimeInterval)timeInterval;

//+(NSString *)dateToTimeString:()

+(NSTimeInterval)dateStrToInterval:(NSString*)dateStr dateFormater:(NSString*)dateFormat;

+(NSString*)dateIntervalToString:(NSTimeInterval)timeInterval dateFormater:(NSString*)dateFormat;

+(void)WJLog:(NSString*)log;

@end




