var exec = require('cordova/exec');

exports.wechatLogin = function(arg0, success, error) {
    exec(success, error, "ShareSdkPlugin", "wechatLogin", [arg0]);
};
