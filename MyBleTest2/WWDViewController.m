//
//  WWDViewController.m
//  MyBleTest2
//
//  Created by maginawin on 14-8-11.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "WWDViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
static int clearflag=0;
static int connectflag=0;
static int fullflag;
static int A=20;  //20字节包
static int B=2;     //2个字节存放包的标志位。这个根据需求自己设置
static int C=18;    //18字节存放数据
@interface WWDViewController ()

//- (NSString*)hexadecimalString:(NSData*)data;
//- (NSData*)dataWithHexstring:(NSString*)hexstring;
- (void)writeToPeripheral:(NSString*)data;

@property (strong, nonatomic) NSMutableString* values;
@property (strong, nonatomic) NSMutableString* valuesTest;
@property (nonatomic) NSUInteger intTest;
@end

@implementation WWDViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
//    self.scanClick;
    self.values = [NSMutableString stringWithString:@""];
    _myPeripherals = [NSMutableArray array];
    _tableView.dataSource = self;
    _tableView.delegate = self;
//    self.valuesTest = [NSMutableString stringWithString:@"a\n"];
//    [self.valueTextView setText:self.valuesTest];
//    [self.valueTextView scrollRectToVisible:CGRectMake(0, self.valueTextView.contentSize.height - 15, self.valueTextView.contentSize.width, 10) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//扫描
- (void)scanClick{
    NSLog(@"正在扫描外设...");
//    [self.myCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    
    [self.myCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000ffe0-0000-1000-8000-00805f9b34fb"]] options:nil];
    if(_myPeripheral != nil){
        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
    }
    connectflag=0;
    double delayInSeconds = 15.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.myCentralManager stopScan];
        NSLog(@"扫描超时,停止扫描!");
    });
}

//连接
- (void)connectClick{
    [self.myCentralManager connectPeripheral:self.myPeripheral options:nil];
    connectflag=1;
}
//断开
- (void)stop{
    [_myCentralManager cancelPeripheralConnection:_myPeripheral];
}
//开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开, 请扫描外设!");
            break;
            
        default:
             NSLog(@"蓝牙未打开!");
            break;
    }
}
//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0);
//{
//    //这个函数一看就知道了，当外设更新了RSSI的时候被调用，当然，外设不会无故给你老是发RSSI，听硬件那边工程师说，蓝牙协议栈里面的心跳包是可以把RSSI带过来的，但是不知道什么情况，被封杀了，你的要主动调用 [peripheral readRSSI];方法，人家外设才给你回RSSI，不过这个方法现在被弃用了。用下面的方法来接收
//    //已经弃用
//    
//}
///*!
// *  @method peripheral:didReadRSSI:error:
// *
// *  @param peripheral	The peripheral providing this update.
// *  @param RSSI			The current RSSI of the link.
// *  @param error		If an error occurred, the cause of the failure.
// *
// *  @discussion			This method returns the result of a @link readRSSI: @/link call.
// */
//- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error NS_AVAILABLE(NA, 8_0);
//{
//    
//    //同上，这个就是你主动调用了 [peripheral readRSSI];方法回调的RSSI，你可以根据这个RSSI估算一下距离什么的
//    NSLog(@" peripheral Current RSSI:%@",RSSI);
//    
//}
//查到外设后的方法,peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"已发现 peripheral: %@ rssi: %@, uuid: %@ advertisementData: %@", peripheral, RSSI, peripheral.identifier, advertisementData);
    
    BOOL replace = NO;
    // Match if we have this device from before
    for (int i=0; i < _nDevices.count; i++) {
        CBPeripheral *p = [_nDevices objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (!replace) {
        [_nDevices addObject:peripheral];
        [_bluetoothTable reloadData];
    }
    [_myPeripherals addObject:peripheral];
//    NSInteger count = [_myPeripherals count];
//    NSLog(@"my periphearls count : %ld\n", (long)count);
    [_tableView reloadData];
 //   self.myPeripheral = peripheral;//~~~~~~~~~~~~~
  //  [self.myCentralManager stopScan];
//    self.connectClick;
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"成功连接 peripheral: %@ with UUID: %@",peripheral, peripheral.identifier);
    [_peripheralState setText:@"正在链接中……"];
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
    NSLog(@"扫描服务...");
    [_attention setText:@""];
    [self.myCentralManager stopScan];
    clearflag=0;
}

