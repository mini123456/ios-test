//
//  WWDViewController.h
//  MyBleTest2
//
//  Created by maginawin on 14-8-11.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface WWDViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CBCentralManager* myCentralManager;
@property (strong, nonatomic) NSMutableArray* myPeripherals;
@property (strong, nonatomic) CBPeripheral* myPeripheral;
@property (strong, nonatomic) NSMutableArray* nServices;
@property (strong, nonatomic) NSMutableArray* nDevices;
@property (strong, nonatomic) NSMutableArray* nCharacteristics;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic* readCharacteristic;
@property (weak, nonatomic  ) IBOutlet UITableView    *bluetoothTable;

@property (strong, nonatomic) IBOutlet UITextView *valueTextView;

@property (strong, nonatomic) IBOutlet UITextField *writeText5;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *peripheralState;
@property (strong, nonatomic) IBOutlet UILabel *peripheralRssi;
@property (strong, nonatomic) IBOutlet UILabel *attention;

- (void)scanClick;
- (void)connectClick;
- (void)hideKeyboard;
- (void)stop;

- (IBAction)stopconnect:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)clearTextView:(id)sender;
- (IBAction)connDevice:(id)sender;



- (IBAction)writeBn5:(id)sender;


@end
