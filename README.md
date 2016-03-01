# ShareSdkPlugin
### Cordova ShareSDK插件

### 1.准备工作
		1. 添加平台

		cd Myproj 
		cordova platform add android  
		cordova platform add ios

		ps:这里请注意iOS平台，必须先执行 `cordova platform add ios`,
		然后再执行`cordova plugin add xxxxx`命令，不然有一些必须要的链接库需要手动添加
		
### 2.Cordova CLI/Phonegap 安装 Android & iOS

1).  安装ImagePicker plugin（工程目录下）

方法一： 在线安装

	cordova plugin add https://github.com/evicord/ShareSdkPlugin.git --variable SDK_KEY=<ShareSDK APP_ID> --variable WECHAT_ID=<微信APP_ID> --variable WECHAT_SECRET=<微信SECRET> --variable SINAWEIBO_ID=<新浪微博APP_ID> --variable SINAWEIBO_SECRET=<新浪微博SECRET>

方法二：下载到本地再安装

使用git命令将ShareSdkPlugin phonegap插件下载的本地,将这个目录标记为`$SHARE_SDK_PLUGIN_DIR`


    git clone https://github.com/evicord/ShareSdkPlugin.git
    cordova plugin add $SHARE_SDK_PLUGIN_DIR --variable SDK_KEY=<ShareSDK APP_ID> --variable WECHAT_ID=<微信APP_ID> --variable WECHAT_SECRET=<微信SECRET> --variable SINAWEIBO_ID=<新浪微博APP_ID> --variable SINAWEIBO_SECRET=<新浪微博SECRET>