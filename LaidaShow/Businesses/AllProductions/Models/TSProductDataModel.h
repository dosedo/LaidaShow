//
//  TSProductDataModel.h
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSProductDataModel : NSObject

@property (nonatomic,strong) NSString *applyPicture;//  = "";
@property (nonatomic,strong) NSString *audio; // = "m/The piano dance.mp3";
@property (nonatomic,assign) NSInteger audioNum;// = 1;
@property (nonatomic,strong) NSString *audioUrls;  //= "<null>";
@property (nonatomic,strong) NSString *category;// = 2;
@property (nonatomic,strong) NSString *categoryName;//  = "珠宝";
@property (nonatomic,strong) NSString *collectCount;// = 1;
@property (nonatomic,strong) NSString *collected;// = 0;
@property (nonatomic,strong) NSString *createtime;//  = "2018-12-21 14:37:11.0";
@property (nonatomic,strong) NSString *describe;//  = "外观造型: 植物，高约15cm";
@property (nonatomic,assign) NSInteger deviceType;// = 0;
@property (nonatomic,assign) NSInteger firstImageSize;// = 0;
@property (nonatomic,assign) NSInteger firstPage;// = 0;
@property (nonatomic,strong) NSString *gif;// = "g/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83.gif";
@property (nonatomic,strong) NSString *headimgurl;//  = "AVATAR/2019/01/02/1139/153a268e9b734fcfb298c77c36c03280.jpg";
@property (nonatomic,assign) NSInteger homeIndex;// = 0;
@property (nonatomic,strong) NSString *ID;// = 9f85a33f7891450190e234e7dd217d83;
@property (nonatomic,strong) NSString *imageDeal;//  = "<null>";
@property (nonatomic,assign) NSInteger imageHeight;// = 0;
@property (nonatomic,assign) NSInteger imageWidth;// = 0;
@property (nonatomic,assign) BOOL isDelete;// = 0;
@property (nonatomic,assign) BOOL isPraise;// = 0;
@property (nonatomic,strong) NSNumber* isPublic;
//@property (nonatomic, strong) NSString *isPublicStr;
@property (nonatomic,strong) NSString *liked;// = 0;
@property (nonatomic,strong) NSString *link;// = "https://item.jd.com/1356438324.html";
@property (nonatomic,assign) NSInteger lookCount;// = 3;
@property (nonatomic,strong) NSString *modifyPicture;//  = "";
@property (nonatomic,strong) NSString *name;// = "旺财守业玉白菜百财貔貅金蟾蜍招财摆件";
@property (nonatomic,strong) NSString *nickname;// = "";
@property (nonatomic,strong) NSString *picStepEnum;// = "<null>";
@property (nonatomic,strong) NSString *picTags;// = "";
@property (nonatomic,strong) NSString *picture;// = "r/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83/0.png";
@property (nonatomic,strong) NSString *pictureName;// = "";
@property (nonatomic,assign) NSInteger pictureNum;// = 36;
@property (nonatomic,strong) NSString *pictureOriginal;// = "";
@property (nonatomic,strong) NSString *pictureOriginalUrl;// = "";
@property (nonatomic,strong) NSString *pictureShare;// = "";
@property (nonatomic,strong) NSString *pictureUrl;// = "r/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83/";
@property (nonatomic,strong) NSMutableArray *pictureUrls;
@property (nonatomic,assign) NSInteger plattype;// = 0;
@property (nonatomic,strong) NSString *plist;// = "<null>";
@property (nonatomic,strong) NSString *praise;// = 0;
@property (nonatomic,strong) NSString *price;// = 86;
@property (nonatomic,assign) NSInteger publicLevel;// = 1;
@property (nonatomic,strong) NSString *recordBase64;// = "";
@property (nonatomic,strong) NSString *saleCount;// = 191;
@property (nonatomic,assign) NSInteger sharetype;// = 0;
@property (nonatomic,strong) NSString *sign;// = "";
@property (nonatomic,strong) NSString *sortFlag;// = 0;
@property (nonatomic,assign) NSInteger status;// = 0;
@property (nonatomic,strong) NSString *step;// = "<null>";
@property (nonatomic,strong) NSString *suffix;// = png;
@property (nonatomic,strong) NSString *tid;// = 0;
@property (nonatomic,strong) NSString *title;// = "旺财守业玉白菜百财貔貅金蟾蜍招财摆件";
@property (nonatomic,strong) NSString *token;// token = "";
@property (nonatomic,strong) NSString *uid;// = 1139;
@property (nonatomic,strong) NSString *userName;// = "三无先森";
@property (nonatomic,strong) NSString *video;// = "v/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83.mp4";
//@property (nonatomic, strong) NSString *gif;

@property (nonatomic, strong) NSString *segmentStatus;// ;作品申请服务标识：在作品实体类增加属性 0：可申请服务 1：不可申请
@property (nonatomic, strong) NSString *type; //作品类型，0 三维作品，1视频作品
@end
