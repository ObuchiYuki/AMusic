import AudioKit


/// AKPlayerWrapper
/// AKPlayerの感覚似合わないところを吸収します。

class AKPlayerWrapper {
    // MARK: - Properties
    var duration:Double{
        return player.duration
    }
    var currentTime:Double{
        return self.player.currentTime
    }
    let player:AKPlayer
    private var avPlayer:AVPlayer!
    
    // MARK: - APIs
    func stop(){
        self.player.stop()
        try? AudioKit.stop()
    }
    func play(){
        try? AudioKit.start()
        self.player.play()
    }
    func pause(){
        self.player.setPosition(currentTime)
        self.player.pause()
    }
    
    func seek(to time:Double){
        DispatchQueue.main.async {
            self.player.setPosition(time)
        }
    }
    func replaceCurrentItem(with file: AKAudioFile){
        let isPlaying = player.isPlaying
        self.player.load(audioFile: file)
        if isPlaying{
            self.player.play()
        }else{
            self.player.pause()
        }
    }
    
    init(audioFile :AKAudioFile) {
        player = AKPlayer(audioFile: audioFile)
    }
}
