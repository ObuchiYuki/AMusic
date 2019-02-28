import Foundation
import MediaPlayer

class MediaItem{
    var entity:MediaEntityType
    
    init(entity:MediaEntityType) {
        self.entity = entity
    }
    //============================================================================================================
    //api
    lazy var isLocal:Bool = {return entity.isLocal}()
    
    lazy var id:Int = {return entity.id}()
    lazy var title:String = {return entity.title ?? "不明なタイトル"}()
    lazy var albumTitle: String = {return entity.albumTitle ?? "不明なアルバム"}()
    lazy var artist: String = {return entity.artist ?? "不明なアーティスト"}()
    lazy var genre: String = {return entity.genre ?? "不明なジャンル"}()
    lazy var composer: String = {return entity.composer ?? "不明な作曲者"}()
    
    lazy var artistName:String = {
        if albumArtist != nil {return albumArtist!}
        return artist
    }()
    lazy var albumIdentifier:String = {
        return "\(artistName)-\(albumTitle)"
    }()
    
    lazy var albumArtist: String? = {return entity.albumArtist}()
    lazy var playbackDuration: TimeInterval = {return entity.playbackDuration}()
    lazy var albumTrackNumber: Int = {return entity.albumTrackNumber}()
    lazy var albumTrackCount: Int = {return entity.albumTrackCount}()
    var discNumber: Int{return entity.discNumber}
    var discCount: Int{return entity.discCount}
    var artwork: MPMediaItemArtwork?{return entity.artwork}
    var lyrics: String?{return entity.lyrics}
    var releaseDate: Date?{return entity.releaseDate}
    var assetURL: URL?{return entity.assetURL}
    
    var albumId:Int{return entity.albumId}
    var artistId:Int{return entity.artistId}
    var albumArtistId:Int{return entity.albumArtistId}
}


extension MediaItem: Equatable{
    public static func == (lhs: MediaItem, rhs: MediaItem) -> Bool{
        return lhs.id == rhs.id
    }
}


extension MediaItem: Hashable{
    public var hashValue: Int {
        return self.id
    }
}

extension MediaItem: CustomStringConvertible{
    var description: String{
        return "\(title) by \(artist)"
    }
}








