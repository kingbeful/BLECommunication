package com.icewind.bleutil;

import com.icewind.bleutil.BLEUtil.BLEUtilCallback;
import com.icewind.bleutil.BLEUtil.BLEUtilErrorCode;
import com.icewind.bleutil.BLEUtil.BLEUtilEvent;

import android.os.Build;
import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;

public class MainActivity extends Activity {

	private final static String TAG = MainActivity.class.getSimpleName();
	private final static String ServiceUUID                = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961";
	private final static String CHARACTERISTIC_NOTIFY_UUID = "08590F7E-DB05-467E-8757-72F6FAEB13D4";
	private final static String CHARACTERISTIC_WRITE_UUID  = "632FB3C9-2078-419B-83AA-DBC64B5B685A";
	private final static String CHARACTERISTIC_READ_UUID   = "C22D1ECA-0F78-463B-8C21-688A517D7D2B";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		BLEUtil.getInstance(this).startCentralManager(new BLEUtilCallback(){

			@Override
			public boolean BLEUtilErrorwithMessage(BLEUtilErrorCode code,
					String msg) {
				// TODO Auto-generated method stub
				return true;
			}

			@Override
			public boolean BLEUtilCentralEventwithMessage(BLEUtilEvent event,
					String msg) {
				// TODO Auto-generated method stub
				if (event == BLEUtilEvent.EV_BT_POWER_ON) {
					Log.i(TAG, "Power On");
					if (Build.VERSION.SDK_INT >= 21) {
						BLEUtil.getInstance(MainActivity.this).scanPeripheralWithServicesUUID_API21(ServiceUUID);
					} else if (Build.VERSION.SDK_INT >= 18) {
						BLEUtil.getInstance(MainActivity.this).scanPeripheralWithServicesUUID_API18(ServiceUUID);
					}
				}
				return true;
			}

			@Override
			public boolean BLEUtilPeripheralEventwithMessage(BLEUtilEvent event,
					String msg) {
				// TODO Auto-generated method stub
				if (event == BLEUtilEvent.EV_DISCOVER_SERVICE) {
					Log.i(TAG, "DISCOVERED SERVICE: " + msg);
					return msg.equalsIgnoreCase(ServiceUUID);
				} else if (event == BLEUtilEvent.EV_DISCOVER_CHAR_FOR_SERVICE) {
					Log.i(TAG, "DISCOVERED CHARACT: " + msg);
					return msg.equalsIgnoreCase(CHARACTERISTIC_NOTIFY_UUID);
				} else if (event == BLEUtilEvent.EV_UPDATE_CHAR_VALUE) {
					Log.i(TAG, "Charact Value: " + msg);
				}
				return true;
			}
			
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
