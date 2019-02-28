import AVFoundation
import UIKit

class ADMediaLibrary {
    //================================================================================================
    //api
    static let `default` = ADMediaLibrary()
    private(set) var songs:[ADMediaItem] = []
    //===============================================
    //private
    private let kItemListSaveKey = "ADMediaLibraryItemListSaveKey"
    private let kNameOfValue = "value.m4a"
    private let kNameOfCover = "cover.png"
    //================================================================================================
    //api
    func changeMetadata(for item:ADMediaItem,with metadata:ADMetadata){
        
        
        MediaLibrary.default.remove(MediaItem(entity: item))
        
        let newItem = ADMediaItem(metadata: metadata, id: item.id, assetURL: item.assetURL!, coverURL: item.coverURL, duration: item.playbackDuration)
        
        self.addItem(item: newItem)
    }
    func getSongListAsDict()-> [[String:Any]]{
        return UserDefaults.standard.array(forKey: kItemListSaveKey) as? [[String:Any]] ?? []
    }
    func removeItem(with item:ADMediaItem){
        self._removeItemList(item)
        self._removeItemFiles(item)
        MediaLibrary.default.remove(MediaItem(entity: item))
        MediaPlayer.default.stop()
    }
    func createItem(with metadata:ADMetadata, data:Data,_ completion:@escaping (ADMediaItem?)->Void){
        let id = self._getRandomId()
        let saveDir = self._getForSave(id: id)
        let tmpfilePath = saveDir.appending(path: "_value.m4a")
        let filePath = saveDir.appending(path: kNameOfValue)
        let imagePath = saveDir.appending(path: kNameOfCover)
        
        do{
            try FileManager.default.createDirectory(atPath: saveDir, withIntermediateDirectories: false)
            
            FileManager.default.createFile(atPath: tmpfilePath, contents: data)
            
            let asset = AVURLAsset(url: URL(fileURLWithPath: tmpfilePath), options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
            let audio = asset.tracks.filter{$0.mediaType == AVMediaType.audio}

            guard let audioAsset = audio.first?.asset else {completion(nil);return}
            let duration = CMTimeGetSeconds(audioAsset.duration)
            guard let exportSession = AVAssetExportSession(asset: audioAsset, presetName: AVAssetExportPresetPassthrough)
                else {completion(nil);return}
            exportSession.outputFileType = AVFileType.m4a
            exportSession.outputURL = filePath.fileUrl
            exportSession.exportAsynchronously {
                try? FileManager.default.removeItem(at: tmpfilePath.fileUrl)
                var imageUrl:URL? = nil
                if let image = metadata.thumbnail, let imageData = UIImagePNGRepresentation(image){
                    FileManager.default.createFile(atPath: imagePath, contents:imageData)
                    imageUrl = URL(fileURLWithPath: imagePath)
                }
                let item = ADMediaItem(metadata: metadata,id: id, assetURL: URL(fileURLWithPath: filePath), coverURL: imageUrl,duration:duration)
                completion(item)
            }
        }catch{
            NotificationManager.default.post(error.localizedDescription)
            completion(nil)
        }
    }
    func addItem(item: ADMediaItem){
        self.songs.append(item)
        self._saveItemList(item: item)
        let wrapper = MediaItem(entity: item)
        MediaLibrary.default.addItem(wrapper)
    }
    //===============================================
    //private
    private func _getRandomId()->Int{
        var id = Int(arc4random_uniform(UInt32.max))
        while self.songs.map({$0.id}).contains(id) {
            id = Int(arc4random_uniform(UInt32.max))
        }
        return id
    }
    private func _loadItemList()->[ADMediaItem]{
        return UserDefaults.standard.array(forKey: kItemListSaveKey)?
            .compactMap{$0 as? [String: Any?]}
            .map{$0.mapValues{($0 as? String ?? "") == "nil" ? nil : $0}}
            .map{ADMediaItem(dict:$0)}
            .map{_adjustAssetUrl($0)} ?? []
    }
    private func _encodeSongItem(_ item: ADMediaItem)->[String:Any]{
        return item.dict.mapValues{$0 == nil ? "nil" : $0!}
    }
    private func _saveItemList(item:ADMediaItem){
        var songlist = getSongListAsDict()
        songlist.append(_encodeSongItem(item))
        UserDefaults.standard.set(songlist, forKey: kItemListSaveKey)
    }
    private func _removeItemList(_ item:ADMediaItem){
        let songlist = self._loadItemList().filter{$0.id != item.id}.map(_encodeSongItem)
        UserDefaults.standard.set(songlist, forKey: kItemListSaveKey)
    }
    private func _removeItemFiles(_ item:ADMediaItem){
        let path = ADMediaLibrary.docDir.appending(path: item.id.description)
        
        do{
            try FileManager.default.removeItem(atPath: path)
        }catch{
            NotificationManager.default.post(error.localizedDescription)
        }
    }
    private func _getForSave(id:Int)->String{
        return ADMediaLibrary.docDir.appending(path: String(id))
    }
    private func _adjustAssetUrl(_ item:ADMediaItem)->ADMediaItem{
        item.assetURL = _getForSave(id: item.id).appending(path: kNameOfValue).fileUrl
        item.coverURL = _getForSave(id: item.id).appending(path: kNameOfCover).fileUrl
        
        return item
    }
    private func _createDir(){
        let path = ADMediaLibrary.docDir
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path, isDirectory: nil){
            do{
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
            }catch{
                NotificationManager.default.post(error.localizedDescription)
            }
        }
    }
    private func removeAll(){// MARK: For debug.
        UserDefaults.standard.set([], forKey: kItemListSaveKey)
        do{
            try FileManager.default.removeItem(atPath: ADMediaLibrary.docDir)
        }catch{
            NotificationManager.default.post(error.localizedDescription)
        }
    }
    func _filterItems(songs:[ADMediaItem])->[ADMediaItem]{
        let ids = (try? FileManager.default.contentsOfDirectory(atPath: ADMediaLibrary.docDir))?.compactMap{Int($0)} ?? []
        return songs.filter{ids.contains($0.id)}
    }
    init() {
        self._createDir()
        self.songs = _filterItems(songs: _loadItemList())
    }
    static var docDir:String{
        return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "").appending(path: "audio")
    }
}

extension Notification.Name{
    static let ADMediaLibraryItemDidChange = Notification.Name("ADMediaLibraryItemDidChange")
}
