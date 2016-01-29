# BLECommunication
Android communicate with iOS using BLE (Bluetooth Low Energy)

BLE has two modes
__Central__ and __Peripheral__

Android has supportted Central mode since android 4.3 (API 18). The Peripheral mode starts from android 5.0 with some special devices like Nexus 6 and Nexus 9. 

Check this [stackoverflow link](http://stackoverflow.com/questions/19717902/does-android-kitkat-allows-devices-that-support-bluetooth-le-to-act-as-a-periphe?lq=1) for detail

In this library, both iOS and Android act in a central role while OSX acts in a peripheral role.

## How to use

#### iOS

Add BLEUtil.h and BLEUtil.mm to your project. Import the header file

```Objective-C
#import "BLEUtil.h"

```

Start the Bluetooth Central Manager

```Objective-C
[[BLEUtil sharedInstance] startCentralManagerWithDelegate:self];
```

Scan the service UUID when Bluetooth is ready

```Objective-C
- (bool)BLEUtilCentralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg {
    if (event == EV_BT_POWER_ON) {
        [[BLEUtil sharedInstance] scanPeripheralWithServicesUUID:@"ADEF1234-7655-00EF-11EE-00B1AD073469"];
    }
    return YES;
}
```

Handle the callback in delegate

```Objective-C

#pragma mark - BLE Delegate
- (bool)BLEUtilError:(BLEUtilErrorCode) code withMessage:(NSString*) msg {
    return YES;
}

- (bool)BLEUtilPeripheralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg {
    return YES;
}

- (bool)BLEUtilCentralEvent:(BLEUtilEvent) event withMessage:(NSString*) msg {
  return YES;
}

```

#### Android

Add the BLEUtil.java to your project

Start the Bluetooth Central Manager with callback

```java
BLEUtil.getInstance(this).startCentralManager(new BLEUtilCallback(){
	@Override
	public boolean BLEUtilErrorwithMessage(BLEUtilErrorCode code,
			String msg) {
		return true;
	}

	@Override
	public boolean BLEUtilCentralEventwithMessage(BLEUtilEvent event, String msg) {
		return true;
	}

	@Override
	public boolean BLEUtilPeripheralEventwithMessage(BLEUtilEvent event, String msg) {
		return true;
	}
	
});
```

Scan the service UUID when Bluetooth is ready

```java
public boolean BLEUtilCentralEventwithMessage(BLEUtilEvent event, String msg) {
	if (event == BLEUtilEvent.EV_BT_POWER_ON) {
		if (Build.VERSION.SDK_INT >= 21) {
			BLEUtil.getInstance(MainActivity.this).scanPeripheralWithServicesUUID_API21("ADEF1234-7655-00EF-11EE-00B1AD073469");
		} else if (Build.VERSION.SDK_INT >= 18) {
			BLEUtil.getInstance(MainActivity.this).scanPeripheralWithServicesUUID_API18("ADEF1234-7655-00EF-11EE-00B1AD073469");
		}
	}
	return true;
}
```

__Notice__

> There are two methods to scan the service depends on the api level.


Handle the callback

```java
@Override
public boolean BLEUtilErrorwithMessage(BLEUtilErrorCode code, String msg) {
  // handle error message
	return true;
}

@Override
public boolean BLEUtilCentralEventwithMessage(BLEUtilEvent event, String msg) {
  // handle the Central event
	return true;
}

@Override
public boolean BLEUtilPeripheralEventwithMessage(BLEUtilEvent event, String msg) {
  // handle the Peripheral event
	return true;
}
```
