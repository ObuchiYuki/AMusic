import Foundation
import Ji
import PySwiftyRegex

class LyricsAPI{
    //================================================================================
    //props
    static let `default` = LyricsAPI()
    var cache:[URL:Ji] = [:]
    //=======================================
    //api
    //================================================================================
    //methods
    //=======================================
    //api
    func getLyricsList(for title:String,_ completion:@escaping ([LyricsRequest])->Void){
        DispatchQueue.global().async {
            var
            title = re.sub("【.*?】", "", title)
            title = re.sub("\\(.*?\\)", "", title)
            title = re.sub("\\[.*?\\]", "", title)
            title = title.trimmingCharacters(in: .whitespaces)
            
            let url = self._createRequestUrl(title: title)
            
            guard let html = self.cache[url] != nil ? self.cache[url] : Ji(htmlURL: url) else {
                DispatchQueue.main.sync {completion([])}
                return
            }
            self.cache[url] = html
            guard let songList = html.xPath("//ul[@class=\"songlist\"]/li") else {
                DispatchQueue.main.sync {completion([])}
                return
            }
            
            let lyricsList = songList.map{
                return LyricsRequest(
                    title: $0.xPath("div/a/h2").at(0)?.content ?? "",
                    artist: $0.xPath("div/p/a").at(0)?.content ?? "",
                    url: "http://www.kget.jp" + ($0.xPath("div/a").at(0)?.attributes["href"] ?? "")
                )
            }
            DispatchQueue.main.sync {
                completion(lyricsList)
            }
        }
    }
    func getLyrics(for req:LyricsRequest,_ completion:@escaping (LyricsData?)->Void){
        DispatchQueue.global().async {
            let url = req.url.url!
            
            guard let page = self.cache[url] == nil ? Ji(htmlURL: url) : self.cache[url] else {completion(nil);return}
            self.cache[url] = page
            guard let lyricsNode = page.xPath("//div[@id=\"lyric-trunk\"]")?.at(0) else {completion(nil);return}
            
            let data = LyricsData(title: req.title, lyrics: lyricsNode.content ?? "", artist: req.artist)
            
            DispatchQueue.main.sync {completion(data)}
        }
    }
    //=======================================
    //private
    private func _createRequestUrl(title:String)->URL{
        let param = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "http://www.kget.jp/search/index.php?t=\(param)".url!
    }
    struct LyricsData {
        var title:String
        var lyrics:String
        var artist:String
    }
    struct LyricsRequest {
        var title:String
        var artist:String
        
        fileprivate var url:String
        
    }
}
