//
//  BlePeripheral.h
//  MyBleTest2
//
//  Created by admin on 2017/3/30.
//  Copyright © 2017年 mycj.wwd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlePeripheral : NSObject
@property(nonatomic,copy)CBPeripheral *m_peripheral;
@property(nonatomic,copy) NSString *m_peripheralIdentifier;
@property(nonatomic,copy) NSString *m_peripheralLocaName;
@property(nonatomic,copy) NSString *m_peripheralName;
@property(nonatomic,copy) NSString *m_peripheralUUID;
@property(nonatomic,copy) NSNumber *m_peripheralRSSI;
@property(nonatomic)     NSInteger  m_peripheralServices;
@end
