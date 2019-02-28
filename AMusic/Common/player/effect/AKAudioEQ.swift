import AudioKit

class AKAudioEQ: AKNode, AKInput, AKToggleable {
    var isStarted: Bool{
        return bands.filter{$0.gain == 0}.count != bands.count
    }
    private var lastKnownGains:[Double]!
    
    func start() {
        self.gains = lastKnownGains
    }
    
    func stop() {
        self.gains = Array(repeating: 0, count: numberOfBands)
    }
    
    private let audioUnitEQ:AVAudioUnitEQ
    private let numberOfBands:Int
    
    @objc open dynamic var bands:[AVAudioUnitEQFilterParameters]{
        return self.audioUnitEQ.bands
    }
    
    @objc open dynamic var globalGain: Double = 1.0 {
        didSet{
            audioUnitEQ.globalGain = Float(globalGain)
        }
    }
    
    @objc open dynamic var gains: [Double] = []{
        didSet{
            self.lastKnownGains = gains
            for i in 0...numberOfBands-1{
                self.bands[i].gain = Float(gains[i])
            }
        }
    }
    
    private func autoBanding(){
        for i in 0...numberOfBands-1{
            self.bands[i].bandwidth = 0.5
            self.bands[i].filterType = .parametric
            self.bands[i].frequency = Float(32.0 * pow(2.0, Double(i)))
            self.bands[i].gain = 0
            self.bands[i].bypass = false
        }
    }
    @objc init(_ input: AKNode? = nil, numberOfBands: Int = 10, autoBanded:Bool = true) {
        self.numberOfBands = numberOfBands
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: numberOfBands)
        self.lastKnownGains = Array(repeating: 0, count: numberOfBands)
        
        super.init()
        
        self.avAudioNode = self.audioUnitEQ
        
        AudioKit.engine.attach(self.avAudioNode)
        input?.connect(to: self)
        
        if autoBanded{
            autoBanding()
        }
    }
}
