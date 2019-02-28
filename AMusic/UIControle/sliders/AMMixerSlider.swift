import UIKit

/// AMMixerSlider
/// コントロールセンターちっくなスライダー
/// Progress: 0-1, Value: min-max
/// 内部的にはProgress、APIはValueを使う。

extension AMMixerSlider{
    /// Reset current value to defalut value.
    @IBAction func reset(){
        self.setValue(self.defaultValue, animated: true)
        self.sendActions(for: .valueChanged)
    }
}

class AMMixerSlider: AMSlider {
    // MARK: - Private Properties
    @IBInspectable var unitString:String = ""
    // MARK: - IBOutlet Parts
    @IBOutlet weak private var progressView: IBGradationView!
    @IBOutlet weak var backgroundView: IBView!
    @IBOutlet weak private var topLabel: UILabel!
    @IBOutlet weak private var underLabel: UILabel!
    
    private var _rawProgress:Double = 0
    private var _progressBeforePan:Double? = nil
    
    override func progressViewWidth() -> CGFloat {
        return self.progressView.frame.width
    }
    /// Progressを元にViewを動かす。
    override func moveView(with movement: CGFloat) {
        
        self.progressView.frame.origin.x = movement
        self.topLabel.center.x = self.progressView.frame.width / 2 - movement
        
        self.adjustLabelText()
    }
    
    /// Labelの文字を変更する。
    private func adjustLabelText(){
        let formatText = "%.\(_calculateAppropriateDigits())f" + (unitString.isEmpty ? "" : " \(unitString)")
        let progressString = String(format: formatText, value)
        
        topLabel.text = progressString
        underLabel.text = progressString
    }
    /// 適切な表示桁数を計算
    private func _calculateAppropriateDigits()->Int{
        if minValue < -10 || maxValue > 10 {return 1}
        return 2
    }
    
    // MARK: - initing
    override func setup(){
        super.setup()
        let mainView = Bundle.main.loadNibNamed("AMMixerSlider", owner: self, options: nil)?.first as! UIView
        self.backgroundColor = .clear
        mainView.backgroundColor = .clear
        mainView.frame.size = self.frame.size
        
        self.addSubview(mainView)
    }
}







