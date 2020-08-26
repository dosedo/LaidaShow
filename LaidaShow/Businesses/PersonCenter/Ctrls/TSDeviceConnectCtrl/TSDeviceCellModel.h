//
//  TSDeviceCellModel.h
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TSDeviceConnectState){
    TSDeviceConnectStateConnected = 0,   //已连接
    TSDeviceConnectStateNotConnected,    //未连接
    TSDeviceConnectStateConnecting       //连接中
};
/**
 设备列表cell
 */
@interface TSDeviceCellModel : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) TSDeviceConnectState connectState;

@end



