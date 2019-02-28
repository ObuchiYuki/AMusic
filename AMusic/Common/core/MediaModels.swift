import MediaPlayer

struct AlbumInfo {
    init(songs:[MediaItem],useRawOrder:Bool = false){
        self._songs = songs
        self.count = songs.count
        self.useRawOrder = useRawOrder
    }
    var albumIdentifier:String{
        return songs[0].albumIdentifier
    }
    private var _songs: [MediaItem]
    private var useRawOrder:Bool
    lazy var diskedSongs:[[MediaItem]] = {
        let diskMap = songs.map{$0.discNumber}.unique
        var result:[[MediaItem]] = []
        
        for song in songs{
            let index = diskMap.index(of: song.discNumber) ?? 0
            if result.at(index) == nil {result.append([])}
            result[index].append(song)
        }
        return result
    }()
    var songs: [MediaItem]{
        if useRawOrder{
            return _songs
        }
        return _songs.sorted{a,b in
            a.discNumber*10000+a.albumTrackNumber<b.discNumber*10000+b.albumTrackNumber
        }
    }
    var albumTitle:String{return _songs.first?.albumTitle ?? ""}
    var count:Int
    var id:Int{return representativeItem.albumId}
    
    var representativeItem:MediaItem{
        return self._songs.first!
    }
}
struct ArtistInfo{
    var name:String
    var albums:[AlbumInfo]
    var representativeItem:MediaItem{
        return (albums.first?.songs.first)!
    }
}
struct GenreInfo {
    var name:String
    var artist:[ArtistInfo]
    var representativeItem:MediaItem{
        return artist.first!.representativeItem
    }
}






