import UIKit

/// ADMetadata
/// Metadata for Downloaed Contents.
class ADMetadata{
    
    // MARK: Forced
    var title:String?
    var artist:String?
    var albumTrackNumber:Int?
    var albumTrackCount:Int?
    var thumbnail:UIImage?
    var albumTitle:String?
    var albumArtist:String?
    var genre:String?
    var composer:String?
    var lyrics:String?
    var releaseDate:Date?
    
    // MARK: Automaic
    var addedDate:Date
    
    // MARK: Init
    init(
        title:String? = nil,
        artist:String? = nil,
        albumTrackNumber:Int? = nil,
        albumTrackCount:Int? = nil,
        thumbnail:UIImage? = nil,
        albumTitle:String? = nil,
        albumArtist:String? = nil,
        genre:String? = nil,
        composer:String? = nil,
        lyrics:String? = nil,
        releaseDate:Date? = nil
    ){
        self.title = title
        self.artist = artist
        self.albumTrackNumber = albumTrackNumber
        self.albumTrackCount = albumTrackCount
        self.thumbnail = thumbnail
        self.albumTitle = albumTitle
        self.albumArtist = albumArtist
        self.genre = genre
        self.composer = composer
        self.lyrics = lyrics
        self.releaseDate = releaseDate
        
        self.addedDate = Date()
    }
}

















