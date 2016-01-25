package com.tyrion.plugin.sharesdk;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import cn.sharesdk.wechat.friends.Wechat;

/**
 * Created by Tyrion on 16/1/21.
 */
public class ShareSdkImageUtils {

    public static final String TAG = "ShareSdkImageUtils";

    public static String storeImageFromUrl(String url){

        String localPath = "";
        try {
            Bitmap mBitmap = BitmapFactory.decodeStream(getImageStream(url));
            localPath = saveBitmap(mBitmap, ShareSdkConst.SHARE_SDK_HEAD_IMG);
        } catch (Exception e) {
            e.printStackTrace();
        }

//        Log.e(TAG, localPath);
        return localPath;
    }

    public static String saveBitmap(Bitmap bitmap, String picName) {

        String foderPath = Environment.getExternalStorageDirectory() + File.separator + ShareSdkConst.TEMP_FODER_NAME + "/";
        File destDir = new File(foderPath);
        if (!destDir.exists()) {
            destDir.mkdirs();
        }

//        Log.e(TAG, foderPath);

        File f = new File(foderPath, picName);
        if (f.exists()) {
            f.delete();
        }
        try {
            FileOutputStream out = new FileOutputStream(f);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out);
            out.flush();
            out.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally{
//            Log.e(TAG, "头像下载完成");
//            Log.e(TAG, f.getPath());
            return f.getPath();
        }
    }

    /*
     * 从网络获取图片
     */
    protected static InputStream getImageStream(String path) throws Exception {
        URL url = new URL(path);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(10 * 1000);
        conn.setRequestMethod("GET");
        if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
            return conn.getInputStream();
        }
        return null;
    }
}
