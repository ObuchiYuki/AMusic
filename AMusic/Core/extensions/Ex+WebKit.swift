import WebKit

// MARK: - Extension for WebKit

extension WKWebView{
    /// Get the HTML of the displayed page as Ji Object.
    ///
    /// - Parameter completion: completion.
    func getHtml(_ completion:@escaping (HTML?)->Void){
        self.evaluateJavaScript("document.body.innerHTML"){html, _ in
            guard let document = html as? String else {completion(nil);return}
            guard let html = HTML(htmlString: document) else {completion(nil);return}
            completion(html)
        }
    }
}
