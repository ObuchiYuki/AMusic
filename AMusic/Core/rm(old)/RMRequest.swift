import Foundation
import SwiftyJSON

/// RMRequest (c) obuchiyuki 2016.
/// あまり使わないでください...古いです。
/// ただ依存関係により削除できないのでここにあります。
/// 今後はAlamofireを使ってください。

class RMRequest{
    // MARK: Enums
    enum Method:String {
        case post = "POST",get = "GET",delete = "DELETE",put = "PUT",head = "HEAD"
    }
    enum RMRequestError : Error{
        case unknown
        case noDataDownloaded
        case noUrl
    }
    
    // MARK: Properties
    var url:URL?
    var method = Method.get
    var headers = [String:String]()
    var bodyData = Data()
    var timeoutInterval:TimeInterval = 60.0
    var isAsync = true
    var raw:URLRequest?{return self.createRequest()}
    
    // MARK: Private Properties
    static private var runnigRequests:[RMRequest] = []
    
    private let _id:UUID
    private var _progressHandler:(Double)->() = {_ in}
    private var _errorHandler:(Error)->() = {_ in}
    private var _completion:(Data)->() = {_ in}
    private var _locationCompletion:(URL)->() = {_ in}
    
    // MARK: API
    
    
    /// RMRequest don't be fired automatically like Almofire.
    func fire(){
        guard let request = createRequest() else {return}
        didStartDownload()
        if isAsync{
            let connection = RMConnection(request: request)
            connection.completion = {[weak self] location in
                guard let data = try? Data(contentsOf: location) else {return}
                self?._locationCompletion(location)
                self?._completion(data)
                self?.didEndDowload()
            }
            connection.progressHandler = _progressHandler
            connection.errorHandler = _errorHandler
            connection.fire()
        }else{
            guard let data = URLSession.shared.synchronousDataTask(with: request) else {return}
            _completion(data)
        }
    }
    
    // MARK: Private Methods
    private func didStartDownload(){
        RMRequest.runnigRequests.append(self)
    }
    private func didEndDowload(){
        guard let index = RMRequest.runnigRequests.index(where: {$0._id == self._id}) else {return}
        RMRequest.runnigRequests.remove(at: index)
    }
    private func createRequest()->URLRequest?{
        guard let url = self.url else {self._errorHandler(RMRequestError.noUrl);return nil}
        var request = URLRequest(url: url)
        headers.forEach{request.addValue($0.value, forHTTPHeaderField: $0.key)}        
        request.httpBody = self.bodyData
        request.httpMethod = self.method.rawValue
        request.timeoutInterval = self.timeoutInterval
        
        return request
    }
    
    // MARK: init
    init(url:URL?) {
        self.url = url
        self._id = UUID()
    }
    init(request:URLRequest) {
        self.url = request.url!
        self._id = UUID()
        
        self.headers = request.allHTTPHeaderFields ?? [:]
        self.bodyData = request.httpBody ?? Data()
        self.method = Method(rawValue: request.httpMethod ?? "GET") ?? .get
    }
}
// MARK: Extensions for use of chain methods.
extension RMRequest{
    func setMethod(_ method:Method)->RMRequest{self.method = method;return self}
    func addHeader(key:String,value:String)->RMRequest{self.headers[key] = value;return self}
    func setHeader(_ headers:[String:String])->RMRequest{self.headers = headers;return self}
    func setBodyData(_ data:Data)->RMRequest{self.bodyData = data;return self}
    
    func setIfAsync(_ flag:Bool)->RMRequest{isAsync = flag;return self}
    func setTimeout(_ interval:TimeInterval)->RMRequest{timeoutInterval = interval;return self}
    
    func setProgressHandler(_ closure:@escaping (Double)->())->RMRequest{_progressHandler = closure;return self}
    func setErrorHandler(_ closure:@escaping (Error)->())->RMRequest{_errorHandler = closure;return self}
    
    func setDataCompletion(_ completion:@escaping (Data)->())->RMRequest{_completion = completion;return self}
    func setJsonCompletion(_ completion:@escaping (JSON?)->())->RMRequest{_completion = {completion(try? JSON(data: $0))};return self}
    func setUrlCompletion(_ completion:@escaping (URL)->())->RMRequest{_locationCompletion = completion;return self}
}

// MARK: Extensions for conveniece.
extension String{
    var request:RMRequest{return RMRequest(url: URL(string: self))}
}
extension URLRequest{
    var request:RMRequest{return RMRequest(request: self)}
}

// MARK: RMConnection
fileprivate class RMConnection:NSObject{
    var request:URLRequest
    var completion:(URL)->() = {_ in}
    var progressHandler:(Double)->() = {_ in}
    var errorHandler:(Error)->() = {_ in}
    init(request:URLRequest){self.request = request}
    func fire(){
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.downloadTask(with: request)
        task.resume()
    }
}
extension RMConnection:URLSessionTaskDelegate,URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progressHandler(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let error = downloadTask.error{errorHandler(error)}
        self.completion(location)
        
        completion = {_ in}
        progressHandler = {_ in}
        errorHandler = {_ in}
        
        session.invalidateAndCancel()
    }
}
extension URLSession {
    func synchronousDataTask(with request:URLRequest)->Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var _data:Data?
        self.dataTask(with: request) {data,_,_ in _data = data;semaphore.signal()}.resume()
        _=semaphore.wait(timeout: .distantFuture)
        return _data
    }
}




