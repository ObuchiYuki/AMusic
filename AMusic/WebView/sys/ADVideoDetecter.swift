import Foundation

class ADVideoDetecter: URLProtocol{
    
    static let `default` = ADVideoDetecter()
    func initialize(){
        URLProtocol.registerClass(ADVideoDetecter.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {return true}
    override class func canonicalRequest (for request: URLRequest) -> URLRequest {return request}
    
    override func startLoading() {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let copiedRequest = request
        session.dataTask(with: request) {data, res, err in
            if err != nil{self.client?.urlProtocol(self, didFailWithError: err!);return}
            var flag = true
            
            defer{
                if flag{
                    self.client?.urlProtocol(self, didReceive: res!, cacheStoragePolicy: .allowed)
                    self.client?.urlProtocol(self, didLoad: data!)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }
            
            guard
                let httpResponse = res as? HTTPURLResponse,
                let contentType = httpResponse.allHeaderFields["Content-Type"] as? String,
                let _contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
                let contentLength = Int(_contentLength)
            else {return}
            
            if (contentType == "video/mp4" || contentType.contains("audio")) && contentLength >= 1000{
                flag = false
                NotificationCenter.default.post(name: .ADVideoDetecterDidDetecteVideo, object: data)
            }
            
        }.resume()
    }
    
    override func stopLoading() {}
}
extension ADVideoDetecter:URLSessionDelegate, URLSessionDataDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection respoe: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: respoe)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil{
            self.client?.urlProtocol(self, didFailWithError: error!)
        }else{
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
}

extension Notification.Name{
    static let ADVideoDetecterDidDetecteVideo = Notification.Name(rawValue: "ADVideoDetecterDidFindVideo")
}
