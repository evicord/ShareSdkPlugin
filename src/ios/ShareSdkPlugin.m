//
//  ShareSDKPlugin.m
//  panart
//
//  Created by zsly on 16/1/25.
//
//

#import "ShareSdkPlugin.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "Operation.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>

@implementation ShareSdkPlugin

-(void)checkInStall:(CDVInvokedUrlCommand*)command
{
    NSArray *array=command.arguments[0];
    NSInteger i;
    NSMutableArray *rs_arry=[NSMutableArray arrayWithCapacity:array.count];
    for (i=0; i<array.count; i++) {
        NSNumber *isInStall=@(YES);
        switch (i) {
            case 0:
                isInStall=![WXApi isWXAppSupportApi]?@(NO):isInStall;
                break;
                
            case 1:
                isInStall=![WeiboSDK isWeiboAppInstalled]?@(NO):isInStall;
                break;
            default:
                break;
        }
        [rs_arry addObject:isInStall];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:rs_arry];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ShareSDKParams" ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    data=[data objectForKey:@"params"];
    NSString *shareSdk_appid=[data objectForKey:@"SDK_KEY"];
    
    NSDictionary *weChat_dict=[data objectForKey:@"WeChat"];
    NSString *weChat_appid=[weChat_dict objectForKey:@"WECHAT_ID"];
    NSString *weChat_secret=[weChat_dict objectForKey:@"WECHAT_SECRET"];
    
    NSDictionary *sinaWeiBo_dict=[data objectForKey:@"sinaWeiBo"];
    NSString *sinaWeiBo_appid=[sinaWeiBo_dict objectForKey:@"SINAWEIBO_ID"];
    NSString *sinaWeiBo_secret=[sinaWeiBo_dict objectForKey:@"SINAWEIBO_SECRET"];
    NSString *sinaWeiBo_redirecturi=[sinaWeiBo_dict objectForKey:@"SINAWEIBO_REDIRECTURI"];
    
    [ShareSDK registerApp:shareSdk_appid
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformTypeWechat)]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:sinaWeiBo_appid
                                                appSecret:sinaWeiBo_secret
                                              redirectUri:sinaWeiBo_redirecturi
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:weChat_appid appSecret:weChat_secret];
                      break;
                  default:
                      break;
              }
          }];
    
}
-(void)login:(CDVInvokedUrlCommand*)command
{
    NSNumber *number=command.arguments[0];
    ShareSDKLoginType type=(ShareSDKLoginType)number.integerValue;
    switch (type) {
        case k_weixin_login:
            [self weixinLogin:command];
            break;
            
        case k_weibo_login:
            [self weiboLogin:command];
            break;
            
        default:
            break;
    }
}

-(void)weixinLogin:(CDVInvokedUrlCommand*)command
{
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeWechat
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       
                                       CDVPluginResult*pluginResult=[self addUserInfo:k_weixin_login uid:[user  uid] unionid:[[user rawData] objectForKey:@"unionid"] nickname:[user nickname] icon:[user icon] accessToken:[[user credential] token]];
                                       [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                       
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    
                                    
                                    if (state == SSDKResponseStateSuccess){
                                        //判断是否已经在用户列表中，避免用户使用同一账号进行重复登录
                                        
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            //取消web_loading显示
                                            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                        });
                                        
                                    }
                                    
                                }];
}

-(void)weiboLogin:(CDVInvokedUrlCommand*)command
{
    [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:@{SSDKAuthSettingKeyScopes : @[@"follow_app_official_microblog"]} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess){
            CDVPluginResult*pluginResult=[self addUserInfo:k_weibo_login uid:[user  uid] unionid:nil nickname:[user nickname] icon:[user icon] accessToken:[[user credential] token]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //取消web_loading显示
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            });
        }
    }];
}

-(CDVPluginResult*)addUserInfo:(ShareSDKLoginType)_loginType uid:(NSString*)uid unionid:(NSString*)unionid nickname:(NSString*)nickname icon:(NSString*)icon accessToken:(NSString*)accessToken
{
    [Operation createDirectory];
    NSData* data=[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]];
    NSString* tmpPath =[Operation tmpImagesDirectoryPath];
    NSDate *date=[NSDate date];
    NSString *filePath=[NSString stringWithFormat:@"%@/%ld_%@", tmpPath,(long)date.timeIntervalSince1970,@"tmpImage"];
    
    NSError* err = nil;
    CDVPluginResult *pluginResult = nil;
    if(![data writeToFile:filePath options:NSAtomicWrite error:&err])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    }
    else
    {
        unionid=unionid==nil?@"":unionid;
        NSDictionary*dict=@{@"login_type":@(_loginType),@"uid":uid,@"unionid":unionid,@"nickname" :nickname,@"headimg":filePath,@"accessToken":accessToken};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    }
    return pluginResult;
}

- (void)share:(CDVInvokedUrlCommand*)command
{
    NSNumber *number=command.arguments[0];
    NSDictionary *work_data=command.arguments[1];
    /* work_data
    作品ID
    作品类型
    专题名称或作品名称
    专题图片url或作品图url
    作者
    专题url或作品url
    */
    SSDKPlatformType type=SSDKPlatformTypeUnknown;
    switch ([number integerValue]) {
        case 0:
            type=SSDKPlatformSubTypeWechatTimeline;
            //微信朋友圈 SSDKPlatformSubTypeWechatTimeline
            break;
        case 1:
            type=SSDKPlatformSubTypeWechatSession;
            //微信好友 SSDKPlatformSubTypeWechatSession
            break;
        case 2:
            type=SSDKPlatformTypeSinaWeibo;
            //新浪微博 SSDKPlatformTypeSinaWeibo
            break;
    }
    if(type!=SSDKPlatformTypeUnknown)
    {
        [self shareType:type data:work_data callbackId:command.callbackId];
    }
}

-(void)shareType:(SSDKPlatformType)share_type data:(NSDictionary*)data callbackId:(NSString*)callbackId
{
    
    NSString* title=[data objectForKey:@"title"];//专题名称或作品名称
    NSString* imageUrl=[data objectForKey:@"viewUrl"];//专题图片url或作品图url
    NSString* author=[data objectForKey:@"auther"];//作者
    NSString* work_url=[data objectForKey:@"serveUrl"];//专题url或作品url
    
    
    SSDKPlatformType shareType = share_type;
    
    NSString* content=nil;
    if (shareType == SSDKPlatformTypeSinaWeibo) {
//        NSString* downloadUrl = @"https://www.9panart.com/0/install";
        content = [NSString stringWithFormat:@"【%@】作者：%@。(分享自@泛艺术)",title,author];
        
    }else if(shareType == SSDKPlatformSubTypeWechatTimeline) {
        
        imageUrl=imageUrl?[NSString stringWithFormat:@"%@@100w.jpg", imageUrl]:imageUrl;// weinxin 小图
        content=nil;
        
    }else if(shareType == SSDKPlatformSubTypeWechatSession)
    {
        imageUrl=imageUrl?[NSString stringWithFormat:@"%@@100w.jpg", imageUrl]:imageUrl;// weinxin 小图
        content=[NSString stringWithString:title];
        title=nil;
    }
    
    
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageUrl
                                        url:[NSURL URLWithString:work_url]
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKEnableUseClientShare];
    
    //进行分享
    [ShareSDK share:shareType
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                 });
                 break;
             }
             case SSDKResponseStateFail:
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSString *error_str=@"分享失败";
                     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error_str];
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
                 });
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 NSLog(@"发布取消 type: %lu",(unsigned long)shareType);
                 break;
             }
             default:
                 break;
         }
         
     }];
    
}

@end
