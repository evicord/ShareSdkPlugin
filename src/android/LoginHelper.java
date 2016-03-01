package com.tyrion.plugin.sharesdk;

import android.content.Context;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;
import java.util.HashMap;

import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;

/**
 * Created by WYF on 15/8/18.
 */
public class LoginHelper {

    public String TAG = getClass().getName();
    private static Context context;
    private OnLoginListener loginListener = null;
    private static final int WeChatPlatform = 0;
    private static final int WeboPlatform = 1;

    private int platformType = 0;
    private String platformName = "";


    private String userID = "";
    private String userName = "";
    private String token = "";
    private String icon = "";
    private String openID = "";
    private String iconUrl = "";

    public LoginHelper(Context mContent){
        this.context = mContent;
    }

    public void login(String platformName){
        Platform platform= ShareSDK.getPlatform(context, platformName);
        authorize(platform);
    }

    public void logout(String platformName){
        Platform platform= ShareSDK.getPlatform(context, platformName);
        platform.removeAccount(true);
    }

    public void setLoginListener(OnLoginListener loginListener) {
        this.loginListener = loginListener;
    }

    private void authorize(Platform plat) {

        plat.setPlatformActionListener(new PlatformActionListener() {
            @Override
            public void onComplete(Platform platform, int i, HashMap<String, Object> hashMap) {
//                Log.e(TAG, "onComplete " + platform.getName() + " " + i + " " + hashMap + "");
                userID = platform.getDb().getUserId();
                userName = platform.getDb().getUserName();
                token = platform.getDb().getToken();
                icon = platform.getDb().getUserIcon();
                if (platformType==0){
                    LoginHelper.this.openID = String.valueOf(hashMap.get("openid"));
                }


                //头像保存至本地
                String headImgUrl = String.valueOf(hashMap.get("headimgurl"));
                String localHeadImg = "";
                if(!headImgUrl.equals("")){
                    localHeadImg = ShareSdkImageUtils.storeImageFromUrl(headImgUrl);
                }


                JSONObject userInfo = new JSONObject();
                try {
                    userInfo.put("id", platform.getDb().getUserId());
                    userInfo.put("nickname", String.valueOf(hashMap.get("nickname")));
                    userInfo.put("sex", String.valueOf(hashMap.get("sex")));
                    userInfo.put("token", platform.getDb().getToken());
                    userInfo.put("openid", String.valueOf(hashMap.get("openid")));
                    userInfo.put("unionid", String.valueOf(hashMap.get("unionid")));
                    userInfo.put("headimg", localHeadImg);
                    userInfo.put("country", String.valueOf(hashMap.get("country")));
                    userInfo.put("province", String.valueOf(hashMap.get("province")));
                    userInfo.put("city", String.valueOf(hashMap.get("city")));

                } catch (JSONException e) {
                    e.printStackTrace();
                }

//                Log.e(TAG, localHeadImg);

                if (loginListener!=null) loginListener.onSucceed(userInfo);
            }

            @Override
            public void onError(Platform platform, int i, Throwable throwable) {
//                Log.e(TAG, "onError");
                if (loginListener!=null) loginListener.onFailed();
            }

            @Override
            public void onCancel(Platform platform, int i) {
//                Log.e(TAG, "onCancel");
                if (loginListener!=null) loginListener.onCancel();
            }
        });
        plat.SSOSetting(true);
        plat.showUser(null);
    }

    public interface OnLoginListener {
        void onSucceed(JSONObject response);
        void onFailed();
        void onCancel();
    }
}
