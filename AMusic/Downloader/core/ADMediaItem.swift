import UIKit
import MediaPlayer

// TODO: - AlbumIDあたりを直す。


class ADMediaItem{
    // MARK: Non optional
    let id:Int
    let playbackDuration: TimeInterval
    let albumTrackNumber: Int
    let albumTrackCount: Int
    
    // MARK: Asset type
    var assetURL: URL?
    var coverURL: URL?
    
    // MARK: Optional
    let title:String?
    let albumTitle: String?
    let artist: String?
    let albumArtist: String?
    let genre: String?
    let composer: String?
    let lyrics: String?
    let releaseDate: Date?
    let addedDate: Date?
    
    init(metadata: ADMetadata,id: Int, assetURL: URL, coverURL: URL?, duration: TimeInterval) {
        self.id = id
        self.playbackDuration = duration
        self.assetURL = assetURL
        self.coverURL = coverURL
        
        self.title = metadata.title
        self.albumTitle = metadata.albumTitle
        self.artist = metadata.artist
        self.albumArtist = metadata.albumArtist
        self.genre = metadata.genre
        self.composer = metadata.composer
        self.albumTrackNumber = metadata.albumTrackNumber ?? 0
        self.albumTrackCount = metadata.albumTrackCount ?? 0
        self.lyrics = metadata.lyrics
        self.releaseDate = metadata.releaseDate
        self.addedDate = metadata.addedDate
    }
    init(dict:[String:Any?]) {
        self.id = dict["id"] as? Int ?? 0
        self.playbackDuration = dict["playbackDuration"] as? TimeInterval ?? 0
        self.albumTrackNumber = dict["albumTrackNumber"] as? Int ?? 0
        self.albumTrackCount = dict["albumTrackCount"] as? Int ?? 0
        
        guard let assetURL = (dict["assetURL"] as? String)?.fileUrl else {fatalError()}
        
        self.assetURL = assetURL
        self.coverURL = (dict["coverURL"] as? String)?.fileUrl
        
        self.title = dict["title"] as? String
        self.albumTitle = dict["albumTitle"]  as? String
        self.artist = dict["artist"] as? String
        self.albumArtist = dict["albumArtist"] as? String
        self.genre = dict["genre"] as? String
        self.composer = dict["composer"] as? String
        self.lyrics = dict["lyrics"] as? String
        self.releaseDate = _stringToDate(dict["releaseDate"] as? String)
        self.addedDate = _stringToDate(dict["addedDate"] as? String)
    }
    var dict:[String:Any?]{
        return [
            "id":id,
            "title":title,
            "albumTitle": albumTitle,
            "artist": artist,
            "albumArtist": albumArtist,
            "genre": genre,
            "composer": composer,
            "playbackDuration": playbackDuration,
            "albumTrackNumber": albumTrackNumber,
            "albumTrackCount": albumTrackCount,
            "lyrics": lyrics,
            "releaseDate": _dateToString(releaseDate),
            "assetURL": assetURL?.path,
            "coverURL": coverURL?.path,
            "addedDate": _dateToString(addedDate)
            
        ]
    }
}

extension ADMediaItem: Equatable{
    public static func == (lhs: ADMediaItem, rhs: ADMediaItem) -> Bool{
        return lhs.id == rhs.id 
    }
}

extension ADMediaItem: MediaEntityType{
    var isLocal: Bool {
        return true
    }
    
    var albumId: Int {
        return 0
    }
    
    var artistId: Int {
        return 0
    }
    
    var albumArtistId: Int {
        return 0
    }
    
    var discNumber: Int {return 0}
    var discCount: Int {return 0}
    
    var artwork: MPMediaItemArtwork? {
        guard
            let coverUrl = coverURL,
            let data = FileManager.default.contents(atPath: coverUrl.path),
            let image = UIImage(data: data)
            else {return nil}
        
        return MPMediaItemArtwork(boundsSize: image.size){size in image.resized(toFit: size)}
    }
}

// MARK: Private Functions
private var _cFormatter:DateFormatter{
    let f = DateFormatter()
    f.dateStyle = .full
    return f
}

private func _stringToDate(_ string:String?)->Date?{
    guard let string = string else {return nil}
    return _cFormatter.date(from: string)
}
private func _dateToString(_ date:Date?)->String{
    guard let date = date else {return ""}
    return _cFormatter.string(from: date)
}















