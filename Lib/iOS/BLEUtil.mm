//
//  BLEUtil.m
//  BTLE Transfer
//
//  Created by Kevin on 16/1/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "BLEUtil.h"
#import <CoreBluetooth/CoreBluetooth.h>

static BLEUtil *INSTANCE = 0;
static int CENTRAL = 0;
static int PERIPHERAL = 1;

@interface BLEUtil () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBUUID                *serviceUUID;

@end


@implementation BLEUtil

#pragma mark - Private Methods

- (bool) runCallbackWithErrorCode:(BLEUtilErrorCode) code {
    return [self runCallbackWithErrorCode:code withMessage:nil];
}

- (bool) runCallbackWithErrorCode:(BLEUtilErrorCode) code withMessage:(NSString*) msg {
    return [self.delegate BLEUtilError:code withMessage:msg];
}

- (bool) runCallback:(int) mode andEvent:(BLEUtilEvent)event {
    return [self runCallback:mode andEvent:event withMessage:nil];
}

- (bool) runCallback:(int) mode andEvent:(BLEUtilEvent)event withMessage:(NSString*) msg {
    if (mode == CENTRAL) {
        return [self.delegate BLEUtilCentralEvent:event withMessage:msg];
    } else {
        return [self.delegate BLEUtilPeripheralEvent:event withMessage:msg];
    }
}

#pragma mark - Public Methods

+ (id) sharedInstance
{
    if (!INSTANCE) {
        INSTANCE = [[BLEUtil alloc] init];
    }
    return INSTANCE;
}

- (void) startCentralManagerWithDelegate:(id<BLEUtilDelegate>)delegate {
    self.delegate = delegate;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
// Scan for the a given uuid of service. If matched a peripheral, central will connect
// to the peripheral automatically. Additionally, after connect with peripheral, central
// will discover the services automatically
- (void) scanPeripheralWithServicesUUID:(NSString*) uuid {
    self.serviceUUID = [CBUUID UUIDWithString:uuid];
    [self.centralManager scanForPeripheralsWithServices:@[self.serviceUUID] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

#pragma mark - Central Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            [self runCallback:CENTRAL andEvent:EV_BT_POWER_ON];
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            [self runCallbackWithErrorCode:E_BT_POWER_OFF];
            break;
            
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            [self runCallbackWithErrorCode:E_NO_BLE_FEATURE];
            break;
            
        default:
            break;
    }
}
/** This callback comes whenever a peripheral that is advertising is discovered.
 *  Check the RSSI, to make sure it's close enough that we're interested in it,
 *  If so, start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
//    if (RSSI.integerValue > -15) {
//        [self runCallbackWithErrorCode:E_RSSI_ERROR];
//        return;
//    }
//    
//    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//    if (RSSI.integerValue < -35) {
//        [self runCallbackWithErrorCode:E_RSSI_TOO_LOW];
//        return;
//    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        // And this action will prevent the central to connnect the peripheral twice.
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self runCallbackWithErrorCode:E_CONNECT_PERIPHERAL_FAILED];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    [self runCallback:CENTRAL andEvent:EV_CONNECT_PERIPHERAL];
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[self.serviceUUID]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnect to %@.", peripheral);
    self.discoveredPeripheral = nil;
    self.serviceUUID = nil;
    [self runCallback:CENTRAL andEvent:EV_DISCONNECT_PERIPHERAL];
}

#pragma mark - Peripheral Methods

/** Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self runCallbackWithErrorCode:E_DISCOVER_SERVICE withMessage:[error localizedDescription]];
        return;
    }
    
    // Discover the characteristic we want...
    NSLog(@"didDiscoverServices");
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        // Check the uuid of the service. Will discover the characteristics if matched our uuid.
        if ([self runCallback:PERIPHERAL andEvent:EV_DISCOVER_SERVICE withMessage:service.UUID.UUIDString]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}


/** characteristic was discovered.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self runCallbackWithErrorCode:E_DISCOVER_CHAR_FOR_SERVICE withMessage:[error localizedDescription]];
        
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        // If it is the characteristic we want, subscribe to it
        if ([self runCallback:PERIPHERAL andEvent:EV_DISCOVER_CHAR_FOR_SERVICE withMessage:characteristic.UUID.UUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self runCallbackWithErrorCode:E_UPDATE_VALUE_FOR_CHAR withMessage:[error localizedDescription]];
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
    [self runCallback:PERIPHERAL andEvent:EV_UPDATE_CHAR_VALUE withMessage:stringFromData];
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

@end
