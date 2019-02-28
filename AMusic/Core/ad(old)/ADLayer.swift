import UIKit

let kDCClearEffectsDuration = 0.3

///突貫工事でSwift1.2->Swift4に変更しています。
///バグあるかも?
class ADLayer: CALayer,CAAnimationDelegate{
    
    var maskEnabled = true {
        didSet {
            self.mask = maskEnabled ? maskLayer : nil
        }
    }
    var rippleEnabled = true
    var rippleScaleRatio: CGFloat = 1.0 {
        didSet {
            self.calculateRippleSize()
        }
    }
    var rippleDuration:CFTimeInterval = 0.35
    var elevation:CGFloat = 0 {
        didSet {
            self.enableElevation()
        }
    }
    var elevationOffset = CGSize.zero {
        didSet {
            self.enableElevation()
        }
    }
    var roundingCorners = UIRectCorner.allCorners {
        didSet {
            self.enableElevation()
        }
    }
    var backgroundAnimationEnabled = true
    
    private weak var superView: UIView?
    private var superLayer: CALayer?
    private var rippleLayer: CAShapeLayer?
    private var backgroundLayer: CAShapeLayer?
    private var maskLayer: CAShapeLayer?
    private var userIsHolding = false
    private var effectIsRunning = false
    
    private override init(layer: Any) {
        super.init()
    }
    
    init(superLayer: CALayer) {
        super.init()
        self.superLayer = superLayer
        setup()
    }
    
