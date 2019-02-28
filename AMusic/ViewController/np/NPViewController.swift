import UIKit
import MediaPlayer

/// そう... ここ即ち...
/// 天の元の全てのコンポーネントの集う場所...
/// NowPlayingViewControllerである... (BGM: Unicorn)
class NowPlayingViewController: AMViewController {
    // MARK: - Properties
    private let playerApi = MediaPlayer.default
    
    // MARK: - UIs (Header)
    private let volumeView = MPVolumeView(frame: .zero)
    private var volumeViewSlider:UISlider! = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var timeSlider: AMSlider!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    
    @IBAction func timeSliderDidChange(_ sender: AMSlider) {
        self.playerApi.currentPlaybackTime = timeSlider.value
    }
    @IBAction func timeSliderChange(_ sender: Any) {
        checkTimeLabel(with: timeSlider.value)
    }
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBAction func dismissButtonPush(_ sender: Any) {self.dismiss(animated: true)}
    
    // MARK: - UIs (Body)
    @IBOutlet weak var imageView: AMCoverImageView!
    
    // MARK: - UIs (Footer)
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonPush(_ sender: Any) {
        if playerApi.playbackState == .playing{
            self.playerApi.pause()
        }else{
            self.playerApi.play()
        }
        playbackStateDidChange()
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func nextButtonPush(_ sender: Any) {
        DispatchQueue.global().async {
            self.playerApi.skip()
            DispatchQueue.main.sync {self.generalInfoDidChange()}
        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButtonPush(_ sender: Any) {
        DispatchQueue.global().async {
            self.playerApi.skipToPrevOrBegin()
            DispatchQueue.main.sync {self.generalInfoDidChange()}
        }
    }
    
    @IBOutlet weak var volumeSlider: AMVolumeSlider!
    @IBAction func volumeSliderChange(_ sender: AMVolumeSlider) {
        volumeViewSlider.value = Float(sender.value)
    }
    @IBAction func moreButtonDidPush(_ sender: Any) {
        showActionSheet()
    }
    
    // MARK: - UIs (Toggle)
    @IBOutlet weak var shuffleButton: UIButton!
    @IBAction func shuffleButtonPush(_ sender: Any) {
        playerApi.shuffleMode = playerApi.shuffleMode == .off ? .on : .off
        shuffleStateDidChange()
    }
    
    @IBOutlet weak var repeatButton: UIButton!
    @IBAction func repeatButtonPush(_ sender: Any) {
        switch playerApi.repeatMode {
        case .all :playerApi.repeatMode = .one
        case .none:playerApi.repeatMode = .all
        case .one :playerApi.repeatMode = .none
        }
        repeatStateDidChange()
    }
    
    // MARK: - Private Methods
    private func showActionSheet(){
        guard let song = playerApi.nowPlayingItem else {return}
        
        let model = AMLongPressViewModel()
        model.title = song.title
        model.subtitle = song.helper.artist
        model.description = song.helper.durationString()
        model.image = song.helper.getArtwork(for: [100, 100], cornerRadius: 20, shadowed: true)
        
        
        if song.isLocal{
            model.addAction(title: "曲を削除", image:  #imageLiteral(resourceName: "trash")){
                let removeSheet = UIAlertController(title: "削除しますか？", message: "ミュージックをライブラリから削除します。", preferredStyle: .alert)
                
                removeSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
                removeSheet.addAction(title: "削除", style: .destructive){
                    ADMediaLibrary.default.removeItem(with: song.entity as! ADMediaItem)
                    song.helper.loadArtwork(with: [41, 41]){NotificationManager.default.post("削除しました。", subTitle: song.title, image: $0)}
                    self.dismiss()
                }
                
                self.present(removeSheet, animated: true)
            }
            model.addAction(title: "編集", image: #imageLiteral(resourceName: "edit")){self.performSegue(withIdentifier: "toEditView", sender: nil)}
        }
        model.addAction(title: "プレイリストに追加", image: #imageLiteral(resourceName: "add_to_playlist")){}
        
        self.present(AMLongPressViewManager.newVC(model: model), animated: true)
    }
    private func update(){
        guard !timeSlider.isTracking else {return}
        
        let time = playerApi.currentPlaybackTime
        if !self.timeSlider.isTracking {
            self.timeSlider.value = time
        }
        checkTimeLabel()
    }
    private func checkAllInfo(){
        generalInfoDidChange(animated: false)
        repeatStateDidChange()
        shuffleStateDidChange()
        volumeDidChange()
        playbackStateDidChange()
    }
    private func repeatStateDidChange(){
        switch playerApi.repeatMode {
        case .all :repeatButton.setImage(#imageLiteral(resourceName: "repeat"), with: ColorPalette.current.tintColor.main)
        case .none:repeatButton.setImage(#imageLiteral(resourceName: "repeat"), with: ColorPalette.current.subTextColor)
        case .one :repeatButton.setImage(#imageLiteral(resourceName: "repeat_one"), with: ColorPalette.current.tintColor.main)
        }
    }
    private func checkTimeLabel(with time:TimeInterval? = nil){
        let time:TimeInterval = time == nil ? playerApi.currentPlaybackTime : time!
        if timeSlider.isTracking && self.leftTimeLabel.transform == CGAffineTransform(scaleX: 1, y: 1){
            UIView.animate(withDuration: 0.2){
                self.leftTimeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.rightTimeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }else if !timeSlider.isTracking && self.leftTimeLabel.transform == CGAffineTransform(scaleX: 1.2, y: 1.2){
            UIView.animate(withDuration: 0.2){
                self.leftTimeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.rightTimeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        self.leftTimeLabel.text = playerApi.nowPlayingItem?.helper.pastDurationString(current: time) ?? ""
        self.rightTimeLabel.text = playerApi.nowPlayingItem?.helper.lastDurationString(current: time) ?? ""
    }
    private func shuffleStateDidChange(){
        
        if playerApi.shuffleMode == .on{
            shuffleButton.imageView?.tintColor = ColorPalette.current.tintColor.main
        }else{
            shuffleButton.imageView?.tintColor = ColorPalette.current.subTextColor
        }
        
        self.title = "\(playerApi.indexOfNowPlayingItem+1) of \(MediaPlayer.default.songList.count)"
    }
    private func volumeDidChange(){
        if !self.volumeSlider.isTracking{
            self.volumeSlider.setValue(Double(self.playerApi.volume), animated: true)
        }
    }
    private func playbackStateDidChange(){
        if playerApi.playbackState == .playing{
            self.playButton.setImage(#imageLiteral(resourceName: "pause").maskable, for: .normal)
        }else{
            self.playButton.setImage(#imageLiteral(resourceName: "play").maskable, for: .normal)
        }
    }
    ///先読み (Read Ahead)
    private func readAhead(){
        guard let nextSong = playerApi.songList.at(playerApi.indexOfNowPlayingItem+1) else {return}
        let imageSize = CGSize(width: UIScreen.main.bounds.width-64, height: UIScreen.main.bounds.width-64)
        
        nextSong.helper.loadArtwork(with: imageSize){_ in}
    }
    private func generalInfoDidChange(animated:Bool = true){
        if let song = playerApi.nowPlayingItem {
            let imageSize = CGSize(width: UIScreen.main.bounds.width-64, height: UIScreen.main.bounds.width-64)
            
            song.helper.loadArtwork(with: imageSize, cornerRadius: 0){image in
                self.imageView.setImage(image, animated: animated)
                self.backgroundImageView.image = image
                self.readAhead()
            }
            
            self.titleLabel.text = song.title
            self.albumButton.setTitle("\(song.helper.artist) - \(song.albumTitle)", for: .normal)
            self.timeSlider.maxValue = Double(song.helper.duration)
            self.title = "\(playerApi.indexOfNowPlayingItem+1) of \(MediaPlayer.default.songList.count)"
        }else{
            self.titleLabel.text = "No Music...?"
            self.albumButton.setTitle("", for: .normal)
            self.imageView.setImage(nil, animated: animated)
        }
    }
    
    // MARK: - Override Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let item = playerApi.nowPlayingItem else {return}
        if let vc = segue.destination as? NowPlayingAlbumViewController{
            vc.album = MediaLibrary.default.getSingles(of: item.albumIdentifier)
            vc.title = item.albumTitle
        }else if let vc = segue.destination as? NPDetailViewController{
            vc.item = item
        }
    }
    override func colorThemeDidChange(with palette: ColorPalette) {
        super.colorThemeDidChange(with: palette)
        
        self.navigationController?.navigationBar.barStyle = palette.naviBarStyle
        self.navigationController?.navigationBar.barTintColor = nil
        self.view.backgroundColor = palette.backgroundColor
        self.effectView.effect = UIBlurEffect(style: palette.blurStyle)
        self.titleLabel.textColor = palette.textColor
        self.rightTimeLabel.textColor = palette.textColor
        self.leftTimeLabel.textColor = palette.textColor
        self.playButton.imageView?.tintColor = palette.textColor
        self.nextButton.imageView?.tintColor = palette.textColor
        self.backButton.imageView?.tintColor = palette.textColor
        self.volumeSlider.iconTintColor = palette.textColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Notifications
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){[weak self] timer in
            if self == nil{timer.invalidate()}
            self?.update()
        }
        playerApi.setDidItemChangeAction{[weak self] in self?.generalInfoDidChange()}
        playerApi.setDidQueueChangeAction {[weak self] in self?.generalInfoDidChange()}
        playerApi.setDidVolumeChangeAction {[weak self] in self?.volumeDidChange()}
        playerApi.setDidPlayBackChangeAction {[weak self] in self?.playbackStateDidChange()}
        playerApi.setDidAlbumEndAction {[weak self] in self?.dismiss(animated: true)}
        
        // MARK: - Setup UIs
        StatusbarManager.default.style = .lightContent
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.nextButton.setImage(nextButton.imageView?.image?.maskable, for: .normal)
        self.backButton.setImage(backButton.imageView?.image?.maskable, for: .normal)
        self.backgroundImageView.image = nil
        self.imageView.subImageView.image = nil
        self.volumeView.frame.origin.x = -1000
        self.shuffleButton.setImage(#imageLiteral(resourceName: "shuffle_enable").maskable, for: .normal)
        
        guard let slider = volumeView.subviews.compactMap({$0 as? UISlider}).first else {return}
        self.volumeViewSlider = slider
        
        view.addSubview(volumeView)
        
        checkAllInfo()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageView.adjust(animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        StatusbarManager.default.style = .lightContent
    }
    override func viewDidDisappear(_ animated: Bool) {
        StatusbarManager.default.resetStatusbar()
    }
}

// MARK: - Extensions
extension NowPlayingViewController{
    func startMusic(list:[MediaItem],start:MediaItem){
        playerApi.startMusic(with: list, from: start)
    }
    func startMusicRandomly(list:[MediaItem]){
        playerApi.startMusicRandomly(with: list)
    }
    @discardableResult
    static func show()->NowPlayingViewController{
        let sb = UIStoryboard.main
        let vc = sb.instantiateViewController(withIdentifier: "NowPlayingNavigationViewController") as! UINavigationController
        let npvc = vc.viewControllers.first as! NowPlayingViewController
        
        let tabvc = UIWindow.main.rootViewController as! AMTabBarController
        tabvc.present(vc, animated: true)
        
        return npvc
    }
}
