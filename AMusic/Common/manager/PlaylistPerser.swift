import Foundation
import MediaPlayer

extension Notification.Name{
    static let AMPPSynchronizeEndNotification = Notification.Name("synchronizeEndNotification")
}

class PlaylistPerser{
    var count:Int{return items.count}
    
    private var playlist:MPMediaPlaylist
    var items:[MediaItem]
    var name:String
    var description:String
    
    var coverImage:UIImage?{
        return playlist.representativeItem?.artwork?.image(at: CGSize(width: 500, height: 500))
    }
    
    init(with playlist:MPMediaPlaylist) {
        self.playlist = playlist
        self.items = playlist.items.map{MediaItem(entity: $0)}
        self.name = playlist.name ?? ""
        self.description = playlist.descriptionText ?? ""
    }
    
    func addCollection(_ collection:[MediaItem]){items.append(contentsOf: collection)}
    func add(_ item:MediaItem){items.append(item)}
    func insert(_ item:MediaItem,at index:Int){items.insert(item, at: index)}
    func move(from fromIndex:Int,to toIndex:Int){items.insert(items.remove(at: fromIndex), at: toIndex)}
    func remove(at index:Int){self.items.remove(at: index)}
    
    func removeFromLibrary(){
        let selectorRemovePlaylist = NSSelectorFromString("removePlaylist:")
        MPMediaLibrary.default().perform(selectorRemovePlaylist, with: playlist)
    }
    
    func synchronize(){
        DispatchQueue.global().async {
            self.removeFromLibrary()
            PlaylistPerser.createNewPlaylist(with: self.name, description: self.description,items: self.items){playlist in
                self.playlist = playlist
                NotificationCenter.default.post(name: .AMPPSynchronizeEndNotification, object: nil)
            }
        }
    }
    
    static func createNewPlaylist(with name:String,description:String,items:[MediaItem],completion:@escaping (MPMediaPlaylist)->Void){
        let metadata = MPMediaPlaylistCreationMetadata(name: name)
        metadata.authorDisplayName = " "
        metadata.descriptionText = description
        MPMediaLibrary.default().getPlaylist(with: UUID(),creationMetadata: metadata){playlist,_ in
            if let playlist = playlist{
                playlist.add(items.compactMap{$0.entity as? MPMediaItem}){_ in DispatchQueue.main.sync {completion(playlist)}}
            }
        }
    }
}

extension MPMediaPlaylist{
    var perser:PlaylistPerser{return PlaylistPerser(with: self)}
}
