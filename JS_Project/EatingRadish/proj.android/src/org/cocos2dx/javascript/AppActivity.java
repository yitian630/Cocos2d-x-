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
package org.cocos2dx.javascript;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxJavascriptJavaBridge;
import android.content.pm.ActivityInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.WindowManager;
import android.widget.Toast;

import cn.cmgame.billing.api.BillingResult;
import cn.cmgame.billing.api.GameInterface;
import cn.cmgame.billing.api.GameOpenActivity;

// The name of .so is specified in AndroidMenifest.xml. NativityActivity will load it automatically for you.
// You can use "System.loadLibrary()" to load other .so files.

public class AppActivity extends Cocos2dxActivity{

    static String hostIPAdress = "0.0.0.0";
    private static Handler handler;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        
        System.out.println("进入游戏");
	    handler = new Handler(){
			
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 0:
				
					System.out.println("---------------");
					
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
				          			callJavascriptMethod(billingIndex);
				          			result = "购买道具：[" + billingIndex + "] 成功！";
				          			break;
				          		case BillingResult.FAILED:
				          			result = "购买道具：[" + billingIndex + "] 失败！";
				          			break;
				          		default:
				          			result = "购买道具：[" + billingIndex + "] 取消！";
				          			break;
				    	  	}
				    	  	Toast.makeText(AppActivity.this, result, Toast.LENGTH_SHORT).show();
				      	}
				    };
				    
				    final String billingIndex = getBillingIndex(msg.arg1);

					    GameInterface.doBilling(AppActivity.this, true, true, billingIndex, null, billingCallback);
   

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

        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        if(nativeIsDebug()){
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        hostIPAdress = getHostIpAddress();
    }
    
    @Override
    public Cocos2dxGLSurfaceView onCreateView() {
        Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
        // TestCpp should create stencil buffer
        glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);

        return glSurfaceView;
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
    
    private static String getBillingIndex(int i) {
	    if (i <= 9) {
	      return "00" + i;
	    } else {
	      return "0" + i;
	    }
	  }
    // 显示购买页面
 	public static void showBuyStatic(final String tag) {
 		Message msg = handler.obtainMessage();	
 		msg.what = 0;
 		msg.arg1 = Integer.parseInt(tag);

 		handler.sendMessage(msg);	
 	}
 	
 	//购买成功后回调
    public static final void callJavascriptMethod(String index) {//【java调用javascript方法】
        final String jsCallStr = String.format("JavaHelper.javascriptMethod('%s')", index);
        Cocos2dxHelper.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxJavascriptJavaBridge.evalString(jsCallStr);
            }
        });
    }
    // 退出游戏
 	public static void exitGameStatic() {
 		Message msg = handler.obtainMessage();	
 		msg.what = 1;
 		handler.sendMessage(msg);
 		
 	}
 	static {
 		System.loadLibrary("cocos2djs");
 	}
}
