import UIKit

class ArtistViewController: AMCollectionViewController {
    var artists:[ArtistInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if artists.isEmpty{
            self.artists = MediaLibrary.default.getArtists()
            self.collectionView?.reloadData()
        }
    }
    override func reloadAll() {
        self.artists = MediaLibrary.default.getArtists()
        self.collectionView?.reloadData()
    }
    override func didHeaderShuffleButtonPush() {
        let items = artists.flatMap{$0.albums}.flatMap{$0.songs}
        NowPlayingViewController.show().startMusicRandomly(list: items)
    }
    override func didHeaderPlayButtonPush() {
        let items = artists.flatMap{$0.albums}.flatMap{$0.songs}
        NowPlayingViewController.show().startMusic(list: items, start: items[0])
    }
    override func didSelect(itemAt indexPath: IndexPath) {
        if artists[indexPath.row].albums.count == 1{
            self.safePerformSegue(withIdentifier: "toSingles", sender: indexPath)
        }else{
            super.didSelect(itemAt: indexPath)
        }
    }
    override func willMove(to destination: UIViewController, with indexPath: IndexPath) {
        if let vc = destination as? AlbumViewController{
            let artist = artists[indexPath.row]
            vc.albums = artist.albums
            vc.title = artist.name
        }else if let vc = destination as? SingleListViewController{
            let artist = artists[indexPath.row]
            vc.albums = [artist.albums[0]]
            vc.title = artist.name
        }
    }
    override func collectionView(_ model: AMLongPressViewModel, willShowLongPressViewFor indexPath: IndexPath) -> AMLongPressViewModel? {
        let artist = artists[indexPath.row]
        
        model.title = artist.name
        model.description = "\(artist.albums.count)枚のアルバム"
        model.image = artist.representativeItem.helper.getArtwork(for: [100, 100], cornerRadius: 20, shadowed: true)
        
        model.addAction(title: "全曲シャッフル", image: #imageLiteral(resourceName: "shuffle_disable")){
            NowPlayingViewController.show().startMusicRandomly(list: artist.albums.flatMap{$0.songs})
        }
        
        return model
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getAlbumCell(at: indexPath)
        let artist = artists[indexPath.row]
        cell.title = artist.name
        cell.subtitle = artist.albums.count.description + "枚のアルバム"
        
        artist.representativeItem.helper.loadCollectionArtiwork{
            if cell.indexPath == indexPath{
                cell.cover = $0
            }
        }
        return cell
    }
}
