//
//  BlePeripheral.m
//  MyBleTest2
//
//  Created by admin on 2017/3/30.
//  Copyright © 2017年 mycj.wwd. All rights reserved.
//
#import "BlePeripheral.h"

@implementation BlePeripheral
-(id) init
{
    if((self = [super init])) {
        self.m_peripheralIdentifier = @"";
        self.m_peripheralLocaName   = @"";
        self.m_peripheralName       = @"";
        self.m_peripheralUUID       = @"";
        self.m_peripheralRSSI       = 0;
        self.m_peripheralServices   = 0;
    }
    return self;
}
@end
