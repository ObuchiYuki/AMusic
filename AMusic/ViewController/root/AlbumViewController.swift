import UIKit

class AlbumViewController: AMCollectionViewController {
    var albums:[AlbumInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if albums.isEmpty{
            self.albums = MediaLibrary.default.getAlbums()
            self.collectionView?.reloadData()
        }
    }
    override func reloadAll() {
        self.albums = MediaLibrary.default.getAlbums()
        self.collectionView?.reloadData()
    }
    override func willMove(to destination: UIViewController, with indexPath: IndexPath) {
        if let vc = destination as? SingleListViewController{
            vc.albums = [self.albums[indexPath.row]]
        }
    }
    override func didHeaderPlayButtonPush() {
        let items = self.albums.flatMap{$0.songs}
        NowPlayingViewController.show().startMusic(list: items, start: items[0])
    }
    override func didHeaderShuffleButtonPush() {
        let items = self.albums.flatMap{$0.songs}
        NowPlayingViewController.show().startMusicRandomly(list: items)
    }
    override func collectionView(_ model: AMLongPressViewModel, willShowLongPressViewFor indexPath: IndexPath) -> AMLongPressViewModel? {
        let album = albums[indexPath.row]
        
        model.title = album.albumTitle
        model.description = "\(album.songs.count)曲"
        model.image = album.representativeItem.helper.getArtwork(for: [100, 100], cornerRadius: 20, shadowed: true)
        model.addAction(title: "全曲シャッフル", image: #imageLiteral(resourceName: "shuffle_disable")){
            NowPlayingViewController.show().startMusicRandomly(list: album.songs)
        }
        
        return model
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getAlbumCell(at: indexPath)
        let album = albums[indexPath.row]
        
        cell.title = album.albumTitle
        cell.subtitle = "\(album.count)曲"
        
        album.representativeItem.helper.loadCollectionArtiwork{
            if cell.indexPath == indexPath{
                cell.cover = $0
            }
        }
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}



