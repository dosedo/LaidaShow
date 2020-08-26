//
//  KCommon.m
//  JLTravel
//
//  Created by 端倪 on 15/9/9.
//  Copyright (c) 2015年 端倪. All rights reserved.
//

#import "KCommon.h"
#import <mach/mach.h>
#import <Foundation/NSProcessInfo.h>
#import <ImageIO/ImageIO.h>
#import "sys/utsname.h"


@implementation KCommon



+(UIColor*)getColorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}
+ (UIColor *)getColorAlphaComponentWithAlpha:(CGFloat)alpha {
    
        return [[UIColor blackColor] colorWithAlphaComponent:alpha];
}

#pragma mark - View相关

//设置view圆角
+(void)setViewRadius:(CGFloat)radius view:(UIView *)view{
    //边框圆角
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
}

+(void)setViewBorderWidth:(CGFloat)width view:(UIView *)view{
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = width;
}

+(void)setViewBorderWidth:(CGFloat)width borderColor:(UIColor*)color view:(UIView *)view{
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
}

+(void)setViewRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor*)color view:(UIView *)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
}

+(void)setLabelRowsSpcaceWithLabel:(UILabel*)lbl lineSpace:(CGFloat)lineSpace{
    if( lbl && lbl.text.length > 0 ){
        NSMutableAttributedString *arrString = [[NSMutableAttributedString alloc] initWithString:lbl.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:lineSpace];
        [arrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lbl.text length])];
        lbl.attributedText = arrString;
    }
}


#pragma mark View Size
+(CGSize)getLblSizeWithStr:(NSString*)str font:(UIFont*)font width:(CGFloat)width
{
    CGSize size = CGSizeMake(width, 20000);
    CGRect labelRect =  [ str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return labelRect.size;
}

#pragma mark - UIImage相关

+(NSString *)UIImageToBase64Str:(UIImage *) image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

//字符串转图片
+(UIImage *)Base64StrToUIImage:(NSString *)_encodedImageStr
{
    NSData *_decodedImageData   = [[NSData alloc] initWithBase64EncodedString:_encodedImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];
    return _decodedImage;
}

///裁剪本地图片jpg
+(UIImage*)cutImgToSize:(CGSize)targetSize imgPath:(NSString*)imgPath{
//    if( imgPath ){
//        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
//        CGImageRef imgRef = CGImageCreateWithImageInRect(img, <#CGRect rect#>)
//    }
    return nil;
}

//2、从一个Image Source中创建一个缩略图
//一些image source file包含缩略图。如果缩略图没有准备好，Image I/O给你一些选项来创建他们。你还可以指定一个最大的缩略图尺寸和是否应用一个transform到缩略图上。
//例子：
CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize)
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return myThumbnailImage;
}

CGImageRef MyCreateCGImageFromFile (NSString* path)
{
    // Get the URL for the pathname passed to the function.
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef        myImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[2];
    CFTypeRef         myValues[2];
    
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, myOptions);
    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    // Create an image from the first item in the image source.
    myImage = CGImageSourceCreateImageAtIndex(myImageSource,
                                              0,
                                              NULL);
    
    CFRelease(myImageSource);
    // Make sure the image exists before continuing
    if (myImage == NULL){
        fprintf(stderr, "Image not created from image source.");
        return NULL;
    }
    
    return myImage;
}

#pragma mark JSON相关
+(NSString*)dataToJsonString:(id)object{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(id)jsonStringToData:(NSString*)jsonString{
    NSError *err;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingMutableContainers
                                      error:&err];
    return obj;
    
}

#pragma mark - SandBox相关

+(NSString *)getSandBoxDocPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+(void)WJLog:(NSString*)log{
    NSString *fileName = @"WenJinLog.txt";
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",[KCommon getSandBoxDocPath],fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:path isDirectory:nil] ){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *da = [NSData dataWithContentsOfFile:log];
    [da writeToFile:path atomically:NO];
}

#pragma mark - 导航栏
+(void)setNavigationBgColor:(UIColor *)color naviCtrl:(UINavigationController*)naviCtrl{
    naviCtrl.navigationBar.barTintColor = color;
}


#pragma mark - Tool

