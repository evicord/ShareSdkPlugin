var exec = require('cordova/exec');

exports.init = function(arg0, success, error) {
    exec(success, error, "ShareSdkPlugin", "init", [arg0]);
};

exports.wechatLogin = function(arg0, success, error) {
    exec(success, error, "ShareSdkPlugin", "wechatLogin", [arg0]);
};
