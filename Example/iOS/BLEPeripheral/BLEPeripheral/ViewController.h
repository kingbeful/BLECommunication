//
//  ViewController.h
//  BLEPeripheral
//
//  Created by Kevin on 16/1/26.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *AdvSwitch;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *charNotify;
@property (strong, nonatomic) CBMutableCharacteristic   *charWrite;
@property (strong, nonatomic) CBMutableCharacteristic   *charRead;

@end

