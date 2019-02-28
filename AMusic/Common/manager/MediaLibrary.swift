import Foundation
import MediaPlayer

class MediaLibrary{
    // MARK: - Properties
    static let `default` = MediaLibrary()
    
    // MARK: - Private Properties
    // MARK: - Caches
    private var _songs:[MediaItem] = []
    private var _artists:[ArtistInfo]? = nil
    private var _albums:[AlbumInfo]? = nil
    private var _genres:[GenreInfo]? = nil
    private var _composters:[ArtistInfo]? = nil
    private var _compilations:[AlbumInfo]? = nil
    private var _songIndexed:[String:[MediaItem]]? = nil
    // MARK: - Const
    private let kSongIndexes = [
        "あ","か","さ","た","な","は","ま","や","ら","わ","ん",
        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "#"
    ]
    
    //MARK: - API Methods
    
    func remove(_ song: MediaItem){
        _songs.remove(of: song)
        _reset()
        NotificationCenter.default.post(name: .ADMediaLibraryItemDidChange, object: nil)
    }
    func addItem(_ item:MediaItem){
        _songs.append(item)
        _reset()
        NotificationCenter.default.post(name: .ADMediaLibraryItemDidChange, object: nil)
    }
    
    /// Search specific type of items
    /// Don't use this method for preview. This method takes a long time to return results
    ///
    /// - Parameters:
    ///   - word: word for searching. Using a short word may often takes a long time to search
    ///   - type: look searchResultType.
    /// - Returns: array of struct `SearchResult` witch contains data of result.
    func search(with word:String,of type:SearchResultType)->[SearchResult]{
        switch type {
        case .artist: return _searchForArtist(with: word, max: Int.max)
        case .album: return _searchForAlbums(with: word, max: Int.max)
        case .song: return _searchForSongs(with: word, max: Int.max)
        default:
            return []
        }
    }
    
    /// Search all types of items. And returns asyncly limited number of items for a preview.
    ///
    /// - Parameters:
    ///   - word: word for searching.
    ///   - completion: Completion handler with an argument array of `SearchResultList`
    func searchForPreview(with word:String,completion:@escaping ([SearchResultList])->Void){
        DispatchQueue.global().async {
            let results = self._search(with: word)
            DispatchQueue.main.sync {completion(results)}
        }
    }
    
    /// Returns playlist. This result will not be cached.
    func getPlaylists()->[MPMediaPlaylist]{
        return (MPMediaQuery.playlists().collections ?? []) as? [MPMediaPlaylist] ?? []
    }
    
    /// Retuens songs. This result will be cached.
    func getSongs()->[MediaItem]{
        return _songs
    }
    
    /// Retuens songs. This result will be cached.
    func getSongIndex()->[String]{
        return kSongIndexes
    }
    func getIndexedSongList()->[MediaItem]{
        var songlists:[MediaItem] = []
        for index in getSongIndex(){
            songlists.append(contentsOf: getIndexedSongs()[index] ?? [])
        }
        return songlists
    }
    func getIndexedSongs()->[String:[MediaItem]]{
        if let songIndexed = _songIndexed{return songIndexed}
        self._songIndexed = _getIndexed()
        return self._songIndexed!
    }
    
    func getArtists()->[ArtistInfo]{//Artist
        if let artists = _artists{return artists}
        _artists = createArtist(songs: _songs)
        return _artists!
    }
    
    func getAlbums() -> [AlbumInfo] {//Album
        if let albums = _albums{return albums}
        _albums = createAlbums(songs: _songs)
        return _albums!
    }
    
