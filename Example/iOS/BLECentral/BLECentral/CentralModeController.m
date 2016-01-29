//
//  CentralModeController.m
//  BLECentral
//
//  Created by Kevin on 16/1/21.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CentralModeController.h"
#import "BLEUtil.h"


#define SERVICE_UUID                @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define CHARACTERISTIC_NOTIFY_UUID  @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define CHARACTERISTIC_WRITE_UUID   @"632FB3C9-2078-419B-83AA-DBC64B5B685A"
#define CHARACTERISTIC_READ_UUID    @"C22D1ECA-0F78-463B-8C21-688A517D7D2B"


@interface CentralModeController () <BLEUtilDelegate>
@end

@implementation CentralModeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[BLEUtil sharedInstance] startCentralManagerWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE Delegate
- (bool)BLEUtilError:(BLEUtilErrorCode) code withMessage:(NSString*) msg {
    NSLog(@"[%ld]%@", (long)code, msg);
    return YES;
}

- (bool)BLEUtilPeripheralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg {
    if (event == EV_DISCOVER_SERVICE) {
        NSLog(@"EV_DISCOVER_SERVICE : %@", msg);
        return [msg isEqualToString:SERVICE_UUID];
    } else if (event == EV_DISCOVER_CHAR_FOR_SERVICE) {
        NSLog(@"EV_DISCOVER_CHAR_FOR_SERVICE : %@", msg);
        if ([msg isEqualToString:CHARACTERISTIC_NOTIFY_UUID]) { // return YES to enable subscribe
            return YES;
        } else {
            return NO;
        }
    } else if (event == EV_UPDATE_CHAR_VALUE) {
        NSLog(@"EV_UPDATE_CHAR_VALUE : %@", msg);
    }
    return YES;
}

- (bool)BLEUtilCentralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg {
    if (event == EV_BT_POWER_ON) {
        NSLog(@"Scan for %@", SERVICE_UUID);
        [[BLEUtil sharedInstance] scanPeripheralWithServicesUUID:SERVICE_UUID];
    }
    return YES;
}

@end
