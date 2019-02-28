import UIKit
import MediaPlayer


class PlayListsViewController: AMTableViewController {
    var playlists:[MPMediaPlaylist] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(forName: .AMPPSynchronizeEndNotification, object: nil, queue: nil){_ in
            self.tableView.reloadData()
        }
        
        self.playlists = MediaLibrary.default.getPlaylists()
        navigationItem.rightBarButtonItem = editButtonItem
        
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if !isEditing{
            self.playlists = MediaLibrary.default.getPlaylists()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathsForRows(in: (sender as! UITableViewCell).frame)![0]
        super.prepare(for: segue, sender: sender)
        let vc = segue.destination as! PlayListSinglesViewController
        vc.playlist = self.playlists[indexPath.row]
    }
    @IBAction func insertRow(_ sender: Any) {
        PlaylistEditingManager.default.startEditing {items in
            if items.isEmpty{return}
            PlaylistPerser.createNewPlaylist(with: "名称未設定", description: "", items: items){playlist in
                self.playlists.insert(playlist, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
    //====================================================================================
    //delegate
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1{return false}
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            playlists.remove(at: indexPath.row).perser.removeFromLibrary()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if indexPath.section == 1{
            insertRow(tableView)
        }
    }
    //====================================================================================
    //data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "add_button_cell",for: indexPath)
            
            return cell
        }else{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "cell",for: indexPath)
            
            let playlist = playlists[indexPath.row]
            
            (cell.viewWithTag(1) as! UIImageView).image = nil
            (cell.viewWithTag(2) as! UILabel).text = playlist.name ?? "unknown"
            (cell.viewWithTag(3) as! UILabel).text = "\(playlist.items.count)曲"
            
            cell.accessibilityIdentifier = playlist.name
            
            if let representativeItem = playlist.representativeItem{
                MediaItem(entity: representativeItem).helper.loadArtwork(with: [100, 100]){image in
                    if cell.accessibilityIdentifier == playlist.name{
                        (cell.viewWithTag(1) as! UIImageView).image = image
                    }
                }
            }
            
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{return 60}
        return 100
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{return 1}
        return playlists.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

