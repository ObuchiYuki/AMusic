import Foundation

enum AWSearchManagerSearchHost{
    case google
    case yahoo
    case bing
    case youtube
    case duckDuckGo
    
    var name:String{
        switch self {
        case .google: return "Google"
        case .yahoo: return "Yahoo"
        case .bing: return "Bing"
        case .youtube: return "YouTube"
        case .duckDuckGo: return "DuckDuckGo"
        }
    }
    
    func url(with query:String)->URL{
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        switch self {
        case .google:
            return "https://www.google.co.jp/search?q=\(query)".url!
        case .yahoo:
            return "https://search.yahoo.co.jp/search?&fr=crmas&p=\(query)".url!
        case .bing:
            return "https://www.bing.com/search?q=\(query)&PC=U316&FORM=CHROMN".url!
        case .youtube:
            return "https://www.youtube.com/results?search_query=\(query)&utm_source=opensearch".url!
        case .duckDuckGo:
            return "https://duckduckgo.com/?q=\(query)&atb=v107-3__".url!
        }
    }
}

class AWSearchManager {
    // MARK: Singleton
    static let `default` = AWSearchManager()
    
    // MARK: APIs
    var searchHost:AWSearchManagerSearchHost = .google
    
    func search(with word:String)->URL{
        return _purse(word)!
    }
    func getQuery(with url:URL)->String?{
        return _extractQuery(from: url)?.removingPercentEncoding
    }
    
    // MARK: Private Properties
    private lazy var tlds:[String] = {
        let tldsString = (try? String(contentsOfFile: Bundle.main.path(forResource: "tlds", ofType: "txt")!)) ?? ""
        let tlds = tldsString.split(separator: "\n")
        
        return tlds.map{String($0)}
    }()
    // MARK: Private Methods
    
    /// ExtractTld: Extract Top Level Domain fomm text
    ///
    /// - Parameter text: Text without protocol
    /// - Returns: TLD if exists.
    private func _extractTld(from text:String)->String?{
        let str0 = text.split(separator: "/")
        guard let tdl = str0.first?.split(separator: ".").last else {return nil}
        return String(tdl)
    }
    
    /// CheckIfContainsProtocol: Check the text has a protocol like "http://" or "https://". And returns Text without protocol
    private func _checkIfContainsProtocol(with text:String)->(Bool,String){
        var flag = false
        var result = text
        if text.contains("https://") || text.contains("http://") || text.contains("ftp://"){
            flag = true
            result = text.removed("https://").removed("http://").removed("ftp://")
        }
        
        return (flag,result)
    }
    private func _extractQuery(from url:URL)->String?{
        guard let comp = URLComponents(url: url, resolvingAgainstBaseURL: true) else {return nil}
        return comp.paramators.filter{$0.key == "q" || $0.key.contains("query")}.first?.value
    }
    private func _purse(_ text:String)->URL?{
        var result:URL? = nil
        let text = text//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        
        let (protocolFlag,str) = _checkIfContainsProtocol(with: text)
        if protocolFlag{result = text.url}
        
        if let tld = _extractTld(from: str), tlds.contains(tld){//estimated to url
            result = ("https://"+text).url
        }else{//estimated not to url
            result = searchHost.url(with: text)
        }
        return result
    }
}









