import UIKit
import WebKit

class ADDownloadTask {
    // MARK: Properties
    var data:Data?
    var metadata:ADMetadata? = nil
    var progress:Progress?
    var currentState:ADDownloadTaskState = .initializing
    var isEnabled = false
    var webpage:WebData?
    
    func applyWebView(_ webView:WKWebView){
        self.webpage = WebData(webView: webView)
    }
    
    class WebData {
        var page:HTML?
        var url:URL?
        var title:String?
        init(webView:WKWebView) {
            title = webView.title
            url = webView.url
            webView.getHtml{html in
                self.page = html
            }
        }
    }
    
    var eta:TimeInterval?{
        return progress?.estimatedTimeRemaining
    }
    
    // MARK: Private Properties
    private var _id = UUID().uuidString
}

extension ADDownloadTask:Equatable{
    static func == (lhs: ADDownloadTask, rhs: ADDownloadTask) -> Bool {return lhs._id == rhs._id}
}
enum ADDownloadTaskState {
    case initializing
    case downloading
    case completed
    
    var string:String{
        switch self {
        case .initializing: return "初期化中..."
        case .downloading:  return "ダウンロード中..."
        case .completed:    return "完了"
        }
    }
}
