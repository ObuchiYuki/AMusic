import UIKit

/// AMSlider
/// Panで段階的に動かせるスライダー
class AMSlider: UIControl {
    // MARK: - APIs
    
    /// Default value. set as initial Value
    /// And when reseted slider move to this value
    @IBInspectable var defaultValue:Double = 0
    @IBInspectable var unitValue:Double = 0.1
    @IBInspectable var isUniting:Bool = true
    
    /// Max Value of a Slider
    @IBInspectable var maxValue:Double = 1
    /// Min Value of a Slider
    @IBInspectable var minValue:Double = 0
    
    /// Current Value.
    var value:Double{
        get{return getValue(of: _rawProgress)}
        set{moveSlider(to: getProgress(of: newValue),animated: false)}
    }
    
    /// Set Slider Value with Animation Falg.
    ///
    /// - Parameters:
    ///   - value: target Value
    ///   - animated: if animate.
    func setValue(_ value:Double, animated:Bool){
        self.moveSlider(to: getProgress(of: value), animated: animated)
    }
    
    override var isTracking: Bool{
        return _isTracking
    }
    /// Methods for Override
    /// エンドクラスでオーバーライドする様のメソッド
    
    /// progressViewの横幅を返す。
    /// overrideしなければViewのWidthをそのまま使う。
    func progressViewWidth()->CGFloat{
        return self.frame.width
    }
    /// Progressを元にViewを動かす。
    func moveView(with movement:CGFloat){}
    
    func modefyPanGesture(x: CGFloat)->CGFloat{
        return x
    }
    // MARK: - Private Properties
    private var _rawProgress:Double = -1
    private var _progressBeforePan:Double? = nil
    private var _isTracking = false{
        didSet{if !_isTracking{ sendActions(for: .primaryActionTriggered) }}
    }
    
    // MARK: - Override Methods
    /// Panスタート時に_progressBeforePanをnilにする。
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self._isTracking = true
        
        self._progressBeforePan = nil
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self._isTracking = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self._isTracking = false
    }
    override func draw(_ rect: CGRect) {
        _rawProgress = _rawProgress == -1 ? getProgress(of: defaultValue) : _rawProgress
        self.moveSlider(to: _rawProgress, animated: false)
        
        super.draw(rect)
    }
    
    // MARK: - Private Methods
    ///Progress (0-1)からValue(minValue-maxValue)を計算
    private func getProgress(of value:Double)->Double{
        return (value - minValue) / (maxValue - minValue)
    }
    ///Value(minValue-maxValue)からProgress(0-1)を計算
    private func getValue(of progress:Double)->Double{
        return progress * (maxValue - minValue) + minValue
    }
    /// Progress (0-1)からViewの変更分を計算。Viewの座標系に変換
    private func getViewMovement(of progress:Double)->CGFloat{
        return progressViewWidth() * (1 - CGFloat(progress))
    }
    
    /// Progress(0-1)が変更される直前に呼ばれる。
    /// sendActions用、特にUnitingしているときに無駄にActionが送られないように。
    private func progressWillChange(to progress:Double){
        if _rawProgress != progress{
            sendActions(for: .valueChanged)
        }
    }
    /// Panの変更値を元にProgress(0-1)を計算
    /// Panスタート時に_progressBeforePanはnilになっている。
    /// Sliderの方向とPanの値の方向は逆
    private func didPan(_ deltaX:CGFloat){
        if _progressBeforePan == nil{
            self._progressBeforePan = _rawProgress
        }
        
        let viewWidth = progressViewWidth()
        let deltaProgress = -deltaX / viewWidth
        var newProgress = _progressBeforePan! + Double(deltaProgress)
        
        newProgress = min(newProgress, 1)
        newProgress = max(newProgress, 0)
        
        progressWillChange(to: newProgress)
        
        self._rawProgress = newProgress
    }
    /// 変更単位に合わせる。
    private func adjustProgressToUnit(){
        var newValue = getValue(of: _rawProgress)
        newValue = round(value: newValue, by: unitValue)
        self._rawProgress = getProgress(of: newValue)
    }
    /// 変更単位計算用
    private func round(value:Double,at point:Int)->Double{
        let digit = pow(10.0, Double(point))
        return (value * digit).rounded(.down) / digit
    }
    private func round(value:Double,by unit:Double)->Double{
        let valueRounded = round(value: value, at: 3)
        return round(value: valueRounded - valueRounded.remainder(dividingBy: unit), at: 3)
        
    }
    /// Progress変更時の処理
    private func didProgressChange(){
        if isUniting{
            self.adjustProgressToUnit()
        }
        self.moveView(with: self.getViewMovement(of: _rawProgress))
    }
    /// コードでスライダーを動かす。
    private func moveSlider(to progress:Double,animated:Bool){
        if _isTracking {return}
        
        self._rawProgress = progress
        
        if animated{
            UIView.animate(withDuration: 0.3){
                self.didProgressChange()
            }
        }else{
            self.didProgressChange()
        }
    }
    /// UIPanGestureRecognizer のハンドラー
    @objc private func panActionHandler(_ sender:UIPanGestureRecognizer){
        let dx = self.modefyPanGesture(x: sender.translation(in: self).x)
        
        self.didPan(dx)
        self.didProgressChange()
    }
    
    // MARK: - initing
    func setup() {
        self.backgroundColor = .clear
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AMSlider.panActionHandler(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(panGestureRecognizer)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}







