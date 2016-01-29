package com.icewind.bleutil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import android.annotation.TargetApi;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.ParcelUuid;
import android.util.Log;

@TargetApi(18)
public class BLEUtil {
	
	private final static String TAG = BLEUtil.class.getSimpleName();
	private final static int CENTRAL = 0;
	private final static int PERIPHERAL = 1;
	
	public enum BLEUtilErrorCode {
		E_NO_BLE_FEATURE, 
		E_BT_POWER_OFF, 
		E_RSSI_ERROR, 
		E_RSSI_TOO_LOW,
		E_CONNECT_PERIPHERAL_FAILED,
		E_DISCOVER_SERVICE,
	    E_DISCOVER_CHAR_FOR_SERVICE,
	    E_UPDATE_VALUE_FOR_CHAR
	}
	
	public enum BLEUtilEvent {
	    EV_BT_POWER_ON,
	    EV_DISCONNECT_PERIPHERAL,
	    EV_CONNECT_PERIPHERAL,
	    EV_DISCOVER_SERVICE,
	    EV_DISCOVER_CHAR_FOR_SERVICE,
	    EV_UPDATE_CHAR_VALUE
	}

    private static BLEUtil INSTANCE = null;
    private Context mContext;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothGatt mGatt = null;
    private BLEUtilCallback mCallback;
            
    private BLEUtil( Context context ) {
    	mContext = context;
    }
    
    public static BLEUtil getInstance(Context context) {
    	if (INSTANCE == null) {
    		INSTANCE = new BLEUtil(context);
    	}
    	return INSTANCE;
    }
    
    private boolean runCallbackWithErrorCode(BLEUtilErrorCode code) {
    	return runCallbackWithErrorCode(code, null);
    }
    
    private boolean runCallbackWithErrorCode(BLEUtilErrorCode code, String msg) {
    	return mCallback.BLEUtilErrorwithMessage(code, msg);
    }
    private boolean runCallback(int mode, BLEUtilEvent event) {
    	return runCallback(mode, event, null);
    }
    private boolean runCallback(int mode, BLEUtilEvent event, String msg) {
    	if (mode == CENTRAL) {
    		return mCallback.BLEUtilCentralEventwithMessage(event, msg);
    	} else {
    		return mCallback.BLEUtilPeripheralEventwithMessage(event, msg);
    	}
    }
    
    private void requestOpenBT() {
    	Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    	runCallbackWithErrorCode(BLEUtilErrorCode.E_BT_POWER_OFF);
	    mContext.startActivity(enableBtIntent);
    }
    
