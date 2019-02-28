import UIKit
import MarqueeLabel

class NPEditViewController: NPTableViewContoller {
    // MARK: - Properies

    // MARK: - IB
    /// Header
    @IBOutlet weak var coverImageView: IBImageView!
    @IBAction func coverButtonDidPush(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        self.present(imagePicker, animated: true)
    }
    @IBOutlet weak var headerTitleLabel: MarqueeLabel!
    @IBOutlet weak var headerArtistLabel: MarqueeLabel!
    @IBOutlet weak var headerAlbumLabel: MarqueeLabel!
    
    /// Main
    @IBOutlet weak var titleTextField: UITextField!
    @IBAction func titleTextFiledDidChange(_ sender: UITextField) {headerTitleLabel.text = sender.text}
    
    @IBOutlet weak var artistTextField: UITextField!
    @IBAction func artistTextFiledDidChange(_ sender: UITextField) {headerArtistLabel.text = sender.text}
    
    @IBOutlet weak var albumTextField: UITextField!
    @IBAction func albumTextFiledDidChange(_ sender: UITextField) {headerAlbumLabel.text = sender.text}
    
    /// Sub
    @IBOutlet weak var albumArtistTextField: UITextField!
    @IBOutlet weak var compTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var trackNumTextField: UITextField!
    @IBOutlet weak var trackCountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var diskNumTextField: UITextField!
    @IBOutlet weak var distCountTextField: UITextField!
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {}
    @IBAction func submitButtonDidPush(_ sender: Any) {
        self.dismiss()
    }
    
    // MARK: - Private Properties
    
    private var song:ADMediaItem!
    // MARK: - Metadata Continers
    private var _metadata = ADMetadata()
    private var _coverImage:UIImage?
    
    // MARK: - Private Methods
    private func _didImagePicked(_ image: UIImage){
        _coverImage = image
        coverImageView.image = _coverImage?.resized(to: coverImageView.frame.size)
    }
    
    private func _changeMetadata(){
        _metadata.title = titleTextField.text
        _metadata.artist = artistTextField.text
        _metadata.albumTitle = albumTextField.text
        _metadata.albumArtist = albumArtistTextField.text
        _metadata.composer = compTextField.text
        _metadata.albumTrackNumber = Int(trackNumTextField.text ?? "")!
        _metadata.albumTrackCount = Int(trackCountTextField.text ?? "")!
        _metadata.genre = genreTextField.text
        _metadata.thumbnail = _coverImage
        
        ADMediaLibrary.default.changeMetadata(for: song, with: _metadata)
        
        NotificationCenter.default.post(name: .ADMediaLibraryItemDidChange, object: nil)
    }
    private func _deployMusicInformation(){
        coverImageView.image = _coverImage?.resized(to: coverImageView.frame.size)
        
        headerTitleLabel.text = song.title
        headerArtistLabel.text = song.artist
        headerAlbumLabel.text = song.albumTitle
        
        titleTextField.text = song.title
        artistTextField.text = song.artist
        albumTextField.text = song.albumTitle
        
        albumArtistTextField.text = song.albumArtist
        compTextField.text = song.composer
        genreTextField.text = song.genre
        trackNumTextField.text = song.albumTrackNumber.description
        trackCountTextField.text = song.albumTrackCount.description
        
        dateTextField.text = song.releaseDate?.description
        
        distCountTextField.text = song.discCount.description
        diskNumTextField.text = song.discNumber.description
    }
    
    // MARK: - Override Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = ColorPalette.current.cellBackgroundColor
        return cell
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !MediaPlayer.default.nowPlayingItem!.isLocal{
            NotificationManager.default.post("エラー: ダウンロードした曲のみ編集ができます。")
            self.dismiss()
            return
        }
        
        song = MediaPlayer.default.nowPlayingItem?.entity as! ADMediaItem
        
        self.tableView.separatorColor = .clear
        self.tableView.allowsSelection = false
        
        self._coverImage = song.artwork?.image(at: [700, 700])
        self._deployMusicInformation()
    }
}


// MARK: - UITextFieldDelegate
extension NPEditViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NPEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss()
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        _didImagePicked(image)
    }
}



