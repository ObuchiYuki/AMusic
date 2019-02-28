import UIKit
import MediaPlayer

class SongsListViewController:AMTableViewController{
    var songs:[String:[MediaItem]] = [:]
    var sectionTitles:[String] = []
    static var unloadImage:UIImage = {
        return UIImage.colorImage(color: UIColor.lightGray.a(0.5), size:[1, 1]).cornerRadiused(10, size: [52, 52])
    }()
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
        
        songs = MediaLibrary.default.getIndexedSongs()
        sectionTitles = MediaLibrary.default.getSongIndex()
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let song = songs[sectionTitles[indexPath.section]]?.at(indexPath.row){
            let vc = NowPlayingViewController.show()
            vc.startMusic(list: MediaLibrary.default.getIndexedSongList(), start: song)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.getCurrentColorThemedCell(withIdentifier: "cell",for: indexPath)
        if let song = songs[sectionTitles[indexPath.section]]?.at(indexPath.row){
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = SongsListViewController.unloadImage
            (cell.viewWithTag(2) as! UILabel).text = song.title
            (cell.viewWithTag(3) as! UILabel).text = song.artist
            (cell.viewWithTag(4) as! UILabel).text = song.helper.durationString()
            
            cell.accessibilityIdentifier = song.id.description
            
            song.helper.loadArtwork(with: [52, 52],cornerRadius: 10, bordered: true){image in
                if cell.accessibilityIdentifier == song.id.description{
                    imageView.image = image
                }
            }
        }
        cell.imageView?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return songs.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs[sectionTitles[section]]?.count ?? 0
    }
}