    private void connectToDevice(BluetoothDevice device) {
	    if (mGatt == null) {
	    	mGatt = device.connectGatt(mContext, false, new BluetoothGattCallback() {
	    	    @Override
	    	    public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
	    	        switch (newState) {
	    	            case BluetoothProfile.STATE_CONNECTED:
	    	            	runCallback(CENTRAL, BLEUtilEvent.EV_CONNECT_PERIPHERAL);
	    	                Log.i(TAG, "Connected to GATT server.");
	    	                Log.i(TAG, "Attempting to start service discovery:" + gatt.discoverServices());
	    	                break;
	    	            case BluetoothProfile.STATE_DISCONNECTED:
	    	            	runCallback(CENTRAL, BLEUtilEvent.EV_CONNECT_PERIPHERAL);
	    	            	mGatt = null;
	    	            	runCallback(CENTRAL, BLEUtilEvent.EV_DISCONNECT_PERIPHERAL);
	    	                Log.i(TAG, "Disconnected from GATT server.");
	    	                break;
	    	            default:
	    	            	runCallbackWithErrorCode(BLEUtilErrorCode.E_CONNECT_PERIPHERAL_FAILED);
	    	            	break;
	    	        }
	    	    }
	    	    @Override
	            // New services discovered
	            public void onServicesDiscovered(BluetoothGatt gatt, int status) {
	    	    	Log.i(TAG, "=== onServicesDiscovered: " + status);
	                if (status == BluetoothGatt.GATT_SUCCESS) {
	                	List<BluetoothGattService> Services = gatt.getServices();
	                	for (BluetoothGattService gattService : Services) {
	                		if (runCallback(PERIPHERAL, BLEUtilEvent.EV_DISCOVER_SERVICE, gattService.getUuid().toString())) {
	                			List<BluetoothGattCharacteristic> gattCharacteristics = gattService.getCharacteristics();
	                			for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
		                			if (runCallback(PERIPHERAL, BLEUtilEvent.EV_DISCOVER_CHAR_FOR_SERVICE, gattCharacteristic.getUuid().toString())) {
		                				List<BluetoothGattDescriptor> gattDescriptors = gattCharacteristic.getDescriptors();
		                                for (BluetoothGattDescriptor gattDescriptor : gattDescriptors) {
		                                    gatt.readDescriptor(gattDescriptor);
		                                }
		                			}
	                			}
	                		}
	                	}
	                } else {
	                    Log.w(TAG, "onServicesDiscovered received: " + status);
	                }
	            }
	    	    
	    	    @Override
	    	    public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
	    	    	Log.i(TAG, "=== onCharacteristicRead: " + status);
	    	    	if (status == BluetoothGatt.GATT_SUCCESS) {

	                }
	    	    }
	    	    
	    	    @Override
	    	    public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
	    	    	Log.i(TAG, "=== onCharacteristicWrite: " + status);
	    	    	if (status == BluetoothGatt.GATT_SUCCESS) {

	                }
	    	    }
	    	    @Override
	    	    public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
	    	    	Log.i(TAG, "===>");
	    	    	final String data = characteristic.getStringValue(0);
	    	    	runCallback(PERIPHERAL, BLEUtilEvent.EV_UPDATE_CHAR_VALUE, data);
	    	    }
	    	    @Override
	    	    public void onDescriptorRead(BluetoothGatt gatt, BluetoothGattDescriptor gattDescripter, int status) {
	    	    	Log.i(TAG, "=== onDescriptorRead: " + status);
	    	    	if (status == BluetoothGatt.GATT_SUCCESS) {
	    	    		BluetoothGattCharacteristic gattCharacteristic = gattDescripter.getCharacteristic();
	    	    		int properties = gattCharacteristic.getProperties();
	                    if ( (properties & BluetoothGattCharacteristic.PROPERTY_NOTIFY) == BluetoothGattCharacteristic.PROPERTY_NOTIFY ||
	                    	 (properties & BluetoothGattCharacteristic.PROPERTY_INDICATE) == BluetoothGattCharacteristic.PROPERTY_INDICATE ) {
	                    	Log.i(TAG, "Set Characteristic Notification");
	                    	boolean ret = mGatt.setCharacteristicNotification(gattCharacteristic, true);
	                    	if (ret) {
	                    		if ((properties & BluetoothGattCharacteristic.PROPERTY_NOTIFY) == BluetoothGattCharacteristic.PROPERTY_NOTIFY) {
	                    			Log.i(TAG, "Set ENABLE_NOTIFICATION_VALUE");
	                    			gattDescripter.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
	                    		} else {
	                    			Log.i(TAG, "Set ENABLE_INDICATION_VALUE");
	                    			gattDescripter.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);
	                    		}
	        	    			gatt.writeDescriptor(gattDescripter);
	        	    		}
	                    }
	                }
	    	    }
	    	    @Override
	    	    public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor gattDescripter, int status) {
	    	    	Log.i(TAG, "=== onDescriptorWrite: " + status);
	    	    	if (status == BluetoothGatt.GATT_SUCCESS) {
	                }
	    	    }
	    	});
	    }
	}
    
    public void startCentralManager(BLEUtilCallback callback) {
    	this.mCallback = callback;
    	if (!mContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
    		runCallbackWithErrorCode(BLEUtilErrorCode.E_NO_BLE_FEATURE);
		}
    	
		// Initializes Bluetooth adapter.
		final BluetoothManager bluetoothManager =
		        (BluetoothManager) mContext.getSystemService(Context.BLUETOOTH_SERVICE);
		mBluetoothAdapter = bluetoothManager.getAdapter();
		// Ensures Bluetooth is available on the device and it is enabled. If not,
		// displays a dialog requesting user permission to enable Bluetooth.
		if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
			requestOpenBT();
		} else {
			runCallback(CENTRAL, BLEUtilEvent.EV_BT_POWER_ON);
		}
    }
    
    // Check this http://stackoverflow.com/questions/20352200/android-ble-retrieve-service-uuid-in-onlescan-callback-when-advertised-from
    private String getUUIDFromScanRecord(final byte[] scanRecord) {
    	int index = 0;
    	byte[] data = null;
        while (index < scanRecord.length) {
            int length = scanRecord[index++];
            //Done once we run out of records
            if (length == 0) break;

            int type = scanRecord[index];
            //Done if our record isn't a valid type
            if (type == 0) break;

            if (type >= 2 && type <= 7)  { 
            	// 0x02 ~ 0x07 is the uuid type, Check BLUETOOTH SPECIFICATION Version 4.0 section 18.2
                data = Arrays.copyOfRange(scanRecord, index+1, index+length);
            }
            index += length;
        }

    	if (data != null) {
    		StringBuilder hex = new StringBuilder(data.length * 2);
			for (int i = data.length - 1; i >= 0 ; i--) {
				hex.append(String.format("%02x", data[i] & 0xff));
			}
    		return hex.toString();
    	}
    	return null;
    }
    
    private boolean matchRules(int rssi, byte [] scanRecord, String uuid) {
    	String uuidAD = getUUIDFromScanRecord(scanRecord);
		Log.i(TAG, "UUID:" + uuidAD);
		if (uuidAD != null) {
			return uuidAD.equalsIgnoreCase(uuid.replaceAll("-", ""));
		} else {
			return false;
		}
    }
    
 // Scan for the a given uuid of service. If matched a peripheral, central will connect
 // to the peripheral automatically. Additionally, after connect with peripheral, central
 // will discover the services automatically
    public void scanPeripheralWithServicesUUID_API21(final String uuid) {
    	if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
    		requestOpenBT();
    		return;
    	}
    	BluetoothLeScanner scanner = mBluetoothAdapter.getBluetoothLeScanner();
    	ScanSettings settings = new ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build();
    	List<ScanFilter> list = new ArrayList<ScanFilter>(1);
    	
    	ScanCallback callback = new ScanCallback() {
			@Override
		    public void onScanResult(int callbackType,  android.bluetooth.le.ScanResult result) {
				BluetoothDevice device = result.getDevice();
				
				ScanRecord sr = result.getScanRecord();
			    
				int rssi = result.getRssi();
//				if (rssi > -15) {
//					runCallbackWithErrorCode(BLEUtilErrorCode.E_RSSI_ERROR);
//					return;
//				}
//				if (rssi < -35) {
//					runCallbackWithErrorCode(BLEUtilErrorCode.E_RSSI_TOO_LOW);
//					return;
//				}
				if (matchRules(rssi, sr.getBytes(), uuid)) {
					connectToDevice(device);
				}
		    }
		 
		    @Override
		    public void onScanFailed(int errorCode) {
		 
		    }
		};
    	
    	if (uuid != null) {
	    	ScanFilter filter = new ScanFilter.Builder().setServiceUuid(ParcelUuid.fromString(uuid)).build();
	        list.add(filter);
	        scanner.startScan(list, settings, callback);
    	} else {
//    		scanner.startScan(null, settings, callback);
    		scanner.startScan(callback);
    	}
    }

    public void scanPeripheralWithServicesUUID_API18(final String uuid) {
            mBluetoothAdapter.startLeScan(new BluetoothAdapter.LeScanCallback() {
        	    @Override
        	    public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) {
        	    	Log.i(TAG, "Name:"+device.getName());
        	    	if (matchRules(rssi, scanRecord, uuid)) {
    					connectToDevice(device);
    				}
        	    }
        	});
    }

    public interface BLEUtilCallback {
    	boolean BLEUtilErrorwithMessage(BLEUtilErrorCode code, String msg);
    	boolean BLEUtilCentralEventwithMessage(BLEUtilEvent event, String msg);
    	boolean BLEUtilPeripheralEventwithMessage(BLEUtilEvent event, String msg);
    }
}