    init(withView view: UIView) {
        super.init()
        self.superView = view
        self.superLayer = view.layer
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.superLayer = self.superlayer
        self.setup()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == "bounds" {
                self.superLayerDidResize()
            } else if keyPath == "cornerRadius" {
                if let superLayer = superLayer {
                    setMaskLayerCornerRadius(superLayer.cornerRadius)
                }
            }
        }
    }
    
    func superLayerDidResize() {
        if let superLayer = self.superLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.frame = superLayer.bounds
            self.setMaskLayerCornerRadius(superLayer.cornerRadius)
            self.calculateRippleSize()
            CATransaction.commit()
        }
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == self.animation(forKey: "opacityAnim") {
            self.opacity = 0
        } else if flag {
            if userIsHolding {
                effectIsRunning = false
            } else {
                self.clearEffects()
            }
        }
    }
    
    func startEffects(atLocation touchLocation: CGPoint) {
        userIsHolding = true
        if let rippleLayer = self.rippleLayer {
            rippleLayer.timeOffset = 0
            rippleLayer.speed = backgroundAnimationEnabled ? 1 : 1.1
            if rippleEnabled {
                startRippleEffect(nearestInnerPoint(touchLocation))
            }
        }
    }
    
    func stopEffects() {
        userIsHolding = false
        if !effectIsRunning {
            self.clearEffects()
        } else if let rippleLayer = rippleLayer {
            rippleLayer.timeOffset = rippleLayer.convertTime(CACurrentMediaTime(), from: nil)
            rippleLayer.beginTime = CACurrentMediaTime()
            rippleLayer.speed = 1.2
        }
    }
    
    func stopEffectsImmediately() {
        userIsHolding = false
        effectIsRunning = false
        if rippleEnabled {
            if let rippleLayer = self.rippleLayer,
                let backgroundLayer = self.backgroundLayer {
                rippleLayer.removeAllAnimations()
                backgroundLayer.removeAllAnimations()
                rippleLayer.opacity = 0
                backgroundLayer.opacity = 0
            }
        }
    }
    
    func setRippleColor(
        _ color: UIColor,
        withRippleAlpha rippleAlpha: CGFloat = 0.3,
        withBackgroundAlpha backgroundAlpha: CGFloat = 0.3
    ){
        if
            let rippleLayer = self.rippleLayer,
            let backgroundLayer = self.backgroundLayer
        {
            rippleLayer.fillColor = color.withAlphaComponent(rippleAlpha).cgColor
            backgroundLayer.fillColor = color.withAlphaComponent(backgroundAlpha).cgColor
        }
    }
    
    func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if
            let first = touches.first,
            let superView = self.superView
        {
            let point = first.location(in: superView)
            startEffects(atLocation: point)
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.stopEffects()
    }
    
    func touchesCancelled(_ touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.stopEffects()
    }
    
    func touchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    
    private func setup() {
        rippleLayer = CAShapeLayer()
        rippleLayer!.opacity = 0
        self.addSublayer(rippleLayer!)
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer!.opacity = 0
        backgroundLayer!.frame = superLayer!.bounds
        self.addSublayer(backgroundLayer!)
        
        maskLayer = CAShapeLayer()
        self.setMaskLayerCornerRadius(superLayer!.cornerRadius)
        self.mask = maskLayer
        
        self.frame = superLayer!.bounds
        superLayer!.addSublayer(self)
        superLayer!.addObserver(
            self,
            forKeyPath: "bounds",
            options: NSKeyValueObservingOptions(rawValue: 0),
            context: nil
        )
        superLayer!.addObserver(
            self,
            forKeyPath: "cornerRadius",
            options: NSKeyValueObservingOptions(rawValue: 0),
            context: nil
        )
        self.enableElevation()
        self.superLayerDidResize()
    }
    
    private func setMaskLayerCornerRadius(_ radius: CGFloat) {
        if let maskLayer = self.maskLayer {
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        }
    }
    
    private func nearestInnerPoint(_ point: CGPoint) -> CGPoint {
        let centerX = self.bounds.midX
        let centerY = self.bounds.midY
        let dx = point.x - centerX
        let dy = point.y - centerY
        let dist = sqrt(dx * dx + dy * dy)
        if let backgroundLayer = self.rippleLayer {
            if dist <= backgroundLayer.bounds.size.width / 2 {
                return point
            }
            let d = backgroundLayer.bounds.size.width / 2 / dist
            let x = centerX + d * (point.x - centerX)
            let y = centerY + d * (point.y - centerY)
            return CGPoint(x: x, y: y)
        }
        return .zero
    }
    
    private func clearEffects() {
        if
            let rippleLayer = self.rippleLayer,
            let backgroundLayer = self.backgroundLayer
        {
            rippleLayer.timeOffset = 0
            rippleLayer.speed = 1
            
            if rippleEnabled {
                rippleLayer.removeAllAnimations()
                backgroundLayer.removeAllAnimations()
                self.removeAllAnimations()
                
                let opacityAnim = CABasicAnimation(keyPath: "opacity")
                opacityAnim.fromValue = 1
                opacityAnim.toValue = 0
                opacityAnim.duration = kDCClearEffectsDuration
                opacityAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                opacityAnim.isRemovedOnCompletion = false
                opacityAnim.fillMode = kCAFillModeForwards
                opacityAnim.delegate = self
                
                self.add(opacityAnim, forKey: "opacityAnim")
            }
        }
    }
    
    private func startRippleEffect(_ touchLocation: CGPoint) {
        self.removeAllAnimations()
        self.opacity = 1
        if
            let rippleLayer = self.rippleLayer,
            let backgroundLayer = self.backgroundLayer,
            let superLayer = self.superLayer
        {
            rippleLayer.removeAllAnimations()
            backgroundLayer.removeAllAnimations()
            
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 0
            scaleAnim.toValue = 1
            scaleAnim.duration = rippleDuration
            scaleAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            scaleAnim.delegate = self
            
            let moveAnim = CABasicAnimation(keyPath: "position")
            moveAnim.fromValue = NSValue(cgPoint: touchLocation)
            moveAnim.toValue = NSValue(cgPoint: CGPoint(x: superLayer.bounds.midX,y: superLayer.bounds.midY))
            moveAnim.duration = rippleDuration
            moveAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            effectIsRunning = true
            rippleLayer.opacity = 1
            
            rippleLayer.add(moveAnim, forKey: "position")
            rippleLayer.add(scaleAnim, forKey: "scale")
        }
    }
    
    private func calculateRippleSize() {
        if let superLayer = self.superLayer {
            let superLayerWidth = superLayer.bounds.width
            let superLayerHeight = superLayer.bounds.height
            let center = CGPoint(x: superLayer.bounds.midX,y: superLayer.bounds.midY)
            let circleDiameter = sqrt(
                powf(Float(superLayerWidth), 2) + powf(Float(superLayerHeight), 2)
            ) * Float(rippleScaleRatio)
            
            let subX = center.x - CGFloat(circleDiameter) / 2
            let subY = center.y - CGFloat(circleDiameter) / 2
            
            if let rippleLayer = self.rippleLayer {
                rippleLayer.frame = CGRect(x: subX, y: subY, width: CGFloat(circleDiameter), height: CGFloat(circleDiameter))
                rippleLayer.path = UIBezierPath(ovalIn: rippleLayer.bounds).cgPath
                
                if let backgroundLayer = self.backgroundLayer {
                    backgroundLayer.frame = rippleLayer.frame
                    backgroundLayer.path = rippleLayer.path
                }
            }
        }
    }
    
    private func enableElevation() {
        if let superLayer = self.superLayer {
            superLayer.shadowOpacity = 0.5
            superLayer.shadowRadius = elevation / 4
            superLayer.shadowColor = UIColor.black.cgColor
            superLayer.shadowOffset = elevationOffset
        }
    }
}
