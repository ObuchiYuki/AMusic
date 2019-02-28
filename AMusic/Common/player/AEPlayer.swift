import AudioKit
import MediaPlayer

/// AVPlayerっぽい何か
/// ここまで再生の基礎が
/// MPMediaPlayerController -> AVPlayer -> MediaPlayerWrapper -> SongProcesser -> AMEffectPlayer
/// って変わってきました。
/// MPMediaPlayerController, AVPlayer, AMEffectPlayer
/// はほとんどAPIが一緒やね



class AEPlayer {
    // MARK: - APIs
    var effect = EffectPlayerSetting() {didSet{_effectDidChange()}}
    var currentTime:Double{return _playerWrapper.currentTime}
    var duration:Double{return _playerWrapper.duration}
    
    func play(){_playerWrapper.play()}
    func pause(){_playerWrapper.pause()}
    func stop(){_playerWrapper.stop()}
    
    func seek(to time:Double){_playerWrapper.seek(to: time)}
    func replaceCurrentItem(with file: AKAudioFile){_playerWrapper.replaceCurrentItem(with: file)}
    
    // MARK: - Private Properties
    var _playerWrapper:AKPlayerWrapper
    private var _playerMixer:AKMixer!
    
    private var _pitchShifter:AKPitchShifter!
    private var _reverb:AKReverb!
    private var _manualReverb:AKCostelloReverb!
    private var _manualReverbMixer:AKDryWetMixer!
    private var _speedBooster:AKVariSpeed!
    
    private var _equalizer:AKAudioEQ!
    
    // MARK: - Private Methods
    private func _effectDidChange(){
        self._pitchShifter.shift = effect.pitchShift
        self._speedBooster.rate = effect.speed
        self._equalizer.gains = effect.equalizerGains
        
        if effect.reverb.isManualType{
            self._reverb.dryWetMix = 0
            self._manualReverb.feedback = effect.reverb.feebback
            self._manualReverbMixer.balance = effect.reverb.mix
        }else{
            self._reverb.dryWetMix = 1
            self._manualReverbMixer.balance = 0
            if let reverb = effect.reverb.type{
                self._reverb.loadFactoryPreset(reverb)
            }else{
                self._reverb.dryWetMix = 0
            }
        }
    }
    // MARK: - Init
    init(file: AKAudioFile) {
        self._playerWrapper = AKPlayerWrapper(audioFile: file)
        
        AKSettings.playbackWhileMuted = true
        
        _playerWrapper.player.completionHandler = {
            NotificationCenter.default.post(name: .AMEffectPlayerItemDidPlayEnd, object: nil, userInfo: nil)
        }
        self._initEffects()
    }
    private func _initEffects(){
        ///init pitchShifter: _playerMixer -> _pitchShifter
        _pitchShifter = AKPitchShifter(_playerWrapper.player, shift: 0)
        
        ///init reverb: _pitchShifter -> _reverb
        _reverb = AKReverb(_pitchShifter, dryWetMix: 0)
        
        ///_reverb -> _speedBooster
        _speedBooster = AKVariSpeed(_reverb, rate: 1.0)
        
        ///_speedBooster -> _manualReverbMixer
        _manualReverb = AKCostelloReverb(_speedBooster)
        _manualReverbMixer = AKDryWetMixer(_speedBooster,_manualReverb, balance: 0)
        
        ///_manualReverbMixer -> _eq
        _equalizer = AKAudioEQ(_manualReverbMixer, numberOfBands: 10)
        
        ///_eq -> AudioKit.output
        AudioKit.output = _equalizer
    }
}
extension Notification.Name{
    static let AMEffectPlayerItemDidPlayEnd = Notification.Name(rawValue: "AMEffectPlayerItemDidPlayEnd")
}
















