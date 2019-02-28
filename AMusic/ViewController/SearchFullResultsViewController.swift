import UIKit

class SearchFullResultsViewController:AMTableViewController{
    var word:String!
    var type:MediaLibrary.SearchResultType!
    private var results:[MediaLibrary.SearchResult] = []
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: ColorPalette.current.indicatorStyle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        indicator.center = self.view.center
        indicator.frame.origin.y -= 150
        indicator.startAnimating()
        self.view.addSubview(indicator)
        DispatchQueue.global().async {
            self.results = MediaLibrary.default.search(with: self.word, of: self.type)
            DispatchQueue.main.sync {
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
}
extension SearchFullResultsViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        switch self.type! {
        case .song:
            NowPlayingViewController.show().startMusic(list: results.map{$0.data as! MediaItem}, start: result.data as! MediaItem)
        case .artist:
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "AlbumListViewController") as! AlbumViewController
            vc.albums = (result.data as! ArtistInfo).albums
            vc.title = (result.data as! ArtistInfo).name
            self.navigationController?.pushViewController(vc, animated: true)
        case .album:
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "SingleListViewController") as! SingleListViewController
            vc.albums = [result.data as! AlbumInfo]
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.getCurrentColorThemedCell(withIdentifier: "cell",for: indexPath)
        let result = results[indexPath.row]
        
        (cell.viewWithTag(1) as! UIImageView).image = result.image
        (cell.viewWithTag(2) as! UILabel).text = result.title
        (cell.viewWithTag(3) as! UILabel).text = result.subtitle
        
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 70}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return results.count}
}
