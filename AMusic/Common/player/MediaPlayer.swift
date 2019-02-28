import MediaPlayer
import AudioKit
import AVFoundation

class MediaPlayer:NSObject{
    //================================================================================
    //props
    static let `default` = MediaPlayer()
    //=======================================
    //api
    var effect:EffectPlayerSetting{
        get{return _player.effect}
        set{_player.effect = newValue}
    }
    private(set) var playbackState:AMusicPlaybackState = .stoped
    var repeatMode:AMMusicRepeatMode = .none{
        willSet{UserDefaults.standard.set(newValue.rawValue, forKey: kRepeatModeSaveKey)}
    }
    var shuffleMode:AMMusicShuffleMode{
        get{return _rawShuffleMode}
        set{
            _isTmpShuffleMode = false
            _rawShuffleMode = newValue
            if !_isTmpShuffleMode{UserDefaults.standard.set(newValue.rawValue, forKey: kShuffleModeSaveKey)}
            checkShuffleMode(with: newValue)
        }
    }
    var currentPlaybackTime:TimeInterval{
        get{return getCurrentTime()}
        set{seekPlayer(to: newValue)}
    }
    var indexOfNowPlayingItem:Int{
        get{return _currentItemIndex}
        set{
            self._currentItemIndex = newValue
            self.changeCurrentItem(to: _mediaCollection[newValue])
        }
    }
    var nowPlayingItem:MediaItem?{
        get{return _mediaCollection.at(_currentItemIndex)}
        set{if let item = newValue {changeCurrentItem(to: item)}}
    }
    var volume:Float{
        return _playerForNotifications.value(forKey: "volume") as! Float
    }
    var songList:[MediaItem]{
        return _mediaCollection
    }
    var isSeekingComplete:Bool{
        return _seekingCompletionCount == 0
    }
    //=====================================
    //private
    private var _rawShuffleMode = AMMusicShuffleMode.off
    private var _isSetuped = false
    private var _lastShuffleState:AMMusicShuffleMode = .off
    private var _isTmpShuffleMode = false
    private var _originalMediaCollection = [MediaItem]()
    private var _mediaCollection = [MediaItem]()
    private var _currentItemIndex = 0
    private var _player:AEPlayer!
    private var _albumCompletionFlag = false
    private var _seekingCompletionCount = 0
    
    private let _playerForNotifications = MPMusicPlayerController.systemMusicPlayer
    
    private let kRepeatModeSaveKey = "player_api_repeat_mode_key"
    private let kShuffleModeSaveKey = "player_api_shuffle_mode_key"
    
