//
//  ViewController.m
//  BLEPeripheral
//
//  Created by Kevin on 16/1/26.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "ViewController.h"


#define SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define CHARACTERISTIC_NOTIFY_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define CHARACTERISTIC_WRITE_UUID @"632FB3C9-2078-419B-83AA-DBC64B5B685A"
#define CHARACTERISTIC_READ_UUID @"C22D1ECA-0F78-463B-8C21-688A517D7D2B"

@implementation ViewController


#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)viewWillDisappear
{
    // Don't keep it going while we're not showing.
    [self.peripheralManager stopAdvertising];
    
    [super viewWillDisappear];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - Peripheral Methods



/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"CBPeripheralManagerStatePoweredOn");
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CBPeripheralManagerStatePoweredOff");
            break;
            
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CBPeripheralManagerStateUnsupported");
            break;
            
        default:
            break;
    }
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // Start with the CBMutableCharacteristic
    self.charNotify =
    [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]
                                       properties:CBCharacteristicPropertyNotify
                                            value:nil
                                      permissions:CBAttributePermissionsReadable];
    
    self.charWrite =
    [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]
                                       properties:CBCharacteristicPropertyWrite
                                            value:nil
                                      permissions:CBAttributePermissionsWriteable];
    self.charRead =
    [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_READ_UUID]
                                       properties:CBCharacteristicPropertyRead
                                            value:nil
                                      permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    service.characteristics = @[self.charNotify, self.charWrite, self.charRead];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    } else {
        NSLog(@"Add Service OK");
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    } else {
        NSLog(@"Start Advertising OK");
    }
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    // Send it
    BOOL ret = [self.peripheralManager updateValue:[@"Hello BLE" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.charNotify onSubscribedCentrals:nil];
    NSLog(@"Send subscribed %hhd", ret);
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"didReceiveReadRequest");
    if ([request.characteristic.UUID isEqual:self.charRead.UUID])
    {
        NSLog(@"Request character Read");
        
        if (request.offset > self.charRead.value.length)
        {
            NSLog(@"--> Read CBATTErrorInvalidOffset");
            [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        request.value = [self.charRead.value subdataWithRange:(NSRange){request.offset, self.charRead.value.length - request.offset}];
        
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        NSLog(@"--> Read CBATTErrorSuccess");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];
    
    self.charWrite.value = request.value;
    
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    NSLog(@"--> Write CBATTErrorSuccess");
}


#pragma mark - Switch Methods

- (IBAction)onSwitch:(id)sender {

    if (self.AdvSwitch.state == NSOnState) {
         NSLog(@"Start Advertising");
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]] }];
    } else {
         NSLog(@"Stop Advertising");
        [self.peripheralManager stopAdvertising];
    }
}

@end