+(BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";
    //    NSString* phoneRegex = @"^0?(13|15|17|18)[0-9]{9}$";
    //    NSString* phoneRegex = @"^0?(11|12|13|14|15|16|17|18|19)[0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


+(BOOL)validateDigital:(NSString*)digital{
    NSString *digi = @"^\\d{6}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digi];
    return [phoneTest evaluateWithObject:digital];
}

+(void)loadHtmlWithHtmlName:(NSString*)htmlName webView:(WKWebView*)webView{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
    
    //    NSURL *url =[NSURL URLWithString:@"http://www.sina.com.cn"];
    ////    NSLog(urlString);
    //    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    //    [self.webView loadRequest:request];
}


+ (BOOL)ValidateEmail:(NSString *)Email{
   
        
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    
    return [emailTest evaluateWithObject:Email];
        
}

+ (BOOL)validatePassWordLegal:(NSString *)pass{
  
    NSString * regex = @"^[(A-Z|a-z|0-9)|(A-Za-z0-9)]{6,10}$";   //正则表达式
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex]; //Cocoa框架中的NSPredicate用于查询，原理和用法都类似于SQL中的where，作用相当于数据库的过滤取
    return  [pred evaluateWithObject:pass];
}


+ (NSString*)dateToString:(NSTimeInterval)timeInterval{
//    NSDate * d = [yourformatter dateFromString:theDate];
    
    NSTimeInterval late = timeInterval;//[d timeIntervalSince1970]*1;
    
    NSString * timeString = nil;
    
    NSDate * dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now = [dat timeIntervalSince1970]*1;
    
    NSTimeInterval cha = now - late;
    if (cha/3600 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        int num= [timeString intValue];
        
        if (num <= 1) {
            
            timeString = [NSString stringWithFormat:@"刚刚"];
            
        }else{
            
            timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
        }
        
    }
    
    if (cha/3600 > 1 && cha/86400 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        timeString = [NSString stringWithFormat:@"%@小时前", timeString];
        
    }
    
    if (cha/86400 > 1)
        
    {
        
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        int num = [timeString intValue];
        
        if (num < 2) {
            
            timeString = [NSString stringWithFormat:@"昨天"];
            
        }else if(num == 2){
            
            timeString = [NSString stringWithFormat:@"前天"];
            
        }else if (num > 2 && num <7){
            
            timeString = [NSString stringWithFormat:@"%@天前", timeString];
            
        }else if (num >= 7 && num <= 10) {
            
            timeString = [NSString stringWithFormat:@"1周前"];
            
        }
        else if ( num <= 14 ){
            timeString = @"2周前";
        }
        else if( num <= 21 ){
            timeString = @"3周前";
        }
        else if( num <= 28 ){
            timeString = @"4周前";
        }
        else if(num > 28){
            
            timeString = [NSString stringWithFormat:@"1个月前"];
        }
        
    }
    return timeString;
//    上述好像有个弊端，忘记了，对于最近的时间，可以用下面的判断
//    
//    NSTimeInterval secondPerDay = 24*60*60;
//    
//    NSDate * yesterDay = [NSDate dateWithTimeIntervalSinceNow:-secondPerDay];
//    
//    NSCalendar * calendar = [NSCalendar currentCalendar];
//    
//    unsigned uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//    
//    NSDateComponents * souretime = [calendar components:uintFlags fromDate:d];
//    
//    NSDateComponents * yesterday = [calendar components:uintFlags fromDate:yesterDay];
//    
//    if (souretime.year == yesterday.year && souretime.month == yesterday.month && souretime.day == yesterday.day){
//        
//        [yourformatter setDateFormat:@"HH:mm"];
//        
//        timeString = [NSString stringWithFormat:@" 昨天 %@ ",[self.hourformatter stringFromDate:d]];
//    }
}

+(NSTimeInterval)dateStrToInterval:(NSString *)dateStr dateFormater:(NSString *)dateFormat{
    NSDateFormatter *fo = [[NSDateFormatter alloc] init];
    [fo setDateFormat:dateFormat];
    
    NSDate *da = [fo dateFromString:dateStr];
    
    if( da == nil )
        return 0;
    
    return da.timeIntervalSince1970;
}

+(NSString*)dateIntervalToString:(NSTimeInterval)timeInterval dateFormater:(NSString *)dateFormat{
    if( !dateFormat )
        return nil;
    NSDateFormatter *fo = [[NSDateFormatter alloc] init];
    [fo setDateFormat:dateFormat];
    
    NSDate *da = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    NSString *daStr = [fo stringFromDate:da];
    return daStr;
}

