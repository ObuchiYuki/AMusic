import UIKit

class GenreViewController: AMCollectionViewController {
    var genres:[GenreInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.genres = MediaLibrary.default.getGenre()
        self.collectionView?.reloadData()
    }
    override func didHeaderShuffleButtonPush() {
        let items = genres.flatMap{$0.artist}.flatMap{$0.albums}.flatMap{$0.songs}
        NowPlayingViewController.show().startMusicRandomly(list: items)
    }
    override func didHeaderPlayButtonPush() {
        let items = genres.flatMap{$0.artist}.flatMap{$0.albums}.flatMap{$0.songs}
        NowPlayingViewController.show().startMusic(list: items, start: items[0])
    }
    override func willMove(to destination: UIViewController, with indexPath: IndexPath) {
        if let vc = destination as? ArtistViewController{
            let genre = genres[indexPath.row]
            vc.artists = genre.artist
            vc.title = genre.name
        }
    }
    override func collectionView(_ model: AMLongPressViewModel, willShowLongPressViewFor indexPath: IndexPath) -> AMLongPressViewModel? {
        let genre = genres[indexPath.row]
        
        model.title = genre.name
        model.description = "\(genre.artist.count)人のアーティスト"
        model.image = genre.representativeItem.helper.getArtwork(for: [100, 100], cornerRadius: 20, shadowed: true)
        
        model.addAction(title: "全曲シャッフル", image: #imageLiteral(resourceName: "shuffle_disable")){
            NowPlayingViewController.show().startMusicRandomly(list: genre.artist.flatMap{$0.albums}.flatMap{$0.songs})
        }
        
        return model
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getAlbumCell(at: indexPath)
        let genre = genres[indexPath.row]
        
        cell.title = genre.name
        cell.subtitle = "\(genre.artist.count)人のアーティスト"
        
        genre.representativeItem.helper.loadCollectionArtiwork{
            if cell.indexPath == indexPath{
                cell.cover = $0
            }
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
}
