import UIKit
import MediaPlayer

class PlaylistEditingManager{
    static let `default` = PlaylistEditingManager()
    
    var contentToAdd:[MediaItem] = []
    var isEditing = false
    
    private var completion:(([MediaItem])->Void)? = nil
    private var vc:UIViewController?
    
    func hasAlbum(_ album:AlbumInfo)->Bool{
        let listSet = Set(contentToAdd)
        let findListSet = Set(album.songs)
        
        return findListSet.isSubset(of: listSet)
    }
    func endEditing(){
        vc?.dismiss(animated: true)
        isEditing = false
        completion?(contentToAdd)
        self.contentToAdd = []
        completion = nil
    }
    func startEditing(completion:@escaping ([MediaItem])->Void){
        self.completion = completion
        isEditing = true
        vc = UIStoryboard.main.instantiateInitialViewController()!
        UIWindow.main.rootViewController?.present(vc!, animated: true)
    }
}
