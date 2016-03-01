var exec = require('cordova/exec');

exports.init = function(arg0, success, error) {
    exec(success, error, "ShareSdkPlugin", "init", [arg0]);
};

exports.wechatLogin = function(arg0, success, error) {
    exec(success, error, "ShareSdkPlugin", "wechatLogin", [arg0]);
};

exports.share = function(shareType, data, success, error) {
    exec(success, error, "ShareSdkPlugin", "share", [shareType, data]);
};