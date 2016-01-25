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

- (void)init:(CDVInvokedUrlCommand*)command
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ShareSDKParams" ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    data=[data objectForKey:@"params"];
    NSString *shareSdk_appid=[data objectForKey:@"SDK_KEY"];
    NSDictionary *weChat_dict=[data objectForKey:@"WeChat"];
    NSString *weChat_appid=[weChat_dict objectForKey:@"WECHAT_ID"];;
    NSString *weChat_secret=[weChat_dict objectForKey:@"WECHAT_SECRET"];;
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
//                  case SSDKPlatformTypeSinaWeibo:
//                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
//                      [appInfo SSDKSetupSinaWeiboByAppKey:@"1083864391"
//                                                appSecret:@"fb9d821655216784cae3f99c443b9068"
//                                              redirectUri:@"https://api.weibo.com/oauth2/default.html"
//                                                 authType:SSDKAuthTypeBoth];
//                      break;
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


@end
