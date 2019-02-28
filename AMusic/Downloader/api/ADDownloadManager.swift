import WebKit
import Alamofire

class ADDownloadManager:NSObject, WKURLSchemeHandler {
    
    // MARK: Singleton
    static let `default` = ADDownloadManager()
    
    // MARK: Private Properties
    private var _runningTasks = [_ADDataTask]()
    
    // MARK: Protocol WKURLSchemeHandler
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let id = urlSchemeTask.request.url!.absoluteString
        self._runningTasks.insert(_ADDataTask(id: id, schemeTask: urlSchemeTask),at:0)
        
        let session = URLSession(configuration: .default, delegate:self, delegateQueue: .main)
        session.sessionDescription = id
        session.dataTask(with: urlSchemeTask.request).resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        _stopTask(with: urlSchemeTask)
    }
    
    // MARK: Private Methods
    private func _stopTask(with urlSchemeTask:WKURLSchemeTask){
        guard let task = _runningTasks.filter({$0.isEqual(to: urlSchemeTask)}).first else {return}
        
        _runningTasks.remove(of: task)
    }
    private func _createDownloadTask()->ADDownloadTask{
        let task = ADDownloadTask()
        return task
    }
    private func _getTask(for session:URLSession)->_ADDataTask?{
        guard let id = session.sessionDescription else {return nil}

        return _runningTasks.filter{$0.id == id}.first
    }

    private func _checkIfVideo(with responce:URLResponse)->Bool{
        guard
            let httpResponse = responce as? HTTPURLResponse,
            let contentType = httpResponse.allHeaderFields["Content-Type"] as? String,
            let _contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
            let contentLength = Int(_contentLength)
        else {return false}
        
        return (contentType == "video/mp4" || contentType.contains("audio")) && contentLength >= 1000
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: ._ADDataTaskDidFinish, object: nil, queue: .main){notice in
            guard let id = notice.object as? String else {return}
            guard let task = self._runningTasks.filter({$0.id == id}).first else {return}
            
            self._runningTasks.remove(of: task)
        }
    }
}
extension ADDownloadManager:URLSessionDataDelegate{
    // MARK: Delegate Methods For Data Tasks.
    func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        guard let task = _getTask(for: session) else {return}
        let isVideo = _checkIfVideo(with: response)
        task.didReceive(response)
        
        if isVideo && !task.isVideoTask{///Video Detector
            task.isVideoTask = true
            task.downloadTask = _createDownloadTask()
            if _ADVideoDownloader.default.enableTask(task){
                NotificationCenter.default.post(name: .AWWebViewDidDetecteVideo, object: task.downloadTask)
                NotificationManager.default.post("ビデオが見つかりました。")
            }
            dataTask.cancel()
        }
        
        completionHandler(.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = _getTask(for: session) else {session.invalidateAndCancel();return}
        
        task.didReceive(data)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let datatask = _getTask(for: session) else {session.invalidateAndCancel();return}
        
        if let error = error{
            datatask.didFailWithError(error)
        }else{
            datatask.didFinish()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        streamTask.resume()
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        downloadTask.resume()
    }
    func urlSession(
        _ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
extension Notification.Name{
    static let AWWebViewDidDetecteVideo = Notification.Name(rawValue: "AWWebViewDidDetecteVideo")
    static let AWWebViewDownloadingVideo = Notification.Name(rawValue: "AWWebViewDownloadingVideo")
    static let AWWebViewDidDownloadVideo = Notification.Name(rawValue: "AWWebViewDidDownloadVideo")
}
// MARK: Private _ADVideoDownloader
private class _ADVideoDownloader{
    // MARK: Singleton
    static let `default` = _ADVideoDownloader()
    
    // MARK: Properties
    private var _previousRequets = [URLRequest]()
    
    // MARK: APIs
    func enableTask(_ task:_ADDataTask)->Bool{//enable可能か
        if _previousRequets.contains(task.request) {//実行したことがあるか
            return false
        }
        _previousRequets.append(task.request)
        
        Alamofire.request(task.request)
            .downloadProgress{prg in
                task.downloadTask?.progress = prg
            }
            .response{res in
                if let error = res.error{
                    task.didFailWithError(error)
                }else{
                    task.downloadTask?.data = res.data
                    task.downloadTask?.currentState = .completed
                    NotificationCenter.default.post(name: .AWWebViewDidDownloadVideo, object: task.downloadTask)
                }
        }
        
        return true
    }
    // MARK: Private Methods
}
// MARK: Private _ADDataTask
private class _ADDataTask{
    // MARK: Properties
    var id:String
    var isVideoTask = false
    var downloadTask:ADDownloadTask?
    private var _schemeTask:WKURLSchemeTask
    
    var request:URLRequest{
        return _schemeTask.request
    }
    
    // MARK: APIs
    func didReceive(_ responce:URLResponse){
        self._schemeTask.didReceive(responce)
    }
    func didReceive(_ data:Data){
        self._schemeTask.didReceive(data)
    }
    func didFinish(){
        self._schemeTask.didFinish()
        self._didFinish()
    }
    
    func didFailWithError(_ error:Error){
        self._schemeTask.didFailWithError(error)
        self._didFinish()
    }
    
    // MARK: Private Methods
    private func _didFinish(){
        NotificationCenter.default.post(name: ._ADDataTaskDidFinish, object: id)
    }
    
    // MARK: Init
    init(id:String,schemeTask:WKURLSchemeTask) {
        self.id = id
        self._schemeTask = schemeTask
    }
}
private extension Notification.Name{
    static let _ADDataTaskDidFinish = Notification.Name(rawValue: "_ADDataTaskDidFinish")
}

extension _ADDataTask:Equatable{
    static func == (lhs: _ADDataTask, rhs: _ADDataTask) -> Bool {return lhs.id == rhs.id}
    
    func isEqual(to task:WKURLSchemeTask)->Bool{
        return self._schemeTask.request == task.request
    }
}




