package com.tyrion.plugin.sharesdk;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

import cn.sharesdk.framework.Platform.ShareParams;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;
import cn.sharesdk.sina.weibo.SinaWeibo;
import cn.sharesdk.wechat.friends.Wechat;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.wechat.moments.WechatMoments;

/**
 * This class echoes a string called from JavaScript.
 */
public class ShareSdkPlugin extends CordovaPlugin implements PlatformActionListener{

    public String TAG = getClass().getName();
    CallbackContext callback;

    public interface ShareType {
        int wechatMoments = 0;
        int wechat = 1;
        int weibo = 2;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("init")) {
            ShareSDK.initSDK(this.cordova.getActivity());
            ShareSDK.setConnTimeout(20000);
            ShareSDK.setReadTimeout(20000);
            return true;
        }

        if (action.equals("wechatLogin")) {
            callback = callbackContext;
            String message = args.getString(0);

            LoginHelper login = new LoginHelper(this.cordova.getActivity());
            login.setLoginListener(new LoginHelper.OnLoginListener() {
                @Override
                public void onSucceed(JSONObject response) {
//                    Log.e(TAG, "用户资料获取成功");
                    PluginResult result = new PluginResult(PluginResult.Status.OK, response);
                    callback.sendPluginResult(result);
                }

                @Override
                public void onFailed() {
//                    Log.e("onFailed", "onFailed");
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, "failed");
                    callback.sendPluginResult(result);
                }

                @Override
                public void onCancel() {
//                    Log.e("onCancel", "onCancel");
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, "cancel");
                    callback.sendPluginResult(result);
                }
            });
            login.login(Wechat.NAME);
//            login.logout(Wechat.NAME);
            return true;
        }

        if (action.equals("share")) {
            callback = callbackContext;
            int type = args.getInt(0);
            JSONObject data = args.getJSONObject(1);
            switch (type){
                case ShareType.wechatMoments: {
                    OnekeyShare oks = new OnekeyShare();
                    oks.setPlatform(WechatMoments.NAME);
                    oks.setTitle(data.getString("title"));
                    oks.setImageUrl(data.getString("viewUrl"));
                    oks.setUrl(data.getString("serveUrl"));
                    oks.setCallback(this);
                    oks.show(this.cordova.getActivity());
                    break;
                }
                case ShareType.wechat: {
                    OnekeyShare oks = new OnekeyShare();
                    oks.setPlatform(Wechat.NAME);
                    oks.setText(data.getString("title"));
                    oks.setImageUrl(data.getString("viewUrl"));
                    oks.setUrl(data.getString("serveUrl"));
                    oks.setCallback(this);
                    oks.show(this.cordova.getActivity());
                    break;
                }
                case ShareType.weibo: {
//                    OnekeyShare oks = new OnekeyShare();
//                    oks.setPlatform(SinaWeibo.NAME);
//                    oks.setTitle("title");
//                    oks.setText(data.getString("title"));
//                    oks.setImageUrl(data.getString("viewUrl"));
//                    oks.setUrl(data.getString("serveUrl"));
//                    oks.setCallback(this);
//                    oks.show(this.cordova.getActivity());

                    ShareParams sp = new ShareParams();
                    sp.setText(data.getString("title"));
                    sp.setImageUrl(data.getString("viewUrl"));
                    Platform weibo = ShareSDK.getPlatform(SinaWeibo.NAME);
                    weibo.setPlatformActionListener(this); // 设置分享事件回调
                    weibo.share(sp);
                    break;
                }

            }
            return true;
        }
        return false;
    }

    @Override
    public void onComplete(Platform platform, int i, HashMap<String, Object> hashMap) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, platform.getName());
        callback.sendPluginResult(result);
    }

    @Override
    public void onError(Platform platform, int i, Throwable throwable) {
        throwable.printStackTrace();
        PluginResult result = new PluginResult(PluginResult.Status.ERROR, platform.getName());
        callback.sendPluginResult(result);
    }

    @Override
    public void onCancel(Platform platform, int i) {
        PluginResult result = new PluginResult(PluginResult.Status.ERROR, platform.getName());
        callback.sendPluginResult(result);
    }
}
