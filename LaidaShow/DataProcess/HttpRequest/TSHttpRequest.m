//
//  TSHttpRequest.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSHttpRequest.h"
#import "AFNetworking.h"
#import "KError.h"
#import "NSString+Ext.h"
#import "TSDataProcess.h"
#import "UIImage+image.h"
#import "TSUserModel.h"
#import "TSDataBase.h"

@implementation TSHttpRequest

- (id)init{
    self = [super init];
    if( self ){
        _manager = [AFHTTPSessionManager manager];
//        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.completionQueue = dispatch_get_global_queue(0, 0);
    }
    return self;
}

+ (TSHttpRequest *)sharedHttpRequest{
    static TSHttpRequest *hp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hp = [TSHttpRequest new];
    });
    
    return hp;
}

- (NSURLSessionDataTask *)post:(NSString *)url parameters:(NSDictionary *)parameters resultBlock:(void (^)(NSDictionary *, NSError *))resultBlock{
    return [self requestWithUrl:url parameters:parameters isJson:NO method:@"POST" resultBlock:resultBlock];
}

- (NSURLSessionDataTask *)postJSON:(NSString *)url parameters:(NSDictionary *)parameters resultBlock:(void (^)(NSDictionary *, NSError *))resultBlock{
    return [self requestWithUrl:url parameters:parameters isJson:YES method:@"POST" resultBlock:resultBlock];
}

- (NSURLSessionDataTask *)get:(NSString *)url parameters:(NSDictionary *)parameters resultBlock:(void (^)(NSDictionary *, NSError *))resultBlock{
    return [self requestWithUrl:url parameters:parameters isJson:NO method:@"GET" resultBlock:resultBlock];
}

