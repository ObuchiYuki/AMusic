import UIKit

class NowPlayingListViewController:AMTableViewController{
    let list = MediaPlayer.default.songList
    
    private var headerView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isAdjustInsetWithFloatingView = false
        self.title = "\(list.count)つのミュージック"
        self.tableView.tableFooterView = UIView()
        
        let naviHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + 20
        
        headerView = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: -naviHeight),
            size: CGSize(width: UIScreen.main.bounds.width, height: naviHeight)
        ))
        headerView.backgroundColor = ColorPalette.current.navigationColor
        self.view.addSubview(headerView)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.frame.origin.y = scrollView.contentOffset.y
    }
    override func colorThemeDidChange(with palette: ColorPalette) {
        super.colorThemeDidChange(with: palette)
        headerView?.backgroundColor = palette.navigationColor
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentMusicIndexPath = IndexPath(row: MediaPlayer.default.indexOfNowPlayingItem, section: 0)
        self.tableView.scrollToRow(at: currentMusicIndexPath, at: .middle, animated: true)
        StatusbarManager.default.style = .lightContent
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MediaPlayer.default.indexOfNowPlayingItem = indexPath.row
        MediaPlayer.default.play()
        self.navigationController?.popViewController(animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.getCurrentColorThemedCell(withIdentifier: "cell", for: indexPath)
        let song = list[indexPath.row]
        
        (cell.viewWithTag(1) as! UIImageView).image = nil
        (cell.viewWithTag(2) as! UILabel).text = song.title
        (cell.viewWithTag(3) as! UILabel).text = song.artist
        (cell.viewWithTag(4) as! UILabel).text = song.helper.durationString()
        
        cell.accessibilityIdentifier = song.title
        song.helper.loadArtwork(with: CGSize(width: 45, height: 45)){image in
            if cell.accessibilityIdentifier == song.title{
                (cell.viewWithTag(1) as! UIImageView).image = image
            }
        }
        
        if song == MediaPlayer.default.nowPlayingItem{
            let alpha:CGFloat = ColorPalette.current == .dark ? 0.25 : 0.14
            cell.backgroundColor = cell.backgroundColor?.add(overlay: ColorPalette.current.tintColor.main.withAlphaComponent(alpha))
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
}
