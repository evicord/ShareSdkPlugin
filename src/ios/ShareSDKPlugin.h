//
//  ShareSDKPlugin.h
//  panart
//
//  Created by zsly on 16/1/25.
//
//

#import <Cordova/CDV.h>

typedef enum _shareSDKLoginType
{
    k_weixin_login,
    k_weibo_login,
    
}ShareSDKLoginType;

@interface ShareSDKPlugin : CDVPlugin
-(void)login:(CDVInvokedUrlCommand*)command;
@end