#pragma mark - ThirdLogin（第三方登录专用）
- (id)thirdLoginWithUrl:(NSString*)url para:(NSDictionary*)parameters resultBlock:(void (^)(NSDictionary *dic, NSError *err))resultBlock{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sm = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    [sm.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [sm.requestSerializer setValue:@"Basic YXBwOmFwcC1zZWNyZXQ=" forHTTPHeaderField:@"Authorization"];

    NSDictionary *para = parameters;
    NSURLSessionDataTask *dataTask =
    [sm POST:url parameters:para constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if( resultBlock ){
            
            NSDictionary *dict = nil;
            NSError *retErr = nil;
            if ( responseObject == nil ){
                retErr = [KError errorWithCode:KErrorCodeDefault msg:@"数据异常，请重试"];
            }
            else {
               //没有错误，返回不为空
               //将json转为字典
                NSError *kerr = nil;
                if( [responseObject isKindOfClass:[NSData class]] ){
                    dict = [NSJSONSerialization JSONObjectWithData:responseObject options:false error:&kerr];
                    retErr = kerr;
                }
                else if( [responseObject isKindOfClass:[NSDictionary class]] ){
                    dict = (NSDictionary*)responseObject;
                }
//                if( kerr == nil && [dict isKindOfClass:[NSDictionary class]] ){
//                    dict = dict[@"rtnResult"];
//                }
            }
            
            resultBlock(dict,retErr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if( resultBlock ){
            resultBlock(nil,error);
        }
    }];
    
    return dataTask;
}

#pragma mark - Private

- (NSURLSessionDataTask *)requestWithUrl:(NSString *)url parameters:(NSDictionary *)parameters isJson:(BOOL)isJson method:(NSString*)method resultBlock:(void (^)(NSDictionary *, NSError *))resultBlock{
    
    if( [url containsString:@"auth/loginBySocial"]
//       || [url containsString:@"user/SiteLogin/getChkCode"]
       ){
        
        return
        [self thirdLoginWithUrl:url para:parameters resultBlock:resultBlock];
    }
    
    
//    NSLog(@"\n\n============================Start Request Log==========================\n");
//    NSLog(@"para:%@",parameters);
//    NSLog(@"url:%@",url);
    
    AFURLSessionManager *manager = self.manager;
    
    AFHTTPRequestSerializer *seri = [AFHTTPRequestSerializer serializer];
    if( isJson ){
        seri = [AFJSONRequestSerializer serializer];
    }
    //接受json格式
//    if( [url containsString:@"services/Member/deleteWaterMark"] ||
//       [url containsString:@"SyPic360Segment/addSyPic360Segment"] ||
//       [url containsString:@"news/getListInfo"] ){
//        seri = [AFJSONRequestSerializer serializer];
//    }
    
    //登录需要设置固定的token
    if( [url containsString:@"auth/oauth/token"] || [url containsString:@"auth/loginByMobile"]){

        [seri setValue:@"Basic YXBwOmFwcC1zZWNyZXQ=" forHTTPHeaderField:@"Authorization"];
    }
    
    [self setupHeaderBearTokenWithSeri:seri];

    NSMutableURLRequest *request = [seri requestWithMethod:method URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 10.f;
    //3代表App端
    [request setValue:@"3" forHTTPHeaderField:@"deviceType"];
    
//    //只有删除作品时，需要传个头
//    if( [url containsString:@"services/Member/deleteWaterMark"] ){
//
//        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//        [req setHTTPMethod:@"POST"];
//        NSDictionary *dic=parameters;
//        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//
//        [req setHTTPBody:data];
//        req.timeoutInterval = 10;
//        [req setValue:@"android" forHTTPHeaderField:@"user-agent"];
//        [req addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//        request =req;
//    }
//    else if( [url containsString:@"SyPic360Segment/addSyPic360Segment"]) {
//        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//        [req setHTTPMethod:@"POST"];
//        NSDictionary *dic=parameters;
//        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//
//        [req setHTTPBody:data];
//        req.timeoutInterval = 10;
//        [req addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//        request =req;
//    }
//    else if( [url containsString:@"news/getListInfo"] ){
//    }
    
    NSLog(@"\n=========================================\n\nRequestStart:\n\nRequestUrl:\n%@\n\nRequestMethod:\n%@\n\nRequestPara:\n%@\n\nRequestHeader:\n%@\n\n=========================================\n",url,method,parameters,request.allHTTPHeaderFields);
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //NSLog(@"registe - %@",responseObject);
        NSString *robj = @"数据为空";
        if( responseObject ){
            robj = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        
        NSLog(@"\n=========================================\n\nRequestResult\n\nRequest URL:\n\n%@\n\nRequestData:\n\n%@\n\n=========================================\n",request.URL.absoluteString, robj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *dict = nil;
            NSError *retErr = nil;
            if ( error!=nil ) {
                retErr = error;
            }
            
            else if ( responseObject == nil ){
                NSError *resErr = [KError errorWithCode:KErrorCodeDefault msg:@"数据异常，请重试"];
                retErr = resErr;
            }
            else {
                //没有错误，返回不为空
                //将json转为字典
                NSError *kerr = nil;
                dict = [NSJSONSerialization JSONObjectWithData:responseObject options:false error:&kerr];

                retErr = kerr;
            }
            
            //若服务器返回401，则需要重新登录
            NSHTTPURLResponse *res = ((NSHTTPURLResponse*) response);
            if( [res isKindOfClass:[NSHTTPURLResponse class]] ){
                if( res.statusCode == 401 ){
                    retErr = [KError errorWithCode:401 msg:@"请重新登录"];
                    //清空登录用户数据
                    [[TSDataBase sharedDataBase] removeUserModel];
                }
            }
            
            if( resultBlock ){
                resultBlock(dict,retErr);
            }
        });
    }];

    [task resume];
    
    return task;
}

#warning 废弃
- (NSURLSessionDataTask *)OLDget:(NSString *)url parameters:(NSDictionary *)parameters resultBlock:(void (^)(NSDictionary *, NSError *))resultBlock{
    
    TSUserModel *um = [TSDataProcess sharedDataProcess].userModel;
    if( um.token && um.tokenType ) {
        NSString *auth = [NSString stringWithFormat:@"%@ %@",um.tokenType,um.token];
        [self.manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    }
    
    NSLog(@"\n=========================================\n\nRequestStart:\n\nRequestUrl:\n%@\n\nRequestMethod:\n%@\n\nRequestPara:\n%@\n\nRequestHeader:\n%@\n\n=========================================\n",url,@"GET",parameters,self.manager.requestSerializer.HTTPRequestHeaders);
    
    NSURLSessionDataTask *task = [self.manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *robj = @"数据为空";
        if( responseObject ){
            robj = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        NSLog(@"\n=========================================\n\nRequestResult\n\nRequest URL:\n\n%@\n\nRequestData:\n\n%@\n\n=========================================\n",task.currentRequest.URL.absoluteString, robj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //没有错误，返回不为空
            //将json转为字典
            NSError *kerr = nil;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:false error:&kerr];
//            NSLog(@"%@------",dict);
            
            if( resultBlock ){
                resultBlock(dict,kerr);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"\n=========================================\n\nRequestResult\n\nRequest URL:\n\n%@\n\nRequestData:\n\n%@\n\n=========================================\n",task.currentRequest.URL.absoluteString, error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if( resultBlock ){
                resultBlock(nil,error);
            }
        });
    }];
    
    return task;
}

- (void)setupHeaderBearTokenWithSeri:(AFHTTPRequestSerializer*)seri{
    TSUserModel *um = [TSDataProcess sharedDataProcess].userModel;
    if( um.token && um.tokenType ) {
        NSString *auth = [NSString stringWithFormat:@"%@ %@",um.tokenType,um.token];
        [seri setValue:auth forHTTPHeaderField:@"Authorization"];
    }
}

#pragma mark - 下载和上传

//异步下载文件
-(NSURLSessionDownloadTask*)downloadFileAsync:(NSString *)fileUrl
                savePath:(NSString *)savePath
        downloadingBlock:(void (^)(double))downloadingBlock
           completeBlock:(void (^)(NSError *))completeBlock
{
    NSURL *url = [[NSURL alloc] initWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *sm = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    NSURLSessionDownloadTask *task =
    [sm downloadTaskWithRequest:request
                       progress:^(NSProgress * _Nonnull downloadProgress) {
                           NSLog(@"百分之%lf",(downloadProgress.completedUnitCount/downloadProgress.totalUnitCount*1.0));
                       }
                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        //创建附件存储目录
                        if (![fileManager fileExistsAtPath:savePath]) {
                            [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
                        }
//                        NSString *imgFilePath = [savePath stringByAppendingPathComponent:[fileUrl lastPathComponent]];
                        
//                        NSString *fileAllName = [fileUrl lastPathComponent];
//                        NSString *filePathMid = [fileUrl stringByDeletingLastPathComponent];
        
                        //不带压缩参数的url ，用来获取缓存的名字
                        NSString *noCompressImgUrl = fileUrl;
                        if( [noCompressImgUrl containsString:@"?"] ){
                            noCompressImgUrl = [noCompressImgUrl componentsSeparatedByString:@"?"][0];
                        }
        
                        NSString *fileAllName = [noCompressImgUrl lastPathComponent];
                        NSString *filePathMid = [noCompressImgUrl stringByDeletingLastPathComponent];
        
                        NSString *fileAllPath = [NSString stringWithFormat:@"%@%@",[filePathMid lastPathComponent],fileAllName];
                        NSString *imgFilePath = [savePath stringByAppendingPathComponent:fileAllPath];

                        
                        [fileManager removeItemAtPath:imgFilePath error:nil];
                        return [NSURL fileURLWithPath:imgFilePath];
                    }
              completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                  
                  if( completeBlock ){
                      completeBlock(error);
                  }
              }
     ];
    
    [task resume];
    
    return task;
}

-(NSURLSessionDownloadTask*)downloadFileAsync:(NSString *)fileUrl
                                     saveAllPath:(NSString *)saveAllPath
                             downloadingBlock:(void (^)(double))downloadingBlock
                                completeBlock:(void (^)(NSError *))completeBlock
{
    NSURL *url = [[NSURL alloc] initWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *sm = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    NSURLSessionDownloadTask *task =
    [sm downloadTaskWithRequest:request
                       progress:^(NSProgress * _Nonnull downloadProgress) {
                           NSLog(@"百分之%lf",(downloadProgress.completedUnitCount/downloadProgress.totalUnitCount*1.0));
                       }
                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        //创建附件存储目录
//                        if (![fileManager fileExistsAtPath:savePath]) {
//                            [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
//                        }
                        NSString *fileAllPath = saveAllPath;//[savePath stringByAppendingPathComponent:[fileUrl lastPathComponent]];
                        [fileManager removeItemAtPath:fileAllPath error:nil];
                        return [NSURL fileURLWithPath:fileAllPath];
                    }
              completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                  
                  if( completeBlock ){
                      completeBlock(error);
                  }
              }
     ];
    
    [task resume];
    
    return task;
}

