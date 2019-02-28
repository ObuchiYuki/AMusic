import UIKit

@IBDesignable
class IBGradationView:UIView{
    @IBInspectable var firstColor:UIColor = .white
    @IBInspectable var lastColor:UIColor = .white
    @IBInspectable var horizontal:Bool = false
    
    private let _gradationLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        _gradationLayer.removeFromSuperlayer()
        _gradationLayer.frame.size = self.frame.size
        _gradationLayer.colors = [firstColor.cgColor,lastColor.cgColor]
        if horizontal{
            _gradationLayer.startPoint = [1,0]
            _gradationLayer.endPoint = .zero
        }
        self.layer.insertSublayer(_gradationLayer, at: 0)
    }
}
