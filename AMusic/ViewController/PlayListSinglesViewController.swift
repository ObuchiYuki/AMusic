import UIKit
import MediaPlayer


// TODO: - ADMediaItemへの対応
class PlayListSinglesViewController:AMTableViewController{
    var playlist:MPMediaPlaylist!
    var perser:PlaylistPerser! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        
        perser = playlist.perser
    }
    var titleTextField:UITextField? = nil
    @IBAction func titleTextFieldDidChange(_ sender: Any) {
        perser.name = titleTextField?.text ?? ""
    }
    @IBAction func insertRows(_ sender: Any) {
        PlaylistEditingManager.default.startEditing {items in
            self.perser.addCollection(items)
            self.tableView.reloadData()
        }
    }
    //====================================================================================
    //delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            NowPlayingViewController.show().startMusic(list: perser.items, start: perser.items[indexPath.row])
        }
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing{
            tableView.beginUpdates()
            tableView.deleteSections(IndexSet(integer: 1), with: .left)
            tableView.endUpdates()
            perser.synchronize()
        }else{
            tableView.beginUpdates()
            tableView.insertSections(IndexSet(integer: 1), with: .left)
            tableView.endUpdates()
        }
        titleTextField?.isEnabled = editing
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == 1{return false}
        return true
    }
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if proposedDestinationIndexPath.section != 2{return sourceIndexPath}
        return proposedDestinationIndexPath
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        perser.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{return false}
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { 
        if editingStyle == .delete {
            perser.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else if editingStyle == .insert{
            insertRows(tableView)
        }
    }
    //====================================================================================
    //data
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{return 125}
        else if indexPath.section == 1 && isEditing{return 45}
        else{return 70}
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0{return .none}
        if indexPath.section == 1{return .insert}
        return .delete
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.getCurrentColorThemedCell(withIdentifier: "top_cell",for: indexPath)

            (cell.viewWithTag(2) as! UITextField).text = perser.name
            (cell.viewWithTag(2) as! UITextField).textColor = ColorPalette.current.textColor
            titleTextField = cell.viewWithTag(2) as? UITextField
            (cell.viewWithTag(3) as! UILabel).text = playlist.descriptionText
            (cell.viewWithTag(4) as! UILabel).text = "\(perser.count)曲・\(Int(perser.items.map{$0.helper.duration}.reduce(0, +)/60.0))分"
            cell.viewWithTag(1)?.layer.borderColor = UIColor(hex: 0xF0F0F0).cgColor
            cell.viewWithTag(1)?.layer.borderWidth = 0.5
            
            (cell.viewWithTag(1) as! UIImageView).image = perser.coverImage ?? nil
            return cell
        }else if indexPath.section == 1 && isEditing{
            return self.getCurrentColorThemedCell(withIdentifier: "add_button_cell",for: indexPath)
        }else{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "cell",for: indexPath)
            
            let single = perser.items[indexPath.row]
            
            (cell.viewWithTag(1) as! UIImageView).image = single.artwork?.image(at: (cell.viewWithTag(1) as! UIImageView).frame.size) ?? #imageLiteral(resourceName: "no_music")
            (cell.viewWithTag(2) as! UILabel).text = single.title
            (cell.viewWithTag(3) as! UILabel).text = single.helper.durationString()
            (cell.viewWithTag(4) as! UILabel).text = single.helper.artist
            
            return cell
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isEditing{return 3}
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        if isEditing && section == 1{return 1}
        return perser.count
    }
}
