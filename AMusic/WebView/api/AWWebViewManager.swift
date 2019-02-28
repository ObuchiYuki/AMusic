import WebKit

class AWWebViewManager {
    static let `default` = AWWebViewManager()
    
    ///どうせ、TabViewControllerベースの作りで一回生成されたWebView解放されないので
    ///メモリリークの心配なし
    var cuurentWebView:WKWebView?
    
    func getConfig()->WKWebViewConfiguration{
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(ADDownloadManager.default, forURLScheme: "dummy")
        
        let _handlers = config.value(forKey: "_urlSchemeHandlers") as! NSMutableDictionary
        
        _handlers.setObject(ADDownloadManager.default, forKey: "https" as NSString)
        _handlers.setObject(ADDownloadManager.default, forKey: "http" as NSString)
        
        return config
    }
}
