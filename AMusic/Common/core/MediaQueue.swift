import Foundation

class MediaQueue{
    func allArtist()->AMQueueProvider<ArtistInfo> {
        return AMQueueProvider(initialValue: MediaLibrary.default.getArtists()){
            return MediaLibrary.default.getArtists()
        }
    }
    func allAlbums()->AMQueueProvider<AlbumInfo>{
        return AMQueueProvider(initialValue: MediaLibrary.default.getAlbums()){
            return MediaLibrary.default.getAlbums()
        }
    }
    func allSongs()->AMQueueProvider<MediaItem>{
        return AMQueueProvider(initialValue: MediaLibrary.default.getSongs()){
            return MediaLibrary.default.getSongs()
        }
    }
    func allGenres()->AMQueueProvider<GenreInfo>{
        return AMQueueProvider(initialValue: MediaLibrary.default.getGenre()){
            return MediaLibrary.default.getGenre()
        }
    }
    func allComporser()->AMQueueProvider<ArtistInfo>{
        return AMQueueProvider(initialValue: MediaLibrary.default.getComposers()){
            return MediaLibrary.default.getComposers()
        }
    }
    func singlesQueue(with albumIds:[Int],initialValue:[AlbumInfo])->AMQueueProvider<AlbumInfo>{
        return AMQueueProvider(initialValue: initialValue){
            return MediaLibrary.default.getAlbums(with: albumIds)
        }
    }
    func albumsQueue(for artistId:Int, initialValue:[AlbumInfo]){
        
    }
    func comporserQueue(with comporserName:String, initialValue:[AlbumInfo]){
        
    }
    func genreQueue(with genreName:String, initialValue:[AlbumInfo]){
        
    }
}
class AMQueueProvider<MediaType> {
    private var _reloadHandler = {}
    private var _computeHandler:(()->[MediaType])
    private var _initialValue:[MediaType]
    private var _currentValue:[MediaType]?
    
    func setReloadHandler(_ block: @escaping ()->Void ){
        
    }
    func getValues()->[MediaType]{
        return []
    }
    
    init(initialValue:[MediaType],computeHandler: @escaping ()->[MediaType]) {
        self._computeHandler = computeHandler
        self._initialValue = initialValue
    }
}











