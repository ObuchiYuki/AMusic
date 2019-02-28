import UIKit

class NPDetailViewController:AMViewController{
    ///MARK: Properties
    var item:MediaItem!
    
    private var LyricList:[LyricsAPI.LyricsRequest] = []
    
    @IBOutlet weak var tableView: UITableView!
    private let kCornerRadius:CGFloat = 30
    private let kDismissOffset:CGFloat = 130
    private var _imageViewInited = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        LyricsAPI.default.getLyricsList(for: self.item.title){list in
            self.LyricList = list
            self.tableView.reloadData()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathsForRows(in: (sender as! UITableViewCell).frame)![0]
        let req = LyricList[indexPath.row]
        if
            let textView = segue.destination.view.viewWithTag(1) as? UITextView,
            let indicator = segue.destination.view.viewWithTag(2) as? UIActivityIndicatorView,
            let titlelabel = segue.destination.view.viewWithTag(3) as? UILabel
        {
            indicator.startAnimating()
            LyricsAPI.default.getLyrics(for: req){data in
                indicator.stopAnimating()
                indicator.isHidden = true
                if let data = data{
                    titlelabel.text = "\(data.title) / \(data.artist)"
                    textView.text = data.lyrics
                }else{
                    titlelabel.text = "データが所得できませんでした。"
                }
            }
        }
    }
}
extension NPDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension NPDetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        return LyricList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "coverCell", for: indexPath)
            if _imageViewInited{return cell}
            _imageViewInited = true
            cell.layer.cornerRadius = 30
            cell.clipsToBounds = true
            (cell.viewWithTag(1) as! UIImageView).image = nil
            //self.item.helper.loadArtwork(with: <#CGSize#>){(cell.viewWithTag(1) as! UIImageView).image = $0}
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let lyricData = LyricList[indexPath.row]
            cell.backgroundColor = .clear
            cell.selectedBackgroundView?.alpha = 0.4
            cell.textLabel?.text = "\(lyricData.title) / \(lyricData.artist)"
            return cell
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -kDismissOffset{
            self.dismiss()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}



