//掉线时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"periheral has disconnect");
    NSLog(@"掉线原因是:%@",error);
    [_peripheralState setText:@"掉线"];
    [_peripheralState setTextColor:[UIColor redColor]];
    [_peripheralRssi setText:@"--"];
    [_attention setText:@"connect failure, please try again!"];
    //[self connectClick];
    if( connectflag==1)
    {
    [self.myCentralManager connectPeripheral:peripheral options:nil];
    }
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败原因：%@", error);
    [_peripheralState setText:@"链接失败"];
    [_peripheralState setTextColor:[UIColor redColor]];
    [_peripheralRssi setText:@"--"];
    [_attention setText:@"connect failure, please try again!"];
}

//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"发现服务!");
    int i = 0;
    for(CBService* s in peripheral.services){
        [self.nServices addObject:s];
    }
    for(CBService* s in peripheral.services){
        NSLog(@"%d :服务 UUID: %@(%@)", i, s.UUID.data, s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
        NSLog(@"扫描Characteristics...");
    }
}

//已发现characteristcs
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for(CBCharacteristic* c in service.characteristics){
        NSLog(@"特征 UUID: %@ (%@)", c.UUID.data, c.UUID);
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"0000ffe1-0000-1000-8000-00805f9b34fb"]]){
            self.writeCharacteristic = c;
            self.readCharacteristic = c;
//            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
//            [self.myPeripheral readValueForCharacteristic:c];
            
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            [self.myPeripheral readValueForCharacteristic:c];
            NSLog(@"找到WRITE : %@", c);
            NSLog(@"找到READ : %@", c);
            [_peripheralState setText:@"connected"];
            [_peripheralState setTextColor:[UIColor greenColor]];
        }
//        else if([c.UUID isEqual:[CBUUID UUIDWithString:@"0000ffe2-0000-1000-8000-00805f9b34fb"]]){
//            self.readCharacteristic = c;
////            CBDescriptor* description = [self.myPeripheral description];
////            [description setValue:<#(id)#> forKey:<#(NSString *)#>];
//            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
//            [self.myPeripheral readValueForCharacteristic:c];
//            NSLog(@"找到READ : %@", c);
//            [_peripheralState setText:@"connected"];
//            [_peripheralState setTextColor:[UIColor greenColor]];
//        }
    }
}

//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readRSSI];
    NSNumber* rssi = [peripheral RSSI];
    NSString* rs=[NSString stringWithFormat:@"%@",rssi];
    NSLog(@"cwz0%@",rs);
    [_peripheralRssi setText:[NSString stringWithFormat:@"%@", rssi]];
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0000ffe1-0000-1000-8000-00805f9b34fb"]]){
        if(clearflag>1)
        {
        NSData* data = characteristic.value;  //接收20字节数据
//        Byte * resultByte = (Byte *)[data bytes];
//        
//        for(int i=0;i<[data length];i++)
//            printf("testByteFF02[%d] = %d\n",i,resultByte[i]);
        NSString* value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];//接收到的数据转成字符串
        //NSString* value = [self hexadecimalString:data];
//        UILocalNotification *noti = [[UILocalNotification alloc] init];
//        

        NSLog(@"characteristic : %@, data : %@, value : %@", characteristic, data, value);
//        [self.valueTextField setText:value];
            [self.values appendString:[NSString stringWithFormat:@"%@\n",value]];//在手机打印出来
//        NSLog(@"\n%@\n vlaue: %@",self.values, value);
        [_valueTextView setText:_values];
        NSRange range;
        range.location = _valueTextView.text.length;
        range.length = 0;
        [_valueTextView scrollRangeToVisible:range];
        [_valueTextView setScrollEnabled:NO];
        [_valueTextView setScrollEnabled:YES];
        }
        clearflag++;//屏蔽乱码，因为手机刚连上蓝牙会连续接收到两个乱码，具体原因不清楚
    }
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    //Notification has started
    if(characteristic.isNotifying){
        [peripheral readValueForCharacteristic:characteristic];
    }else{
        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
        [self.myCentralManager cancelPeripheralConnection:self.myPeripheral];
    }
}

