import WebKit
import PySwiftyRegex

/// Specificator For Youtube
class ADSYoutube:ADSpecificator{
    // MARK: Protocol
    var chargedHosts: [String] = ["www.youtube.com","m.youtube.com","youtube.com"]
    
    func applyMetadata(with task: ADDownloadTask,completion:@escaping () -> Void) {
        guard
            let html = task.webpage?.page,
            let url = task.webpage?.url
        else {return}
        
        let metadata = ADMetadata()
        metadata.title = self._generateTitle(with: html)
        metadata.artist = self._generateAuthor(with: html)
        metadata.albumArtist = metadata.artist
        metadata.albumTitle = "Youtube"
        self._generateThumb(with: url){image in
            metadata.thumbnail = image
            task.metadata = metadata
            completion()
        }
    }
    
    // MARK: Private Methods
    private func _generateThumb(with url:URL,completion:@escaping (UIImage?)->Void){
        guard
            let comp = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let id = comp.paramators["v"]
        else {return}
        
        "http://i.ytimg.com/vi/\(id)/maxresdefault.jpg".request.setDataCompletion{data in
            if let image = UIImage(data: data), image.size.height > 300{
                completion(UIImage(data: data))
            }else{
                "http://i.ytimg.com/vi/\(id)/sddefault.jpg".request.setDataCompletion{data in
                    if let image = UIImage(data: data), image.size.height > 300{
                        completion(UIImage(data: data))
                    }else{completion(nil)}
                }.fire()
            }
        }.fire()
    }
    private func _generateAuthor(with html:HTML)->String?{
        return html.xPath("//span[@class=\"video-main-content-byline\"]/a")?.at(0)?.content
    }
    private func _generateTitle(with html:HTML)->String?{
        func form(_ title:String)->String{return re.sub("【.*?】", "", title)}
        var title = ""
        
        title = html.xPath("//h1/span/span")?.at(0)?.content ?? ""
        if !title.isEmpty{return form(title)}
        
        
        title = html.xPath("//h2[@class=\"video-main-content-title\"]")?.at(0)?.content ?? ""
        if !title.isEmpty{return form(title)}
        
        return ""
    }
}