    private var onPlayBackDidChangeActions:[()->Void] = []
    private var onVolumeDidChangeActions:[()->Void] = []
    private var onItemDidChangeActions:[()->Void] = []
    private var onQueueDidChangeActions:[()->Void] = []
    private var onAlbumDidEndActions:[()->Void] = []
    //================================================================================
    //methods
    //=====================================
    //api
    func startMusicRandomly(with collection:[MediaItem]){
        let indexToStart = Int(arc4random_uniform(UInt32(collection.count - 1)))
        self.startMusic(with: collection, from: collection[indexToStart])
        self._lastShuffleState = self.shuffleMode
        self.shuffleMode = .on
        self._isTmpShuffleMode = true
    }
    func startMusic(with collection:[MediaItem],from item:MediaItem){
        if self._isTmpShuffleMode{
            shuffleMode = _lastShuffleState
            _isTmpShuffleMode = false
        }
        self.initialize(with: collection, from: item)
        self.play()
        self.checkShuffleMode(with: shuffleMode)
    }
    func initialize(){
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget{event in
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.isEnabled = true
    }
    func play(){
        playbackState = .playing
        self._player.play()
        self._albumCompletionFlag = false
        syncWithNowPlayingCenter()
        runPlayBackDidChangeActions()
    }
    func pause(){
        playbackState = .paused
        self._player.pause()
        syncWithNowPlayingCenter()
        runPlayBackDidChangeActions()
    }
    func stop(){
        self._player.stop()
        self.playbackState = .stoped
    }
    func skip(){
        skipToNextItem()
    }
    func skipToPrevOrBegin(){
        if currentPlaybackTime >= 5{
            skipToBegining()
        }else{
            skipToPreviousItem()
        }
    }
    func setDidPlayBackChangeAction(_ action:@escaping ()->Void){onPlayBackDidChangeActions.append(action)}
    func setDidVolumeChangeAction(_ action:@escaping ()->Void){onVolumeDidChangeActions.append(action)}
    func setDidItemChangeAction(_ action:@escaping ()->Void){onItemDidChangeActions.append(action)}
    func setDidQueueChangeAction(_ action:@escaping ()->Void){onQueueDidChangeActions.append(action)}
    func setDidAlbumEndAction(_ action:@escaping ()->Void){onAlbumDidEndActions.append(action)}
    //=====================================
    //private
    private func initialize(with collection:[MediaItem],from item:MediaItem){
        guard let indexOfItem = collection.index(of: item) else {return}
        guard let file = item.file else {return}
        
        self._albumCompletionFlag = false
        self._currentItemIndex = -1
        
        if self._player == nil{
            self._player = AEPlayer(file: file)
        }else{
            self._player.replaceCurrentItem(with: file)
        }
        
        self._currentItemIndex = indexOfItem
        self._mediaCollection = collection
        self._originalMediaCollection = collection
        self.setup()
        
        self.runItemDidChangeActions()
    }
    private func didAlbumEnd(){
        if self._isTmpShuffleMode{
            shuffleMode = _lastShuffleState
            _isTmpShuffleMode = false
            changeCurrentItem(to: _originalMediaCollection[0])
            checkShuffleMode(with: shuffleMode)
        }
    }
    private func checkShuffleMode(with mode:AMMusicShuffleMode){
        guard let nowPlayingItem = nowPlayingItem else {return}
        if mode == .on{
            _mediaCollection = _originalMediaCollection.shuffled()
            _mediaCollection.remove(of: nowPlayingItem)
            _mediaCollection.insert(nowPlayingItem, at: 0)
            _currentItemIndex = 0
        }else{
            _mediaCollection = _originalMediaCollection
            _currentItemIndex = _originalMediaCollection.index(of: nowPlayingItem)!
        }
        runQueueDidChangeActions()
    }
    private func skipToNextItem(){
        guard _player != nil else {return}
        if !(_mediaCollection.count > _currentItemIndex+1) && self.repeatMode != .all{
            self.runAlbumDidEndActions()
            self._albumCompletionFlag = true
            self._player.pause()
        }
        
        _currentItemIndex = _mediaCollection.count > _currentItemIndex+1 ? _currentItemIndex+1 : 0
        
        guard let file = _mediaCollection[_currentItemIndex].file else {return}
        self._player.replaceCurrentItem(with: file)
        
        if _currentItemIndex==0{
            self.didAlbumEnd()
        }
        
        runItemDidChangeActions()
        syncWithNowPlayingCenter()
    }
    private func skipToPreviousItem(){
        guard _player != nil else {return}
        _currentItemIndex = _currentItemIndex > 0 ? _currentItemIndex-1 : 0
        
        guard let file = _mediaCollection[_currentItemIndex].file else {return}
        self._player.replaceCurrentItem(with: file)
        
        runItemDidChangeActions()
        syncWithNowPlayingCenter()
    }
    private func skipToBegining(){
        guard _player != nil else {return}
        self.seekPlayer(to: 0)
        syncWithNowPlayingCenter()
    }
    private func seekPlayer(to time:TimeInterval){
        guard _player != nil else {return}
        _player.seek(to: time)
        self.syncWithNowPlayingCenter()
    }
    private func getCurrentTime()->TimeInterval{
        guard _player != nil else {return 0}
        return _player.currentTime
    }
    private func changeCurrentItem(to item:MediaItem){
        _currentItemIndex = _mediaCollection.index(of:item) ?? 0
        
        guard let file = item.file else {return}
        self._player.replaceCurrentItem(with: file)
        
        runItemDidChangeActions()
        syncWithNowPlayingCenter()
    }
    private func playerDidFinishPlaying() {
        switch self.repeatMode {
        case .one: currentPlaybackTime = 0
        case .none: self.skipToNextItem()
        case .all:
            if _albumCompletionFlag{
                _albumCompletionFlag = false
                _currentItemIndex = 0
                changeCurrentItem(to: _mediaCollection[0])
                checkShuffleMode(with: shuffleMode)
            }else{
                self.skipToNextItem()
            }
        }
        if !_albumCompletionFlag{self.play()}
    }
    private func syncWithNowPlayingCenter(){
        guard let nowPlayingItem = nowPlayingItem else {return}
        
        let defaultCenter = MPNowPlayingInfoCenter.default()
        let defaultArtwork = MPMediaItemArtwork(boundsSize: CGSize(width: 500, height: 500)){_ in return #imageLiteral(resourceName: "no_music")}
        
        defaultCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: nowPlayingItem.title,
            MPMediaItemPropertyArtist: "\(indexOfNowPlayingItem+1)/\(songList.count) - " + nowPlayingItem.artist,
            MPMediaItemPropertyArtwork: nowPlayingItem.artwork ?? defaultArtwork,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: nowPlayingItem.helper.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime:currentPlaybackTime
        ]
    }
    private func runPlayBackDidChangeActions(){DispatchQueue.main.async {self.onPlayBackDidChangeActions.forEach{$0()}}}
    private func runVolumeDidChangeActions(){DispatchQueue.main.async {self.onVolumeDidChangeActions.forEach{$0()}}}
    private func runItemDidChangeActions(){DispatchQueue.main.async {self.onItemDidChangeActions.forEach{$0()}}}
    private func runQueueDidChangeActions(){DispatchQueue.main.async {self.onQueueDidChangeActions.forEach{$0()}}}
    private func runAlbumDidEndActions(){DispatchQueue.main.async {self.onAlbumDidEndActions.forEach{$0()}}}
    
    private func setup() {
        if !_isSetuped{
            _isSetuped = true
            self.repeatMode = AMMusicRepeatMode(rawValue: UserDefaults.standard.integer(forKey: kRepeatModeSaveKey)) ?? .none
            self.shuffleMode = AMMusicShuffleMode(rawValue: UserDefaults.standard.integer(forKey: kShuffleModeSaveKey)) ?? .off
        }
    }
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(forName: .AMEffectPlayerItemDidPlayEnd){self.playerDidFinishPlaying()}
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerVolumeDidChange){self.runVolumeDidChangeActions()}
    }
    deinit {NotificationCenter.default.removeObserver(self)}
}
enum AMusicPlaybackState{
    case stoped
    case playing
    case paused
}
enum AMMusicRepeatMode:Int{
    case none = 0
    case all
    case one
}
enum AMMusicShuffleMode: Int{
    case off = 0
    case on
}

private extension MediaItem{
    var file: AKAudioFile?{
        return try? AKAudioFile(forReading: self.assetURL!)
    }
}