//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)data{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    NSLog(@"data数据是:%@",data);
    //NSData* value = [self dataWithHexstring:data];
    NSData* value=[data dataUsingEncoding:NSUTF8StringEncoding];
    int numdig=value.length/A;//计算分包个数
    int flag=value.length%A;//判断最后一个包是否满包
    int valuelong=value.length;
    if(flag==0)
    {
        fullflag=0;//全是满包
    }else{
        fullflag=1;
    }
    Byte* minvalue[20];
    Byte* bytevalue=(Byte*)[value bytes];
    for (int i=0; i<=numdig; i++) {
        if(valuelong<=20)
        {
            NSLog(@"%d",valuelong);
            for(int j=0;j<valuelong;j++)
            {
                NSLog(@"\n第：%d次zz    字节组数据：%d",j,bytevalue[j]);
                minvalue[j]=bytevalue[j];   //字节组赋值给字节组有问题待解决
            
                NSLog(@"\n第：%d次qq    字节组数据：%d",j,minvalue[j]);
            }
            NSLog(@"bytevalue:%d",bytevalue);
            NSLog(@"minvalue:%d",minvalue);
            NSData *adata = [[NSData alloc] initWithBytes:minvalue length:value.length];
            NSLog(@"写入的数据:%@",adata);
            [_myPeripheral writeValue:adata forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else if(valuelong>20)
        {
            if(fullflag==0)
            {
                //满包处理。 逻辑与安卓一样
            }
            else if(fullflag==1)
            {
                //非满包处理。 逻辑与安卓的一样
            }
        }                                      //！！！！未写完是因为后期要加入的协议未给。   后期包里加入标志位 该函数 需要重新写。-----------------
    }
}
//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}



//连接设备[connect]
- (IBAction)connDevice:(id)sender{
  //  [self.myCentralManager stopScan];
    if(_myPeripherals != nil){
        _myPeripherals = nil;
        _myPeripherals = [NSMutableArray array];
        [_tableView reloadData];
    }
    _tableView.hidden = NO;
    self.scanClick;
    
}

//tableview的方法,返回section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//tableview的方法,返回rows(行数)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myPeripherals.count;
}
//tableview的方法,返回cell的view
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //为表格定义一个静态字符串作为标识符
    static NSString* cellId = @"cellId";
    //从IndexPath中取当前行的行号
    NSUInteger rowNo = indexPath.row;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    UILabel* labelName = (UILabel*)[cell viewWithTag:0];
    labelName.text = [[_myPeripherals objectAtIndex:rowNo] name];
    
  //  UILabel* labelRSSI = (UILabel*)[cell viewWithTag:2];
    /*[self.myPeripheral readRSSI];
    NSNumber* rssi = [self.myPeripheral RSSI];
    rssi=[NSNumber numberWithInteger:rssi];
    NSString *rs = [NSString stringWithFormat:@"%d",rssi];    NSLog(@"cwz1 %@",flagrssi);
    NSString*rs = [NSString stringWithFormat:@"%@",flagrssi];
    NSString* rss=[NSString stringWithFormat:@"%@      [%@]",[[_myPeripherals objectAtIndex:rowNo] name],rs];
    labelName.text = rss;
    NSLog(@"%@",rss);*/


    
//    UILabel* labelUUID = (UILabel*)[cell viewWithTag:2];
//    NSString* uuid = [NSString stringWithFormat:@"%@", [[_myPeripherals objectAtIndex:rowNo] identifier]];
//    uuid = [uuid substringFromIndex:[uuid length] - 13];
//    NSLog(@"%@", uuid);
//    labelUUID.text = uuid;

    return cell;
}

//tableview的方法,点击行时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
//    NSLog(@"%lu", (unsigned long)rowNo);
    _tableView.hidden = YES;
    _myPeripheral = [_myPeripherals objectAtIndex:rowNo];
    [self connectClick];
}


//隐藏键盘
- (IBAction)hideKeyboard:(id)sender{
    [self hideKeyboard];
}

- (void)hideKeyboard{
    [_writeText5 resignFirstResponder];
}

- (IBAction)clearTextView:(id)sender {
    _values = nil;
    _values = [NSMutableString stringWithString:@""];
    [_valueTextView setText:_values];
}


- (IBAction)writeBn5:(id)sender {
    NSString* value = [_writeText5 text];
    if(!value || [value isEqualToString:@""]){
        return;
    }
    
    [self writeToPeripheral:value];
    [self hideKeyboard];
    NSLog(@"write to peripheral value : %@", value);
    [self.writeText5 setText:@""];//~~~~~~~~~~~~~~~~~
}
- (IBAction)stopconnect:(id)sender{
    if(connectflag==1)
    {
        [self.myCentralManager stopScan];
        if(_myPeripherals != nil){
            _myPeripherals = nil;
            _myPeripherals = [NSMutableArray array];
            [_tableView reloadData];
        }
        _tableView.hidden = NO;
        [ self stop];
        connectflag=0;
    }else{
        [self.myCentralManager stopScan];
        NSLog(@"停止扫描");
    }
}
@end
