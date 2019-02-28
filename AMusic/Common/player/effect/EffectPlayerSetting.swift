import AudioKit

// MARK: - Setting Structure
struct EffectPlayerSetting{
    var pitchShift:Double = 0
    var reverb = Reverb()
    var speed:Double = 1.0
    var equalizerGains:[Double] = Array(repeating: 0, count: 10)
    
    struct Reverb {
        var type:AVAudioUnitReverbPreset? = nil
        
        var isManualType = false
        var feebback:Double = 0
        var mix:Double = 0
    }
}
