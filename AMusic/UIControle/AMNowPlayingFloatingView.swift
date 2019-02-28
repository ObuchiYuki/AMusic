import UIKit

class AMNowPlayingFloatingView:UIView{
    static let shared = AMNowPlayingFloatingView()
    private let kHeight:CGFloat = 56
    private let kMargineTop:CGFloat = 10
    private let kCornerRadius:CGFloat = 15
    
    private let playerApi = MediaPlayer.default
    
    private let _gradationLayer = AMGradationLayer()
    private var _mainView:UIView!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var playbackProgressView: UIProgressView!
    
    @IBAction func skipButtonTouchUp(_ sender: Any) {
        ColorThemeManager.default.changeColorTheme(with: ColorPalette.current == .dark ? .default : .dark)
        //playerApi.player.skipToNextItem()
    }
    @IBAction func selfDidTouchUp(_ sender: Any) {
        _setDehighlighted()
    }
    @IBAction func selfDidTouchDown(_ sender: Any) {
        _setHighlighted()
    }
    @IBAction func selfDidPush(_ sender: Any) {
        NowPlayingViewController.show()
        _setDehighlighted()
    }
    @IBAction func playButtonDidPush(_ sender: Any) {
        if playerApi.playbackState == .playing{
            self.playerApi.pause()
            self.playButton.setImage(#imageLiteral(resourceName: "play").maskable, for: .normal)
        }else{
            self.playerApi.play()
            self.playButton.setImage(#imageLiteral(resourceName: "pause").maskable, for: .normal)
        }
    }
    func _setHighlighted(){
        UIView.animate(withDuration: 0.3){
            self.backgroundButton.backgroundColor = ColorPalette.current.cellSelectedColor
            self.titleLabel.textColor = .white
            self.playButton.imageView?.tintColor = .white
            self.skipButton.imageView?.tintColor = .white
        }
    }
    func _setDehighlighted(){
        UIView.animate(withDuration: 0.3){
            self.backgroundButton.backgroundColor = UIColor.clear
            self.titleLabel.textColor = ColorPalette.current.textColor
            self.playButton.imageView?.tintColor = ColorPalette.current.textColor
            self.skipButton.imageView?.tintColor = ColorPalette.current.textColor
        }
    }
    private func update(){
        if let currentSong = playerApi.nowPlayingItem{
            playbackProgressView.progress = Float(playerApi.currentPlaybackTime)/currentSong.helper.duration
        }else{
            playbackProgressView.progress = 0
        }
    }
    private func checkInfo(){
        if let currentSong = playerApi.nowPlayingItem{
            self.isHidden = false
            FloatingViewsManager.default.addFloatingView(with: self)
            self.transform = CGAffineTransform(translationX: 0, y: 0)
            currentSong.helper.loadArtwork(with: [48, 48],cornerRadius: 0){image in
                self.coverImageView.image = image.editable(for: [58, 58])
                .setPadding(5)
                .setCorner(10)
                .setShadow(.black, radius: 5, offset: [0, 4], opacity: 0.3)
                .rendered()
            }
            self.titleLabel.text = currentSong.title
            self.skipButton.setImage(self.skipButton.imageView?.image?.maskable, for: .normal)
            self.playButton.setImage(
                (playerApi.playbackState == .playing ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play")).maskable,
                for: UIControlState.normal
            )
            self.colorThemeDidChange(with: ColorPalette.current)
        }else{
            self.isHidden = true
            FloatingViewsManager.default.removeView(with: "NowPlayingFloatingView")
        }
    }
    private func colorThemeDidChange(with palette:ColorPalette){
        if palette == .dark{
            _mainView.backgroundColor = palette.cellBackgroundColor.add(overlay: palette.textColor.withAlphaComponent(0.05))
        }else{
            _mainView.backgroundColor = palette.cellBackgroundColor
        }
        titleLabel.textColor = palette.textColor
        playButton.imageView?.tintColor = palette.textColor
        skipButton.imageView?.tintColor = palette.textColor
    }
    func initialize(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){[weak self] timer in
            if self == nil{timer.invalidate()}
            self?.update()
        }
        
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: nil){[weak self] _ in
            UIView.animate(withDuration: 0.3){
                self?.colorThemeDidChange(with: ColorPalette.current)
            }
        }
        
        playerApi.setDidQueueChangeAction {[weak self] in self?.checkInfo()}
        playerApi.setDidItemChangeAction {[weak self] in self?.checkInfo()}
        playerApi.setDidPlayBackChangeAction {[weak self] in self?.checkInfo()}
                
        self.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: kHeight+kMargineTop))
        _mainView = Bundle.main.loadNibNamed("AMNowPlayingFloatingView", owner: self, options: nil)?.first as! UIView
        
        _mainView.frame = CGRect(x: 0, y: kMargineTop, width: self.frame.width, height: kHeight)
        _mainView.layer.shadowColor = UIColor.black.cgColor
        _mainView.layer.shadowOpacity = 0.4
        _mainView.layer.shadowRadius = 2
        _mainView.layer.shadowOffset = .zero
        self.addSubview(_mainView)
        self.clipsToBounds = true
        
        _gradationLayer.frame.size = _mainView.frame.size
        
        self.titleLabel.textColor = .white

        playbackProgressView.backgroundColor = .clear
        
        checkInfo()
    }
}


extension AMNowPlayingFloatingView: FloatingViewType{
    var viewHeight: CGFloat{return kHeight}
    var floatingViewIdentifier: String{return "NowPlayingFloatingView"}
    var instance: UIView{return self}
    var primary: Int{return 10000}
}