//scale 压缩比例
+(UIImage *)compressImage:(UIImage *)imgSrc scale:(CGFloat)scale
{
    if( scale < 0.01) scale = 0.2;
    
    if( imgSrc == nil ) return nil;
    CGSize size = {60, 60};
    size.height = imgSrc.size.height* scale;
    size.width  = imgSrc.size.width * scale;
    UIGraphicsBeginImageContext(size);
    CGRect rect = {{0,0}, size};
    [imgSrc drawInRect:rect];
    UIImage *compressedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImg;
}

/* appInfoDic 的数据样板
 {
 resultCount = 1;
 results =     (
 {
 artistId = 开发者 ID;
 artistName = 开发者名称;
 price = 0;
 isGameCenterEnabled = 0;
 kind = software;
 languageCodesISO2A =             (
 EN
 );
 trackCensoredName = 审查名称;
 trackContentRating = 评级;
 trackId = 应用程序 ID;
 trackName = 应用程序名称";
 trackViewUrl = 应用程序介绍网址;
 userRatingCount = 用户评级;
 userRatingCountForCurrentVersion = 1;
 version = 版本号;
 wrapperType = software;
 }
 );
 */

+(void)checkinVersionUpdateWithAppId:(NSString *)appId completeBlock:(void(^)(NSError*err, BOOL haveNewVersion , NSString* newVersionUrlStr ) )completeBlock{
    if( appId == nil || appId.length == 0 ){
        return;
    }
    
    
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString *appVersion = infoDic[@"CFBundleShortVersionString"];//[@"CFBundleVersion"];
    
    
    //获取appstore的版本号
    NSError *err;
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appId];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setTimeoutInterval:30];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if( response == nil ){
        if( completeBlock ){
            completeBlock(nil, NO,nil);
        }
        return;
    }
    
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&err];
    if( err ){
        NSLog(@"err:%@", [err description]);
        
        if( completeBlock ){
            completeBlock(err, NO,nil);
        }
    }
    else{
        
        NSString *cnt = appInfoDic[@"resultCount"];
        if( [cnt isKindOfClass:[NSNumber class]] )
        {
            cnt = ((NSNumber*)cnt).stringValue;
        }

        //在appStore中，未查到app
        if( cnt.integerValue < 1 ){
            if( completeBlock ){
                completeBlock(nil, NO,nil);
            }
            return;
        }
        
        NSArray *resultsArr = infoDic[@"results"];
        if( resultsArr.count ){
            NSDictionary *resultDic = resultsArr[0];
            NSString *lastVersion = resultDic[@"version"];
            
            if( ![appVersion isEqualToString:lastVersion] ){
                NSString *url = resultDic[@"trackViewUrl"];
                if( completeBlock ){
                    completeBlock(nil,YES,url);
                }
            }
            
        }
        else
            completeBlock(nil,NO,nil);

    }
    
}


//将一个NSString类型字符串获取的长度转换成类似ASCII编码的长度，如汉字2个字节，英文以及符号1个字节这个功能。
//由于使用[NSString length]方法调用获取的长度是一个中文和一个英文都是一个字节，而使用

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

+(NSString*)subStringToIndex:(int)index  srcStr:(NSString *)srcStr{
    
    if( srcStr == nil || srcStr.length ==0 )
        return nil;
    
    NSString *a = srcStr;//@"这sfd仅仅是一个测试";
    
    NSMutableString *c = [[NSMutableString alloc] init];
    
    //需要的长度
    
    int position = index;
    
    for(int i = 0; i < a.length; i++){
        
        if(position == 0){
            
            break;
            
        }
        
        unichar ch = [a characterAtIndex:i];
        
        if (0x4e00 < ch  && ch < 0x9fff)
            
        {
            
            //若为汉字
            
            [c appendString:[a substringWithRange:NSMakeRange(i,1)]];
            
            position = position - 2;
            
        } else {
            
            [c appendString:[a substringWithRange:NSMakeRange(i,1)]];
            
            position = position - 1;
            
        }
    }
    
    return c;
}

