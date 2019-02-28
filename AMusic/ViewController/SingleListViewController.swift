import UIKit
import MediaPlayer
import NVActivityIndicatorView

class SingleListViewController: AMTableViewController{
    var albums:[AlbumInfo] = []
    
    private var playingIndicator = NVActivityIndicatorView(
        frame: [0, 0, 15, 15], type: NVActivityIndicatorType.lineScaleParty, color: ColorPalette.current.tintColor.main, padding: 0
    )
    private var playingIndexPath:IndexPath? = nil
    
    private var additionalSectionCount:Int{
        return albums.count != 1 ? 1 : 0
    }
    @IBAction func playlistAddAlbumButtonDidPush(_ sender: UIButton) {
        guard let cell = sender.superview?.superview else {return}
        guard let indexPath = tableView.indexPathForRow(at: cell.center) else {return}
        if PlaylistEditingManager.default.isEditing{
            PlaylistEditingManager.default.contentToAdd.append(contentsOf: albums[indexPath.section-additionalSectionCount].songs)
            self.tableView.reloadRows(at: self.tableView.visibleCells.map{tableView.indexPath(for: $0)!}, with: .none)
        }
    }
    @IBAction func shulleButtonDidPush(_ sender: UIButton) {
        guard let cell = sender.superview?.superview else {return}
        guard let indexPath = tableView.indexPathForRow(at: cell.center) else {return}
        NowPlayingViewController.show().startMusicRandomly(list: albums[indexPath.section-additionalSectionCount].songs)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        MediaPlayer.default.setDidItemChangeAction {[weak self] in
            self?.tableView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AlbumViewController{
            let artist = (sender as! UIButton).titleLabel?.text ?? "unknown"
            vc.albums = MediaLibrary.default.getAlbums(of: artist)
            vc.title = artist
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && albums.count != 1{
            NowPlayingViewController.show().startMusicRandomly(list: albums.flatMap{$0.songs})
        }
        if indexPath.row == 0{
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if PlaylistEditingManager.default.isEditing{
            guard let single = albums[indexPath.section-additionalSectionCount].songs.at(indexPath.row-1) else {return}
            PlaylistEditingManager.default.contentToAdd.append(single)
            tableView.reloadData()
            return
        }
        NowPlayingViewController.show().startMusic(
            list: albums[indexPath.section-additionalSectionCount].songs,
            start: albums[indexPath.section-additionalSectionCount].songs[indexPath.row-1]
        )
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && albums.count != 1{return 55}
        if indexPath.row == 0{
            return 125
        }else{
            return 45
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && albums.count != 1{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "all_items_cell", for: indexPath) as! AMAllItemsCell
            cell.textLabel?.text = "全ての曲をシャッフル"
            cell.textLabel?.textColor = ColorPalette.current.tintColor.main
            cell.detailTextLabel?.text = nil
            return cell
        }
        if indexPath.row == 0 {//ヘッダー的なやつ
            let cell = self.getCurrentColorThemedCell(withIdentifier: "top_cell",for: indexPath)
            let album = albums[indexPath.section-additionalSectionCount]
            guard let firstSong = album.songs.first else {return cell}
            (cell.viewWithTag(1) as! UIImageView).image = nil
            (cell.viewWithTag(2) as! UILabel).text = album.albumTitle
            (cell.viewWithTag(3) as! UIButton).setTitle(firstSong.helper.albumArtist, for: .normal)
            (cell.viewWithTag(4) as! UILabel).text = "\(Int(album.songs.map{$0.helper.duration}.reduce(0, +)/60.0))分"
            (cell.viewWithTag(5) as! UIButton).isHidden = !PlaylistEditingManager.default.isEditing
            (cell.viewWithTag(5) as! UIButton).imageView?.alpha = PlaylistEditingManager.default.hasAlbum(album) ? 0.2 : 1
            (cell.viewWithTag(6) as! UIButton).isHidden = PlaylistEditingManager.default.isEditing
            firstSong.helper.loadArtwork(with: [113, 113],cornerRadius: 20, shadowed: true){image in
                (cell.viewWithTag(1) as! UIImageView).image = image
            }
            return cell
        }else if PlaylistEditingManager.default.isEditing{//編集用セル
            let cell = self.getCurrentColorThemedCell(withIdentifier: "editing_cell",for: indexPath)
            let single = albums[indexPath.section-additionalSectionCount].songs[indexPath.row-1]
            
            (cell.viewWithTag(1) as! UILabel).text = single.albumTrackNumber == 0 ? "" : "\(single.albumTrackNumber)"
            (cell.viewWithTag(2) as! UILabel).text = single.title
            (cell.viewWithTag(3) as! UILabel).text = single.helper.durationString()
            (cell.viewWithTag(4) as! UIButton).imageView?.alpha = PlaylistEditingManager.default.contentToAdd.contains(single) ? 0.2 : 1
            
            return cell
        }else{//最も基本的なセル
            let cell = self.getCurrentColorThemedCell(withIdentifier: "cell",for: indexPath)
            let single = albums[indexPath.section-additionalSectionCount].songs[indexPath.row-1]
            
            (cell.viewWithTag(1) as! UILabel).text = single.albumTrackNumber == 0 ? "" : "\(single.albumTrackNumber)"
            (cell.viewWithTag(2) as! UILabel).text = single.title
            (cell.viewWithTag(3) as! UILabel).text = single.helper.durationString()
            
            if MediaPlayer.default.nowPlayingItem == single{
                playingIndicator.startAnimating()
                cell.accessoryView = playingIndicator
                playingIndexPath = indexPath
            }else{
                cell.accessoryView = nil
            }

            return cell
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count+additionalSectionCount
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count != 1 && section == 0 ? 1 : albums[section-additionalSectionCount].songs.count+1
    }
}
