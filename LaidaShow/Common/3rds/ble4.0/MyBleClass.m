//
//  MyBleClass.m
//  MyBleDemo
//
//  Created by Allen Ning on 15/6/3.
//  Copyright (c) 2015年 my. All rights reserved.
//

#import "MyBleClass.h"
@interface MyBleClass ()

@end

@implementation MyBleClass

-(id)init
{
    if(self=[super init])
    {
        /////////////////////////////////////
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.shields = [NSMutableArray arrayWithCapacity:30];
        //////////////////////////////////////
        
        
        [self myBleSetConnectBool:NO err:nil];//没有连接
    }
    return self;
}





#pragma mark -
#pragma mark CBCentralManagerDelegate methods

/*
 *  @method centralManagerDidUpdateState:
 *
 *  @param central The central whose state has changed.
 *
 *  @discussion Invoked whenever the central's state has been updated.
 *      See the "state" property for more information.
 *当Central Manager被初始化，我们要检查它的状态，以检查运行这个App的设备1.是不是支持BLE。实现以下的代理方法
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //
    BtLog(@"%s state change",__func__);
    //
    if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"Central Manager Off");
        
    }
    else if (central.state == CBCentralManagerStatePoweredOn) {
        
        NSLog(@"Central Manager On");
       //查找设备
        [self MybleStartFindBle:NO];
    }
}
/*
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @discussion Invoked when the central discovered a peripheral while scanning.
 *      The advertisement / scan response data is stored in "advertisementData", and
 *      can be accessed through the CBAdvertisementData* keys.
 *      The peripheral must be retained if any command is to be performed on it.
 *  2.扫描设备 得到扫描的设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
   // BtLog(@"");
    //    if( !(peripheral.UUID))
    //    {
    //        return;
    //    }
    //    if( !(peripheral.name))
    //    {
    //        return;
    //    }
    //
    //NSLog(@"Discovered: %@", peripheral.name);
    
    // NSLog(@"Discovered**: %@", [advertisementData objectForKey: @"kCBAdvDataLocalName"]);
    /*
     NSLog(@"Discovered**: %@", advertisementData);
     [advertisementData objectForKey: @"kCBAdvDataLocalName"];
     
     Discovered**: {
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = SimpleBLEPeripheral;
     kCBAdvDataServiceUUIDs =     (
     1910
     );
     kCBAdvDataTxPowerLevel = 0;
     }
     */
    
    
    // Stops scanning for peripheral
    /* [self.manager stopScan];
     if (self.peripheral != peripheral) {
     self.peripheral = peripheral;
     NSLog(@"Connecting to peripheral %@", peripheral);
     // Connects to the discovered peripheral
     [self.manager connectPeripheral:peripheral options:nil];*/
    
    // if ([self.shields count] == 0) {
    // [self.shields addObject:peripheral];
    
    //}
    if ([self.shields count] > 0) {//如果已保存多个蓝牙
        //判断现在扫描的地址是不是已存在了
        for (int i = 0; i < [self.shields count]; i++) {
            CBPeripheral *per = [self.shields objectAtIndex:i];
            if(per == peripheral)//如果已存在不执行了
            {
                return;
            }
        }
    }
    //添加设备
    [self.shields addObject:peripheral];
    //把查到的设备给代理
    if( self.delegate && [self.delegate respondsToSelector:@selector(MyBleDelegateDiscover:)]){
        [self.delegate MyBleDelegateDiscover:(int)self.shields.count];
    }
    //看保存的所有设备
    NSLog(@"Discovered_shields: %@", self.shields);
    NSLog(@"Discovered_Lengs: %ld", (unsigned long)self.shields.count);   
}

