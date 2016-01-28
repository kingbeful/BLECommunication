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
//@property (strong,nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) NSMutableArray *devices;
@end

@implementation CentralModeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.devices = [NSMutableArray array];
    [[BLEUtil sharedInstance] startCentralManagerWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    [_devices sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        CBPeripheral *peripheral1 = obj1;
//        CBPeripheral *peripheral2 = obj2;
//        
//        NSNumber *rssi1 = nil;
//        NSNumber *rssi2 = nil;
//        
//        if (peripheral1) {
//            if (peripheral1.identifier) {
//                rssi1 = [_rssis objectForKey:[NSString stringWithFormat:@"%@", CFUUIDCreateString(nil, (CFUUIDRef)peripheral1.identifier)]];
//            }
//        }
//        
//        if (peripheral2) {
//            if (peripheral2.identifier) {
//                rssi2 = [_rssis objectForKey:[NSString stringWithFormat:@"%@", CFUUIDCreateString(nil, (CFUUIDRef)peripheral2.identifier)]];
//            }
//        }
//        
//        if (rssi1 && rssi2) {
//            
//            if (rssi1.doubleValue>rssi2.doubleValue) {
//                return NSOrderedAscending;
//            }
//        }
//        
//        return NSOrderedDescending;
//        
//    }];
    return _devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Called Cell build");
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.textLabel.text = @"sdfdsf";
        
//        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 32)];
//        nameLabel.tag = 0x1001;
//        nameLabel.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:nameLabel];
//        
//        UILabel *rssiLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 90, 32)];
//        rssiLabel.tag = 0x1002;
//        rssiLabel.backgroundColor = [UIColor clearColor];
//        
//        rssiLabel.textAlignment = NSTextAlignmentRight;
//        
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            rssiLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
//            rssiLabel.frame = CGRectMake(180, 0, 90, 44);
//        }
//        
//        [cell.contentView addSubview:rssiLabel];
//        
//        UILabel *uuidLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 26, 300, 16)];
//        uuidLabel.tag = 0x1003;
//        uuidLabel.font = [UIFont systemFontOfSize:10];
//        uuidLabel.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:uuidLabel];
    }
    
    
    
    
//    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0x1001];
//    UILabel *rssiLabel = (id)[cell.contentView viewWithTag:0x1002];
//    UILabel *uuidLabel = (id)[cell.contentView viewWithTag:0x1003];
//    
//    CBPeripheral *peripheral = [_devices objectAtIndex:indexPath.row];
//    
//    if (![peripheral.name isEqualToString:@"Microwave Sensor"]) {
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    else
//    {
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    
//    NSNumber *rssi = nil;
//    
//    if (peripheral.identifier) {
//        rssi = [_rssis objectForKey:[NSString stringWithFormat:@"%@", CFUUIDCreateString(nil, (CFUUIDRef)peripheral.identifier)]];
//    }
//    
//    nameLabel.text = [NSString stringWithFormat:@"%@", peripheral.name];
//    
//    rssiLabel.text = @"";
//    uuidLabel.text = @"";
//    
//    if (rssi) {
//        rssiLabel.text = [NSString stringWithFormat:@"%@dBm", rssi];
//    }
//    
//    if (peripheral.identifier) {
//        uuidLabel.text =  [NSString stringWithFormat:@"%@", CFUUIDCreateString(nil, (CFUUIDRef)peripheral.identifier)];
//    }
//    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    BLEDevice *device = [[BLEDevice alloc] init];
//    device.p = [_devices objectAtIndex:indexPath.row];
//    device.manager = _manager;
//    
//    if ([device.p.name isEqualToString:@"Microwave Sensor"])
//    {
//        [self performSegueWithIdentifier:@"DeviceAction" sender:device];
//    }
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
