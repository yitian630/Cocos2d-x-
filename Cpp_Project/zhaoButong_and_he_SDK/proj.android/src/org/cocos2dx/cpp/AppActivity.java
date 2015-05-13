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
package org.cocos2dx.cpp;

import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.cpp.AppActivity;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;
import cn.cmgame.billing.api.BillingResult;
import cn.cmgame.billing.api.GameInterface;

public class AppActivity extends Cocos2dxActivity {
	

	static String hostIPAdress = "0.0.0.0";
	private static Handler handler;
	
	//单例
	public static AppActivity instance = null;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		//初始化
		instance = AppActivity.this;
		
	    System.out.println("----------------进入游戏------------------");
	    handler = new Handler(){
			
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 0:
					final int index = msg.arg1;
					//设置显示
					// 初始化SDK
				    GameInterface.initializeApp(AppActivity.this);
				    // 计费结果的监听处理，合作方通常需要在收到SDK返回的onResult时，告知用户的购买结果
				    final GameInterface.IPayCallback billingCallback = new GameInterface.IPayCallback() {
				    	
				      @Override
				      	public void onResult(int resultCode, String billingIndex, Object obj) {
				    	  	String result = "";
							switch (resultCode) {
				          		case BillingResult.SUCCESS:
				          			saveTimeByIndex(index);
				          			result = "购买道具：[" + billingIndex + "] 成功！";
				          			break;
				          		case BillingResult.FAILED:
				          			result = "购买道具：[" + billingIndex + "] 失败！";
				          			break;
				          		default:
				          			saveTimeByIndex(index);
				          			System.out.println("++++++保存时间+++++++");
				          			System.out.println(index);
				          			System.out.println("++++++保存时间+++++++");
				          			result = "购买道具：[" + billingIndex + "] 取消！";
				          			break;
				    	  	}
				    	  	Toast.makeText(AppActivity.this, result, Toast.LENGTH_SHORT).show();
				      	}
				    };
				    
				    final String billingIndex = getBillingIndex(msg.arg1);

					    GameInterface.doBilling(AppActivity.this, true, true, billingIndex, null, billingCallback);
//					}   

				    break;
				case 1:		
					//设置隐藏
			
					    // 移动退出接口，含确认退出UI
					    // 如果外放渠道（非移动自有渠道）限制不允许包含移动退出UI，可用exitApp接口（无UI退出）
					    GameInterface.exit(AppActivity.this, new GameInterface.GameExitCallback() {
					      @Override
					      public void onConfirmExit() {
					        AppActivity.this.finish();
					        System.exit(0);
					      }

					      @Override
					      public void onCancelExit() {
					        Toast.makeText(AppActivity.this, "取消退出", Toast.LENGTH_SHORT).show();
					      }
					    });
					

				break;
				
				}
			}
		};
	    
	
		hostIPAdress = getHostIpAddress();


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

	private static native boolean nativeIsLandScape();
	private static native boolean nativeIsDebug();
	
	//获取单例
	public static Object getInstance() {
		return instance;
	}
	
	//本地方法在c++中实现
	private static native void saveTimeByIndex(int billingIndex);
	
	private static String getBillingIndex(int i) {
	    if (i <= 9) {
	      return "00" + i;
	    } else {
	      return "0" + i;
	    }
	  }
	// 显示购买页面
	public static void showBuyStatic(final String tag, final int luaFunctionId) {
		Message msg = handler.obtainMessage();	
		msg.what = 0;
		msg.arg1 = Integer.parseInt(tag);
		msg.arg2 = luaFunctionId;

		handler.sendMessage(msg);	
	}
	
	// 显示购买页面
		public static void showBuy_Static(int tag) {
			Message msg = handler.obtainMessage();	
			msg.what = 0;
			msg.arg1 = tag;

			handler.sendMessage(msg);	
		}
	// 退出游戏
	public static void exitGameStatic() {
		Message msg = handler.obtainMessage();	
		msg.what = 1;
		handler.sendMessage(msg);
		
	}
	
	// 测试
	public static int AddTwoNumbers(final int number1,
	        final int number2) {
	    return number1 + number2;
	}

	static {
        System.loadLibrary("cocos2dcpp");
    }
}
