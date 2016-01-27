package com.tyrion.plugin.sharesdk;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.wechat.friends.Wechat;

/**
 * This class echoes a string called from JavaScript.
 */
public class ShareSdkPlugin extends CordovaPlugin {

    public String TAG = getClass().getName();
    CallbackContext callback;

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
        return false;
    }
}
