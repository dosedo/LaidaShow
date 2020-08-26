//
//  MyBleClass.h
//  MyBleDemo
//
//  Created by Allen Ning on 15/6/3.
//  Copyright (c) 2015年 my. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MyPublic.h"
#import <CoreBluetooth/CoreBluetooth.h>

///
//#define DEBUG 0
#ifdef DEBUG
#   define BtLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define BtLog(...)
#endif

////
#ifndef MYBLECLASS_DEFINE
#define MYBLECLASS_DEFINE

#define BleServiceUUIDBleString @"1910"
#define BleCharacteristicRXUUIDString @"FFF4"//@"FFF4"
#define BleCharacteristicTXUUIDString @"FFF1"//@"FFF2"

//收到设备发送的通知
#define MyBleDidRecieveDeviceMsgNotification @"BleDidRecieveDeviceMsgNotification"

#endif
///定一个代理协议
@protocol MyBleDelegate <NSObject>

//-(void)MybleConnectBle;
@optional//可以不用实现
//如果发现设备调用 设备的数量
-(void)MyBleDelegateDiscover : (int) bleNum;

//开始扫描
- (void)MyBleDelegateStartedScan;

@required//必须要实现
//更新当前的连接状态
-(void)MyBleDelegateSetConnectBool : (BOOL) thisBool err:(NSError*)err;
//读取到的数据
-(void)MyBleDelegateDisConnectBle : (NSData *) readData;
@end

////
@interface MyBleClass : NSObject< CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
}
@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) NSMutableArray *shields;
@property (strong, nonatomic) CBPeripheral *connectedShield;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic *readCharacteristic;
//是不是连接成功
@property (nonatomic) BOOL myBleConnectBool;
//当前连接的数组编号 断开时也根据这个断开
@property (nonatomic) NSInteger myBleConnectInt;
@property (weak,nonatomic) id <MyBleDelegate> delegate;//代理一定要assign这个
//更新当前的连接状态
-(void)myBleSetConnectBool : (BOOL) thisBool err:(NSError*)err;
////my

-(void)MybleStartFindBle : (BOOL) isDelAll;
-(void)MybleStopFindBle;
-(void)MybleConnectBle : (int)shieldsCount;//连接从机
-(void)MybleDisConnectBle : (int)shieldsCount;//断开连接连接
-(void)MybleDisConnectBleAll;//断开所有已连接的设备
//发送数据 data
-(void)MybleSendData : (NSData*)data;
- (void)MybleSendBytes:(Byte *)mydata :(int)myleng;
////

/**
 连接设备

 @param shield 设备信息
 */
- (void)connectingBleWithShield:(CBPeripheral*)shield;

/**
 断开设备

 @param shield 设备信息
 */
- (void)disConnectBleWithShield:(CBPeripheral*)shield;
@end