- (void)uploadImg:(UIImage*)img url:(NSString*)url parameters:(NSDictionary*)parameters completeBlock:(void(^)(NSError *err))completeBlock{
    if(  img == nil ){
        NSLog(@"图片为空");
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sm = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    [sm.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *para = parameters;//[[self class] enctryParmeters:parameters];
    
    //设置头token
    [self setupHeaderBearTokenWithSeri:sm.requestSerializer];
    
    NSURLSessionDataTask *dataTask =
    [sm POST:url parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imgData = UIImageJPEGRepresentation(img, 0.1);
        //上传的参数名
        NSString *name = @"avatar";
        //NSString *name = @"upfile";
        //上传的文件名
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",name];
        
        [formData appendPartWithFileData:imgData name:name fileName:fileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"abc1");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSData *data = [NSDictionary dic]
        NSLog(@"上传水印成功 -- %@",responseObject);
        NSError *err = nil;
        if( [responseObject isKindOfClass:[NSDictionary class]] ){
            NSDictionary *dic = (NSDictionary*)responseObject;
            err = [[TSDataProcess sharedDataProcess] returnErrorWithResult:dic];
        }
        if( completeBlock ){
            completeBlock(err);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        if( completeBlock ){
            completeBlock(error);
        }
    }];
    
}

-(void)uploadWaterMarkImg:(UIImage *)img url:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(void (^)(NSDictionary *dataDic, NSError *))completeBlock{
    
    if(  img == nil ){
        NSLog(@"图片为空");
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sm = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    [sm.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *para = parameters;//[[self class] enctryParmeters:parameters];
    
    //设置头token
    [self setupHeaderBearTokenWithSeri:sm.requestSerializer];
    
    NSURLSessionDataTask *dataTask =
    [sm POST:url parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imgData = UIImageJPEGRepresentation(img, 0.1);
        //上传的参数名
        //NSString *name = @"avatar";
        NSString *name = @"upfile";
        //上传的文件名
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",name];
        
        [formData appendPartWithFileData:imgData name:name fileName:fileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"abc1");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSData *data = [NSDictionary dic]
        NSLog(@"上传水印成功 -- %@",responseObject);
        NSError *err = nil;
        NSDictionary *dic = nil;
        if( [responseObject isKindOfClass:[NSDictionary class]] ){
            dic = (NSDictionary*)responseObject;
            err = [[TSDataProcess sharedDataProcess] returnErrorWithResult:dic];
        }
        if( completeBlock ){
            completeBlock(dic,err);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        if( completeBlock ){
            completeBlock(nil,error);
        }
    }];
    
}



- (NSURLSessionDataTask*)uploadImgs:(NSArray<UIImage *> *)imgs url:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(void (^)(NSError *,NSDictionary*))completeBlock{
    NSLog(@"uploadParameters%@",parameters);
    if(  imgs.count == 0 ){
        NSLog(@"图片为空");
        return nil;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sm = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    [sm.requestSerializer setValue:@"multipart/form-data; boundary=<calculated when request is sent>" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *para = parameters;//[[self class] enctryParmeters:parameters];
    
    //设置头token
    [self setupHeaderBearTokenWithSeri:sm.requestSerializer];
    
    NSURLSessionDataTask *dataTask =
    [sm POST:url parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger i=0;
        for( UIImage *img in imgs ){
            NSData *imgData = UIImageJPEGRepresentation(img, 1);
            //上传的参数名
            //NSString *name = [@"file" stringByAppendingString:@(i).stringValue];
            NSString *name = @"file";//@"syPic";
            if( [url containsString:@"product/services/SyPic360/uploadDoneSyPics"] ){
                name = @"syPic";
            }
            //上传的文件名
            NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",name,(int)i];
            
//            fileName = @"file";
            
            [formData appendPartWithFileData:imgData name:name
                                    fileName:fileName mimeType:@"image/jpeg"];
            NSLog(@"filename -- %@",fileName);
            i++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadImgProgress=%f",uploadProgress.completedUnitCount*1.0/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"uploadImgComplete -- %@",responseObject);
        //        NSData *data = [NSDictionary dic]
        NSError *err = nil;
        NSDictionary *dataDic = nil;
        if( [responseObject isKindOfClass:[NSDictionary class]] ){
            NSDictionary *dic = (NSDictionary*)responseObject;
            err = [[TSDataProcess sharedDataProcess] returnErrorWithResult:dic];
            if( err == nil ){
                dataDic = dic[@"data"];
            }
        }
        if( completeBlock ){
            
            completeBlock(err,dataDic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        if( completeBlock ){
            completeBlock(error,nil);
        }
    }];
    
    return dataTask;
}


- (NSURLSessionDataTask*)uploadVideo:(NSURL*)videoUrl url:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(void (^)(NSError *,NSDictionary*))completeBlock{
    NSLog(@"uploadVideoParameters%@",parameters);

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sm = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    [sm.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    //设置头token
    [self setupHeaderBearTokenWithSeri:sm.requestSerializer];
    
    NSDictionary *para = parameters;//[[self class] enctryParmeters:parameters];
    NSURLSessionDataTask *dataTask =
    [sm POST:url parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *videoData = nil;
        if( [videoUrl isKindOfClass:[NSURL class]] ){
            videoData = [NSData dataWithContentsOfURL:(NSURL*)videoUrl];
        }
//
//        if( fileName == nil ){
//            fileName = [NSString stringWithFormat:@"%f.mp4",[NSDate new].timeIntervalSince1970];
//        }else{
//            fileName = [fileName stringByAppendingString:@".mp4"];
//        }
        //上传的参数名
        //NSString *name = [@"file" stringByAppendingString:@(i).stringValue];
        NSString *name = @"video";
        //上传的文件名
        NSString *fileName = @"video.mp4";//[NSString stringWithFormat:@"%@%d.jpg",name,(int)i];
        
        [formData appendPartWithFileData:videoData name:name
                                fileName:fileName mimeType:@"video/mp4"];
        NSLog(@"filename -- %@",fileName);
        
        //添加封面
        UIImage *cover = [UIImage getVideoFirstViewImage:videoUrl];
        if( cover ){
            [formData appendPartWithFileData:UIImageJPEGRepresentation(cover, 1) name:@"thumbnail" fileName:@"thumbnail.jpg" mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadImgProgress=%f",uploadProgress.completedUnitCount*1.0/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"uploadIMg -- %@",responseObject);
        //        NSData *data = [NSDictionary dic]
        NSError *err = nil;
        NSDictionary *dataDic = nil;
        if( [responseObject isKindOfClass:[NSDictionary class]] ){
            NSDictionary *dic = (NSDictionary*)responseObject;
            err = [[TSDataProcess sharedDataProcess] returnErrorWithResult:dic];
            if( err == nil ){
                dataDic = dic[@"data"];
            }
        }
        if( completeBlock ){
            
            completeBlock(err,dataDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        if( completeBlock ){
            completeBlock(error,nil);
        }
    }];
    
    return dataTask;
}

@end