/*
 *  @method centralManager:didConnectPeripheral:
 *
 *  @discussion Invoked whenever a connection has been succesfully created with the peripheral.
 *3.当点连接时会调用
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    BtLog(@"");
    NSLog(@"===连接%@===",peripheral);
    self.connectedShield = peripheral;
    self.connectedShield.delegate = self;
    [self.connectedShield discoverServices:nil];
}
/*
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 * 4.查找当前主程序的服务ID
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BtLog(@"");
    
    
    //查找所有服务 如果是当前服务 则查打该服务下的有的特征
        for (CBService *service in peripheral.services ) {
    
            CBUUID *serviceUUID = [CBUUID UUIDWithString:BleServiceUUIDBleString];
            
            //如果找到写的去服务 则继续查找服务下所有特性
            if ([service.UUID isEqual:serviceUUID]) {
                //BtLog(@"Discovering Characteristics...");
                [self.connectedShield discoverCharacteristics:nil forService:service];
            }
        }
}
/*
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 返回当前服务的UUID的所有特性
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    BtLog(@"");
    if (error)//如果有错误
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        
        //if ([self.delegate respondsToSelector:@selector(DidNotifyFailConnectChar:withPeripheral:error:)])
           // [self.delegate DidNotifyFailConnectChar:nil withPeripheral:nil error:nil];
        
        return;
    }
    
    //查找所盖服务的所有特性如果是 发送就把当前特性保存起来
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BleCharacteristicTXUUIDString]])
        {
            NSLog(@"Discovered read characteristics:%@ for service: %@", characteristic.UUID, service.UUID);
            
            self.readCharacteristic = characteristic;//保存读的特征
            
            //回掉函数
           // if ([self.delegate respondsToSelector:@selector(DidFoundReadChar:)])
                //[self.delegate DidFoundReadChar:characteristic];
            
            break;
        }
    }
    
    //查找所盖服务的所有特性如果是 接收 就把当前特性保存起来  并且开通知
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BleCharacteristicRXUUIDString]])
        {
            
            NSLog(@"Discovered write characteristics:%@ for service: %@", characteristic.UUID, service.UUID);
            self.writeCharacteristic = characteristic;//保存写的特征
            //接收开启通知
                 [self.connectedShield setNotifyValue:YES forCharacteristic:self.writeCharacteristic];
            ////
            
        
            //回掉函数
            //if ([self.delegate respondsToSelector:@selector(DidFoundWriteChar:)])
               // [self.delegate DidFoundWriteChar:characteristic];
            
            break;
            
            
        }
    }
}
/*
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forCharacteristic: @/link call.
    向蓝牙发送数据调用
 */

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    BtLog(@"");
    
}
/*
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 
 开启通知时调用
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    BtLog(@"");
    ///

    [self myBleSetConnectBool:YES err:error];//连接
}

/*
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 收到数据了长度
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    static int a = 18;
   // BtLog(@"");
    NSLog(@"收到设备发出的消息");
//    
    NSData *data = [characteristic value];
//    NSLog(@"Read leng = %ld ** %@",data.length,data);
//    //
//   // if(self.delegate != NULL)
//   // {
//    [self.delegate MyBleDelegateDisConnectBle:data];
//    //}
//    ///////////////////////////////////
    
    NSLog(@"收到设备指令：%@",data.description);
    
    Byte *testByte = (Byte *)[data bytes];
    
    if (testByte[10] == 0) {
        if (testByte[6] == 0) {
            a = 18 ;
        }
        if (testByte[6] == 1) {
            a = 36;
        }
        if (testByte[6] == 2) {
            a = 72;
        }
    }
//    NSLog(@"@@@@qqqqqqq@@%d",a);
//    if (testByte[10]< a) {
        NSLog(@"123@@@@@@%hhu",testByte[10]);
        
    NSString *endVideo = [NSString stringWithFormat:@"%d",testByte[6]];
    [[NSNotificationCenter defaultCenter]postNotificationName:MyBleDidRecieveDeviceMsgNotification object:nil userInfo:@{@"index":[NSString stringWithFormat:@"%d",testByte[10]],@"isEndRecordVideo":endVideo}];
        
//        if( testByte[10] == a-1 )
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"postNavigation" object:nil];
//    }
}
/*
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @discussion Invoked whenever an existing connection with the peripheral has been teared down.
 * 当断开连接时调用  断开蓝牙电源时也可以调用
 */


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    BtLog(@"");

    [self myBleSetConnectBool:NO err:error] ;//没有连接
}
/*
 *  @method centralManager:didRetrievePeripheral:
 *
 *  @discussion Invoked when the central retrieved a list of known peripherals.
 *      See the -[retrievePeripherals:] method for more information.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
 //   BtLog(@"");
}

/*
 *  @method centralManager:didRetrieveConnectedPeripherals:
 *
 *  @discussion Invoked when the central retrieved the list of peripherals currently connected to the system.
 *      See the -[retrieveConnectedPeripherals] method for more information.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripheralArray {
  //  BtLog(@"");
}





/*
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @discussion Invoked whenever a connection has failed to be created with the peripheral.
 *      The failure reason is stored in "error".
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  //  BtLog(@"");
    
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    NSLog(@"00000");
}

/*
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
 //   BtLog(@"");
}

/*
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
  //  BtLog(@"");
}

/*
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
   // BtLog(@"");
}


/*
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
   // BtLog(@"");
}








/*
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
   // BtLog(@"");
}

/*
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
  //  BtLog(@"");

}
//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
////
//}

/*
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    BtLog(@"");
}
////my
//查找设备
-(void)MybleStartFindBle: (BOOL) isDelAll
{

    if(isDelAll)
    {
        [self.shields removeAllObjects];
    }
    
    
    [self.cbManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BleServiceUUIDBleString]]
        options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

}
//停止查找
-(void)MybleStopFindBle
{
    [self.cbManager stopScan];
}

//连接从机
-(void)MybleConnectBle : (int)shieldsCount
{
    
    [self MybleStopFindBle];//停止查找
    //
    //从扫描的从机数组中根据编号得到从机
    if (self.shields.count) {
        CBPeripheral *per = [self.shields objectAtIndex:shieldsCount];
        self.myBleConnectInt  = shieldsCount;
        NSLog(@"===per%@===",per);
        //连接
        [self.cbManager connectPeripheral:per options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        NSLog(@"===per%@===",per);
        

    }
//更新当前数组中的编号

}
//断开连接连接
-(void)MybleDisConnectBle : (int)shieldsCount
{
    //从扫描的从机数组中根据编号得到从机
    CBPeripheral *per = [self.shields objectAtIndex:shieldsCount];
    //
      [self.cbManager cancelPeripheralConnection:per];
}
-(void)MybleDisConnectBleAll//断开所有已连接的设备
{
    for(int a=0;a< self.shields.count;a++)
    {
        /*typedef NS_ENUM(NSInteger, CBPeripheralState) {
            CBPeripheralStateDisconnected = 0,
            CBPeripheralStateConnecting,
            CBPeripheralStateConnected,
        } NS_AVAILABLE(NA, 7_0);
        */
    CBPeripheral *per = [self.shields objectAtIndex:a];
        //NSLog(@"%d****",per.state);
        if(per.state == 2)//如果已连接
        {
            [self MybleDisConnectBle : a];
        }
    }
    
    if(self.connectedShield && self.connectedShield.state == 2 ){
        [self disConnectBleWithShield:self.connectedShield];
    }
}
//发送数据 data
-(void)MybleSendData : (NSData*)data
{
    [self.connectedShield writeValue:data forCharacteristic:self.readCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)MybleSendBytes:(Byte *)mydata :(int)myleng
{
    NSData *data=[NSData dataWithBytes:mydata length:myleng];
    NSLog(@"\n发送设备指令:%@",data);
    [self MybleSendData:data];
}

-(void)myBleSetConnectBool : (BOOL) thisBool err:(NSError*)err
{
    self.myBleConnectBool = thisBool;
    
    
    if( self.delegate && [_delegate respondsToSelector:@selector(MyBleDelegateSetConnectBool:err:)] ){
        [self.delegate MyBleDelegateSetConnectBool:thisBool err:err];
    }
}

#pragma mark - wkadd
/**
 连接设备
 
 @param shield 设备信息
 */
- (void)connectingBleWithShield:(CBPeripheral*)shield{
    if( shield == nil ) return;
    
    [self MybleStopFindBle];//停止查找
    //
    //从扫描的从机数组中根据编号得到从机
    if (self.shields.count ) {
        CBPeripheral *per = shield;
        self.myBleConnectInt  = [self.shields indexOfObject:shield];;
        //连接
        [self.cbManager connectPeripheral:per options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        
    }
}

/**
 断开设备
 
 @param shield 设备信息
 */
- (void)disConnectBleWithShield:(CBPeripheral*)shield{
    if( shield == nil ) return;
    [self.cbManager cancelPeripheralConnection:shield];
}


@end