///获取设备内存信息，大小M
+(NSUInteger)getDeviceMemorySize{
    
    unsigned long long M = [NSProcessInfo processInfo].physicalMemory;
    return  M/1024/1024.0;

    
    vm_statistics64_data_t vmStats;
    
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)(&vmStats), &infoCount);
    
    BOOL canSuccess = (kernReturn == KERN_SUCCESS);
    
    
    if( canSuccess ){
        NSLog(@"free: %lu\nactive: %lu\ninactive: %lu\nwire: %lu\nzero fill: %llu\nreactivations: %llu\npageins: %llu\npageouts: %llu\nfaults: %llu\ncow_faults: %llu\nlookups: %llu\nhits: %llu",
              vmStats.free_count * vm_page_size,
              vmStats.active_count * vm_page_size,
              vmStats.inactive_count * vm_page_size,
              vmStats.wire_count * vm_page_size,
              vmStats.zero_fill_count * vm_page_size,
              vmStats.reactivations * vm_page_size,
              vmStats.pageins * vm_page_size,
              vmStats.pageouts * vm_page_size,
              vmStats.faults,
              vmStats.cow_faults,
              vmStats.lookups,
              vmStats.hits
              );
        
    }
}


+(DeviceCategory)getDeviceCategory{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//    if ([deviceString isEqualToString:@"iPhone1,1"]) return ;//@"iPhone 1G";
//    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
//    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return DeviceCategoryIPhone4;//@"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return DeviceCategoryIPhone4s;//@"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return DeviceCategoryIPhone5;//@"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"]) return DeviceCategoryIPhone5c;
    if ([deviceString isEqualToString:@"iPhone5,4"]) return DeviceCategoryIPhone5c;
    if ([deviceString isEqualToString:@"iPhone6,2"]) return DeviceCategoryIPhone5s;
    if ([deviceString isEqualToString:@"iPhone6,1"]) return DeviceCategoryIPhone5s;
    if ([deviceString isEqualToString:@"iPhone7,2"]) return DeviceCategoryIPhone6;
    if ([deviceString isEqualToString:@"iPhone7,1"]) return DeviceCategoryIPhone6Plus;
    if ([deviceString isEqualToString:@"iPhone8,1"]) return DeviceCategoryIPhone6s;
    if ([deviceString isEqualToString:@"iPhone8,2"]) return DeviceCategoryIPhone6sPlus;
    
//    if ([deviceString isEqualToString:@"iPhone3,2"]) return v//@"Verizon iPhone 4";
    
    return DeviceCategoryOther;
}

+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"]) return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"]) return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"]) return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

#pragma mark 原点坐标转换
+(CGPoint)imgToViewWithImgOri:(CGPoint)imgOri viewSize:(CGSize)viewSize imgSize:(CGSize)imgSize{
    
    if( imgSize.height <=0 || imgSize.width <=0 || viewSize.width<=0 || viewSize.height<=0  ){
        return CGPointZero;
    }
    
    CGPoint vOri = CGPointZero;
    vOri.y = imgOri.y/imgSize.height *viewSize.height;
    vOri.x = imgOri.x/imgSize.width *viewSize.width;
    
    CGFloat scale = [UIScreen mainScreen].scale;
//    vOri.x = vOri.x/scale;
//    vOri.y = vOri.y/scale;
    
    return vOri;
}

+(CGPoint)viewToImgWithViewOri:(CGPoint)viewOri imgSize:(CGSize)imgSize viewSize:(CGSize)viewSize{
    
    if( imgSize.height <=0 || imgSize.width <=0 || viewSize.width<=0 || viewSize.height<=0  ){
        return CGPointZero;
    }
    
    CGPoint imgOri = CGPointZero;
    imgOri.y = viewOri.y/viewSize.height *imgSize.height;
    imgOri.x = viewOri.x/viewSize.width*imgSize.width;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    imgOri.y = imgOri.y*scale;
    imgOri.x = imgOri.x*scale;
    
    return imgOri;
}

#pragma mark - AlertView
+(void)showErrorAlertViewWithTitle:(NSString*)title msg:(NSString*)msg delegate:(id)del cancelBtnTitle:(NSString*)bntTitle{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:del cancelButtonTitle:bntTitle otherButtonTitles:nil , nil];
    [alertView show];
}

//+(void)showHUDAddToView:(UIView *)view title:(NSString *)title tag:(NSUInteger)tag{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.tag = tag;
//    hud.labelText = title;
//    hud.dimBackground = YES;
//}

@end




