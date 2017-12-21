# WechatLogTest

### 接入流程
```
target 'WechatLogTest' do
end
platform :ios, '8.0'
use_frameworks!
pod 'WechatOpenSDK'

```
相关资料：<br>
[iOS接入指南](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=1417694084&token=&lang=zh_CN)<br>
[移动应用微信登录开发指南](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=&lang=zh_CN)<br>
[个人日记保存点](http://www.cnblogs.com/AnchoriteFiliGod/diary/2017/12/21/8080913.html)


### 点击调取微信(BuildSettings中设置好URLTypes)
```swift
func sendAuthRequest() {
    let req: SendAuthReq = SendAuthReq()
    req.scope = "snsapi_userinfo"
    req.state = "WechatLogTest"
    WXApi.send(req)
}
```
### 在appdelegate中设置好所有的东西
```swift
var window: UIWindow?
let APPID = "wx40683bbaae3afdd4"
let SECRET = ""

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    WXApi.registerApp(APPID)
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return WXApi.handleOpen(url, delegate: self)
}

func onReq(_ req: BaseReq!) {

    if req.isKind(of: GetMessageFromWXReq.self) {
    // 微信请求APP提供内容，需要app提供内容后使用senRsp返回
        print("微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信")
    } else if req.isKind(of: ShowMessageFromWXReq.self) {

        let tmp: ShowMessageFromWXReq = req as! ShowMessageFromWXReq

        // 显示微信传过来的内容
        let msg: WXMediaMessage = tmp.message
        let obj: WXAppExtendObject = msg.mediaObject as! WXAppExtendObject

        print("标题：\(msg.title) 内容：\(msg.description) 附带信息：\(obj.extInfo) 缩略图：\(msg.thumbData.count)")
    } else if req.isKind(of: LaunchFromWXReq.self) {
        // 从微信启动app
        print("从微信启动app")
    }
}

func onResp(_ resp: BaseResp!) {

    switch resp.errCode {
    case 0: // 用户同意
        // 调用相关方法
        let aresp: SendAuthResp = resp as! SendAuthResp
        print("code *********** \(aresp.code)")
        weChatCallBackWithCode(code: aresp.code)
        break
    case -4: // 用户拒绝授权
        break
    case -2: // 用户取消
        break
    default:
        break
    }

}

func weChatCallBackWithCode(code: String) {

    let urlString = "https://api.weixin.qq.com/sns/oauth2/access_token"
    print("urlString ************** \(urlString)")

    HYHttpTool.post(url: urlString, param: ["appid":APPID,"secret":SECRET,"code":code,"grant_type":"authorization_code",]) { (response, result) in
        print("dicOne ************ \(result.value)")

        let dic: NSDictionary = result.value as! NSDictionary

        if let errmsg = dic.value(forKey: "errmsg") {
            print("errmsg ************** \(errmsg)")
            return
        }

        self.getUserInfoWithAccessToken(accessToken:  dic.value(forKey: "access_token")  as! String, openId: dic.value(forKey: "openid") as! String)
    }

}

func getUserInfoWithAccessToken(accessToken: String, openId: String) {

    let urlString = "https://api.weixin.qq.com/sns/userinfo"

    HYHttpTool.post(url: urlString, param: ["access_token":accessToken,"openid":openId]) { (response, result) in
        print("dicTwo ************ \(String(describing: result.value))")
        let dic: NSDictionary = result.value as! NSDictionary

        if let errmsg = dic.value(forKey: "errmsg") {
            print("errmsg ************** \(errmsg)")
            return
        }
    }
}
```


