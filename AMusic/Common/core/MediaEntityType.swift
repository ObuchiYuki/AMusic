import Foundation
import MediaPlayer

protocol MediaEntityType {
    var id:Int { get }
    var albumId:Int { get }
    var artistId:Int { get }
    var albumArtistId:Int { get }
    var title:String? { get }
    var albumTitle: String? { get }
    var artist: String? { get }
    var albumArtist: String? { get }
    var genre: String? { get }
    var composer: String? { get }
    var playbackDuration: TimeInterval { get }
    var albumTrackNumber: Int { get }
    var albumTrackCount: Int { get }
    var discNumber: Int { get }
    var discCount: Int { get }
    var artwork: MPMediaItemArtwork? { get }
    var lyrics: String? { get }
    var releaseDate: Date? { get }
    var assetURL: URL? { get }
    var addedDate: Date? { get }
    
    var isLocal:Bool { get }
}

extension MPMediaItem:MediaEntityType{
    var artistId: Int {
        return Int(exactly: artistPersistentID) ?? -Int(UInt(artistPersistentID)-UInt(Int.max))
    }
    var albumArtistId: Int {
        return Int(exactly: albumArtistPersistentID) ?? -Int(UInt(albumArtistPersistentID)-UInt(Int.max))
    }
    var albumId: Int{
        return Int(exactly: albumPersistentID) ?? -Int(UInt(albumPersistentID)-UInt(Int.max))
    }
    var id:Int{
        return Int(exactly: persistentID) ?? -Int(UInt(persistentID)-UInt(Int.max))
    }
    var addedDate: Date? {
        return self.dateAdded
    }
    var isLocal: Bool{
        return false
    }
}











