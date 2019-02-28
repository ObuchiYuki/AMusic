import UIKit

@IBDesignable
class AMGradationButton: UIButton {
    private var gradientLayer:AMGradationLayer{
        return self.layer as! AMGradationLayer
    }
    override class var layerClass: AnyClass {return AMGradationLayer.self}
    @IBInspectable var _isLineType:Bool = false{
        didSet{
            if _isLineType{
                let shape = CAShapeLayer()
                shape.lineWidth = 3
                shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: bounds.height/2).cgPath
                shape.cornerRadius = bounds.height/2
                shape.strokeColor = UIColor.black.cgColor
                shape.fillColor = UIColor.clear.cgColor
                gradientLayer.mask = shape
                
                self.setTitleColor(#colorLiteral(red: 0.9866124988, green: 0.23717767, blue: 0.2805764973, alpha: 1), for: .normal)
            }else{
                self.setTitleColor(.white, for: .normal)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.cornerRadius = bounds.height/2
        self.gradientLayer.frame.size = frame.size
    }
    private func setup() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.setTitleColor(.white, for: .normal)
    }
    override var isHighlighted: Bool{
        didSet{
            UIView.animate(withDuration: 0.15){
                self.gradientLayer.opacity = self.isHighlighted ? 0.6 :1
                self.titleLabel?.alpha = self.isHighlighted ? 0.6 :1
            }
        }
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
