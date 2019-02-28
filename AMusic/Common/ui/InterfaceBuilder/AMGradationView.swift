import UIKit

@IBDesignable
class AMGradationView: IBView{
    @IBInspectable var horizontal:Bool = false
    
    private let _gradationLayer = AMGradationLayer()
    
    override func draw(_ rect: CGRect) {
        if horizontal{
            _gradationLayer.direction = .horizontal
        }
        _gradationLayer.removeFromSuperlayer()
        _gradationLayer.frame.size = self.frame.size
        self.layer.insertSublayer(_gradationLayer, at: 0)
    }
}
