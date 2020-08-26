//
//  TSHttpRequest.h
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AFHTTPSessionManager;

@interface TSHttpRequest : NSObject

@property (nonatomic, strong,readonly) AFHTTPSessionManager *manager;

+ (TSHttpRequest*)sharedHttpRequest;

-(NSURLSessionDataTask *)post:(NSString*)url parameters:(NSDictionary*)parameters resultBlock:(void(^)(NSDictionary *result, NSError *err))resultBlock;

-(NSURLSessionDataTask *)postJSON:(NSString*)url parameters:(NSDictionary*)parameters resultBlock:(void(^)(NSDictionary *result, NSError *err))resultBlock;

-(NSURLSessionDataTask *)get:(NSString*)url parameters:(NSDictionary*)parameters resultBlock:(void(^)(NSDictionary *result, NSError *err))resultBlock;

//异步下载文件
-(NSURLSessionDownloadTask*)downloadFileAsync:(NSString *)fileUrl
                savePath:(NSString *)savePath
        downloadingBlock:(void (^)(double))downloadingBlock
           completeBlock:(void (^)(NSError *))completeBlock;


/**
 异步下载文件

 @param fileUrl 文件的url
 @param saveAllPath 文件的保存的全路径包括扩展名
 @param downloadingBlock 回调
 @param completeBlock 回调
 @return task
 */
-(NSURLSessionDownloadTask*)downloadFileAsync:(NSString *)fileUrl
                                  saveAllPath:(NSString *)saveAllPath
                             downloadingBlock:(void (^)(double))downloadingBlock
                                completeBlock:(void (^)(NSError *))completeBlock;

//上传图片
- (void)uploadImg:(UIImage*)img url:(NSString*)url parameters:(NSDictionary*)parameters completeBlock:(void(^)(NSError *err))completeBlock;

- (void)uploadWaterMarkImg:(UIImage*)img url:(NSString*)url parameters:(NSDictionary*)parameters completeBlock:(void(^)(NSDictionary *dataDic,NSError *err))completeBlock;


- (NSURLSessionDataTask*)uploadImgs:(NSArray< UIImage*>*)imgs url:(NSString*)url parameters:(NSDictionary*)parameters completeBlock:(void(^)(NSError *err,NSDictionary*result))completeBlock;

- (NSURLSessionDataTask*)uploadVideo:(NSURL*)videoUrl url:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(void (^)(NSError *,NSDictionary*))completeBlock;

@end