    func getGenre() -> [GenreInfo] {//Genre
        if let genres = _genres{return genres}
        _genres = createGenres()
        return _genres!
    }
    func getComposers()->[ArtistInfo]{
        if let composters = _composters{return composters}
        _composters = createComposers()
        return _composters!
    }
    func getCompilations()->[AlbumInfo]{
        if let compilations = _compilations{return compilations}
        _compilations = createCompilations()
        return _compilations!
    }
    //========================================
    //Filtered
    func getAlbums(with ids:[Int])->[AlbumInfo]{
        return getAlbums().filter{ids.contains($0.id)}
    }
    func getAlbums(of artist:String)->[AlbumInfo]{
        return getArtists().filter{$0.name == artist}[0].albums
    }
    func getSingles(of albumIdentifier:String)->AlbumInfo{
        return getAlbums().filter{return $0.albumIdentifier == albumIdentifier}[0]
    }
    //======================================
    //p-api
    private func _search(with word:String)->[SearchResultList]{
        var results = [SearchResultList]()
        let lowercasedWord = word.lowercased()
        
        results.append(SearchResultList(items: _searchForArtist(with: lowercasedWord, max: 5), title: "アーティスト"))
        results.append(SearchResultList(items: _searchForAlbums(with: lowercasedWord, max: 5), title: "アルバム"))
        results.append(SearchResultList(items: _searchForSongs(with: lowercasedWord, max: 10), title: "曲"))
        
        
        return results.filter{!$0.items.isEmpty}
    }
    private func _searchForSongs(with word:String,max:Int)->[SearchResult]{
        var songs = [SearchResult]()
        for song in getSongs(){
            if song.title.lowercased().contains(word){
                let result = SearchResult(
                    type: .song,
                    title: song.title,
                    subtitle: song.helper.artist,
                    image: song.artwork?.image(at: CGSize(width: 55, height: 55)) ?? #imageLiteral(resourceName: "no_music"),
                    data: song
                )
                songs.append(result)
            }
            if songs.count >= max{break}
        }
        return songs
    }
    private func _searchForAlbums(with word:String,max:Int)->[SearchResult]{
        var albums = [SearchResult]()
        for album in getAlbums(){
            if album.albumTitle.lowercased().contains(word){
                let result = SearchResult(
                    type: .album,
                    title: album.albumTitle,
                    subtitle: "\(album.songs.count)曲",
                    image: album.representativeItem.artwork?.image(at: CGSize(width: 55, height: 55)),
                    data: album
                )
                albums.append(result)
            }
            if albums.count >= max{break}
        }
        return albums
    }
    private func _searchForArtist(with word:String,max:Int)->[SearchResult]{
        var artists = [SearchResult]()
        for artist in getArtists(){
            if artist.name.lowercased().contains(word){
                let result = SearchResult(
                    type: .artist,
                    title: artist.name,
                    subtitle: "\(artist.albums.count)枚のアルバム",
                    image: artist.representativeItem.artwork?.image(at: CGSize(width: 55, height: 55)),
                    data: artist
                )
                artists.append(result)
            }
            if artists.count >= max{break}
        }
        return artists
    }
    private func _getIndexed()->[String:[MediaItem]]{
        var results = [String:[MediaItem]]()
        let songIndex = getSongIndex()
        for word in songIndex{results[word] = []}
        for song in _songs{
            guard let title = song.title.first else {break}
            var firstChar = (String(title)).uppercased().applyingTransform(.hiraganaToKatakana, reverse: true)?.getGyou() ?? ""
            if !songIndex.contains(firstChar) && !NSPredicate(format: "SELF MATCHES %@", "^[ぁ-ゞ]+$").evaluate(with: firstChar){
                firstChar = "#"
            }
            results[firstChar]?.append(song)
        }
        return results
    }
    private func createComposers()->[ArtistInfo]{
        return MPMediaQuery.composers().collections!.map{
            ArtistInfo(name: $0.representativeItem?.composer ?? "unknown",albums:createAlbums(songs: $0.items.map{MediaItem(entity: $0)}))
        }
    }
    private func createCompilations()->[AlbumInfo]{
        return MPMediaQuery.compilations().collections!.map{AlbumInfo(songs: $0.items.map{MediaItem(entity: $0)})}
    }
    private func createGenres()->[GenreInfo]{
        return MPMediaQuery.genres().collections!.map{
            GenreInfo(name: $0.representativeItem?.genre ?? "unknown", artist: createArtist(songs: $0.items.map{MediaItem(entity: $0)}))
        }
    }
    private func createAlbums(songs:[MediaItem])->[AlbumInfo]{
        var albums = [String:[MediaItem]]()
        for song in songs{
            if albums[song.albumIdentifier] == nil {albums[song.albumIdentifier] = []}
            albums[song.albumIdentifier]!.append(song)
        }
        return albums.map{AlbumInfo(songs: $1)}.sorted{$0.albumTitle.lowercased() < $1.albumTitle.lowercased()}
    }
    private func createArtist(songs:[MediaItem])->[ArtistInfo]{
        var artistRawInfo:[String:[MediaItem]] = [:]
        for song in songs{
            let name = song.artistName
            if artistRawInfo[name] == nil{artistRawInfo[name] = []}
            artistRawInfo[name]?.append(song)
        }
        var artistInfo:[String:[AlbumInfo]] = [:]
        for (k,v) in artistRawInfo{
            artistInfo[k] = createAlbums(songs: v)
        }
        return artistInfo.map{ArtistInfo(name: $0, albums: $1)}.sorted {
            $0.name.lowercased().localizedStandardCompare($1.name.lowercased()) == .orderedAscending
        }
    }
    private func _reset(){
        _artists = nil
        _albums = nil
        _songIndexed = nil
        DispatchQueue.global().async {
            _=self.getIndexedSongs()
        }
    }
    @discardableResult
    func initialize()->Bool {
        let currentState = MPMediaLibrary.authorizationStatus()
        if currentState == .notDetermined || currentState == .denied || currentState == .restricted{
            MPMediaLibrary.requestAuthorization{state in
                
            }
            return false
        }
        if !_songs.isEmpty{return true}
        
        //iPhone Music Library
        self._songs = (MPMediaQuery.songs().items ?? []).map{MediaItem(entity: $0)}.filter{$0.assetURL != nil}
        //Local Music Library
        self._songs.append(contentsOf: ADMediaLibrary.default.songs.map{MediaItem(entity: $0)})
        
        return true
    }
    struct SearchResultList {
        var items:[SearchResult]
        var title:String
    }
    enum SearchResultType {case artist,album,song,playlist}
    struct SearchResult {
        var type:SearchResultType
        var title:String
        var subtitle:String
        var image:UIImage?
        var data:Any
    }
}

fileprivate extension String{
    func getGyou()->String?{
        guard let c = self.unicodeScalars.first?.value else {return nil}
        if c >= 0x3041 && c <= 0x304A {
            return "あ"
        } else if c >= 0x304B && c <= 0x3054 {
            return "か"
        } else if c >= 0x3055 && c <= 0x305E {
            return "さ"
        } else if c >= 0x305F && c <= 0x3069 {
            return "た"
        } else if c >= 0x306A && c <= 0x306E {
            return "な"
        } else if c >= 0x306F && c <= 0x307D {
            return "は"
        } else if c >= 0x307E && c <= 0x3082 {
            return "ま"
        } else if c >= 0x3083 && c <= 0x3088 {
            return "や"
        } else if c >= 0x3089 && c <= 0x308D {
            return "ら"
        } else if c >= 0x308F && c <= 0x3093 {
            return "わ"
        }else{
            return self
        }
    }
}
