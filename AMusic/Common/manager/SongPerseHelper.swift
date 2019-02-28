import MediaPlayer

class SongPerseHelper {
    //=======================================================================================
    //props
    var song:MediaItem
    //======================================
    //api
    var artist:String{
        if song.entity.artist == nil{
            return song.albumArtist ?? "不明なアーティスト"
        }else{
            return song.artist
        }
    }
    var albumArtist: String{
        if song.albumArtist == nil{
            return song.artist
        }else{
            return song.albumArtist!
        }
    }
    var duration:Float {
        let value = Float(song.playbackDuration)
        return value.isNaN ? 0 : value
    }
    //======================================
    //private
    private var id:Int{return song.id}
    //=======================================================================================
    //funcs
    //======================================
    //api
    func durationString()->String{
        return createDurationString(duration: self.duration)
    }
    func pastDurationString(current:TimeInterval)->String{
        let current = current.isNaN ? 0 : Float(current)
        return createDurationString(duration: current)
    }
    func lastDurationString(current:TimeInterval)->String{
        let lastTime = duration-(current.isNaN ? 0 : Float(current))
        return "-"+createDurationString(duration: lastTime)
    }
    func getArtwork(
        for size: CGSize,
        cornerRadius: CGFloat = 0, shadowed: Bool = false ,bordered:Bool = false
    )->UIImage{
        let key = "\(id)-\(size)-\(shadowed)-\(cornerRadius)"
        
        if let image = _ArtworkHelper.default.getArtwork(for: key) {
            return image
        }
        
        let artwork = self.song.artwork
        var image = (artwork?.image(at: size) ?? #imageLiteral(resourceName: "no_music").resized(toFit: size))
        if shadowed || cornerRadius != 0 || bordered{
            let editableImage = image.editable(for: size)
            if shadowed {
                _=editableImage
                    .setPadding(5)
                    .setShadow(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1).a(0.7), radius: 5, offset: [0, 3], opacity: 1)
            }
            if cornerRadius != 0{
                _=editableImage
                    .setCorner(cornerRadius)
            }
            if bordered{
                _=editableImage
                    .setBorder(ColorPalette.current.separationColor, width: 0.5)
            }
            image = editableImage.rendered()
        }
        _ArtworkHelper.default.setArtwork(for: key, image)
        return image
    }
    func loadCollectionArtiwork(_ completion: @escaping (UIImage)->Void){
        loadArtwork(with: CellLayoutProvider.default.imageSize,cornerRadius: 20, shadowed: true, bordered: false, completion)
    }
    func loadArtwork(
        with size: CGSize,
        cornerRadius: CGFloat = 0, shadowed: Bool = false ,bordered:Bool = false,
        _ completion: @escaping (UIImage)->Void
    ){
        let key = "\(id)-\(size)-\(shadowed)-\(cornerRadius)"
        
        if let image = _ArtworkHelper.default.getArtwork(for: key) {
            completion(image)
            return
        }
        DispatchQueue.global().async {
            let artwork = self.song.artwork
            var image = (artwork?.image(at: size) ?? #imageLiteral(resourceName: "no_music").resized(toFit: size))
            if shadowed || cornerRadius != 0 || bordered{
                let editableImage = image.editable(for: size)
                if shadowed {
                    _=editableImage
                    .setPadding(5)
                    .setShadow(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1).a(0.7), radius: 5, offset: [0, 3], opacity: 1)
                }
                if cornerRadius != 0{
                    _=editableImage
                    .setCorner(cornerRadius)
                }
                if bordered{
                    _=editableImage
                    .setBorder(ColorPalette.current.separationColor, width: 0.5)
                }
                image = editableImage.rendered()
            }
            DispatchQueue.main.sync{
                completion(image)
                _ArtworkHelper.default.setArtwork(for: key, image)
            }
        }
    }
    //======================================
    //private
    private func createDurationString(duration:Float)->String{
        let sec = Int(duration)/60
        let min = NSString(format: "%02d", Int(duration)%60)
        return "\(sec):\(min)"
    }
    
    init(song:MediaItem) {self.song = song}
}

extension MediaItem{
    var helper:SongPerseHelper{
        return SongPerseHelper(song: self)
    }
}


/// _ArtworkHelper
/// Cache Images. アートワークをキャッシュしておく、MaxCacheCount以上で最初から捨てていく
/// スレッドセーフでない!
private class _ArtworkHelper {
    // MARK: - Singlton
    static let `default` = _ArtworkHelper()
    
    // MARK: - Properties
    private var artworkKeys = [String]()
    private var artworkImages = [UIImage]()
    
    // MARK: - Const
    private let kMaxCacheCount = 400
    
    // MARK: - APIs
    func getArtwork(for key:String)->UIImage?{
        guard let index = artworkKeys.index(of: key) else {return nil}
        self._chackMaxCount()
        return artworkImages.at(index)
    }
    func setArtwork(for key:String,_ image:UIImage){
        artworkKeys.insert(key, at: 0)
        artworkImages.insert(image, at: 0)
    }
    
    // MARK: - Private Mathods
    private func _chackMaxCount(){
        if artworkKeys.count > kMaxCacheCount{
            artworkKeys.removeLast(100)
            artworkImages.removeLast(100)
        }
    }
}














