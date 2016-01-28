//
//  BLEUtil.h
//  BTLE Transfer
//
//  Created by Kevin on 16/1/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BLEUtilErrorCode) {
    E_NO_BLE_FEATURE = 0,
    E_BT_POWER_OFF,
    E_RSSI_ERROR,
    E_RSSI_TOO_LOW,
    E_CONNECT_PERIPHERAL_FAILED,
    E_DISCOVER_SERVICE,
    E_DISCOVER_CHAR_FOR_SERVICE,
    E_UPDATE_VALUE_FOR_CHAR,
};

typedef NS_ENUM(NSInteger, BLEUtilEvent) {
    EV_BT_POWER_ON = 0,
    EV_DISCONNECT_PERIPHERAL,
    EV_CONNECT_PERIPHERAL,
    EV_DISCOVER_SERVICE,
    EV_DISCOVER_CHAR_FOR_SERVICE,
    EV_UPDATE_CHAR_VALUE
};

@protocol BLEUtilDelegate;
@interface BLEUtil : NSObject

@property(assign, nonatomic) id<BLEUtilDelegate> delegate;
+ (id) sharedInstance;
- (void) startCentralManagerWithDelegate:(id<BLEUtilDelegate>)delegate;
- (void) scanPeripheralWithServicesUUID:(NSString*) uuid;
@end

@protocol BLEUtilDelegate <NSObject>

- (bool)BLEUtilError:(BLEUtilErrorCode) code withMessage:(NSString*) msg;
- (bool)BLEUtilPeripheralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg;
- (bool)BLEUtilCentralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg;

@end
