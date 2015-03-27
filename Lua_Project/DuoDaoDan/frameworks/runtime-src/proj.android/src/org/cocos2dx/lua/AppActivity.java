/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.ViewGroup.LayoutParams;
import android.widget.RelativeLayout;

import android.provider.Settings;
import android.text.format.Formatter;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;
import com.anysdk.framework.PluginWrapper;

import cn.domob.android.ads.AdView;
import cn.domob.android.ads.AdEventListener;
import cn.domob.android.ads.AdManager.ErrorCode;

public class AppActivity extends Cocos2dxActivity{

	static String hostIPAdress = "0.0.0.0";

	public static final String PUBLISHER_ID = "56OJzdfIuN4jdU8Ppg";
	public static final String InterstitialPPID = "16TLmqUoApzU4NUOxaAQZVks";
	
	private static Handler handler;
	private static RelativeLayout bannerLayout;
	private static AdView adView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		

		bannerLayout = new RelativeLayout(this);
		RelativeLayout.LayoutParams parentLayputParams = new RelativeLayout.LayoutParams(
				(RelativeLayout.LayoutParams.MATCH_PARENT),
				RelativeLayout.LayoutParams.MATCH_PARENT);
		this.addContentView(bannerLayout, parentLayputParams);
		adView = new AdView(AppActivity.this,PUBLISHER_ID,InterstitialPPID);
		handler = new Handler(){
			
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 0:
					//设置显示
					adView.setVisibility(0);
					if (bannerLayout.getChildCount() == 0) {
						Log.i("tag", "llllllllllll");
						
						adView.setAdSize(adView.INLINE_SIZE_320X50);
						adView.setAdEventListener(new AdEventListener() {
							@Override
							public void onAdOverlayPresented(AdView adView) {
								Log.i("DomobSDKDemo", "overlayPresented");
							}
							@Override
							public void onAdOverlayDismissed(AdView adView) {
								Log.i("DomobSDKDemo", "Overrided be dismissed");
							}
							@Override
							public void onAdClicked(AdView arg0) {
								Log.i("DomobSDKDemo", "onDomobAdClicked");
							}
							@Override
							public void onLeaveApplication(AdView arg0) {
								Log.i("DomobSDKDemo", "onDomobLeaveApplication");
							}
							@Override
							public Context onAdRequiresCurrentContext() {
								return AppActivity.this;
							}
							@Override
							public void onAdFailed(AdView arg0, ErrorCode arg1) {
								Log.i("DomobSDKDemo", "onDomobAdFailed");
							}
							@Override
							public void onEventAdReturned(AdView arg0) {
								Log.i("DomobSDKDemo", "onDomobAdReturned");
							}
						});
						//显示广告

						RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams((LayoutParams.WRAP_CONTENT),
								LayoutParams.WRAP_CONTENT);
						
						//水平居中
						layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
						//在父中的位置
						layoutParams.addRule(
                                RelativeLayout.ALIGN_PARENT_BOTTOM,RelativeLayout.TRUE); 	
						bannerLayout.addView(adView, layoutParams);
						Log.i("tag", "qqqqqqqqqqqqqqqqqqq");
					}
					break;
				case 1:		
					//设置隐藏
					adView.setVisibility(4);

				break;
				
				}
			}
		};

		if(nativeIsLandScape()) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
		} else {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
		}
		
		//2.Set the format of window
		
		// Check the wifi is opened when the native is debug.
		if(nativeIsDebug())
		{
			getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
			if(!isNetworkConnected())
			{
				AlertDialog.Builder builder=new AlertDialog.Builder(this);
				builder.setTitle("Warning");
				builder.setMessage("Please open WIFI for debuging...");
				builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
						finish();
						System.exit(0);
					}
				});

				builder.setNegativeButton("Cancel", null);
				builder.setCancelable(true);
				builder.show();
			}
		}
		hostIPAdress = getHostIpAddress();

        //for anysdk
        PluginWrapper.init(this); // for plugins
	}
	private boolean isNetworkConnected() {
	        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
	        if (cm != null) {  
	            NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
			ArrayList networkTypes = new ArrayList();
			networkTypes.add(ConnectivityManager.TYPE_WIFI);
			try {
				networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
			} catch (NoSuchFieldException nsfe) {
			}
			catch (IllegalAccessException iae) {
				throw new RuntimeException(iae);
			}
			if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
	                return true;  
	            }  
	        }  
	        return false;  
	    } 
	 
	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}
	
	public static String getLocalIpAddress() {
		return hostIPAdress;
	}

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        super.onActivityResult(requestCode, resultCode, data);
        PluginWrapper.onActivityResult(requestCode, resultCode, data);
    }
    @Override
    protected void onResume() {
        super.onResume();
        PluginWrapper.onResume();
    }
    @Override
    public void onPause(){
        PluginWrapper.onPause();
        super.onPause();
    }
    @Override
    protected void onNewIntent(Intent intent) {
        PluginWrapper.onNewIntent(intent);
        super.onNewIntent(intent);
    }

	private static native boolean nativeIsLandScape();
	private static native boolean nativeIsDebug();
	
	public Cocos2dxGLSurfaceView onCreateView() {
    	Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
    	// HelloWorld should create stencil buffer
    	glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
    	
    	return glSurfaceView;
    }
	public static void showBannerStatic() {
		Log.w("", "xdfxfxfxxfxfdxf");
		Message msg = handler.obtainMessage();	
		msg.what = 0;
		handler.sendMessage(msg);	
	}
	
	public static void closeBannerStatic() {
		Log.w("", "cccccccccccccccccccc");
		Message msg = handler.obtainMessage();	
		msg.what = 1;
		handler.sendMessage(msg);
		
	}
	
	
	static {
        System.loadLibrary("cocos2dlua");
    }
}
