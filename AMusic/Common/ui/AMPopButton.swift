import UIKit

@IBDesignable
class AMPopButton:IBButton{
    //MARK: Properties
    
    //MARK: IBInspectables
    ///A Flag witch the aphpa animation enabled.
    @IBInspectable var useAlphaAnimation:Bool = true
    ///A Ratio of animation
    @IBInspectable var ratio:Double = 0.93
    ///A Speed of animation
    @IBInspectable var speed:Double = 1.0
    
    // MARK: Override
    override var isEnabled: Bool{
        get{return super.isEnabled}
        set{super.isEnabled = newValue;checkEnabledState()}
    }

    //MARK: Private Methods
    
    //MARK: Methods for animation
    private func startAnimating(){
        UIView.animate(withDuration: 0.2/speed, delay: 0, animations: {
            self.transform = CGAffineTransform(scaleX: CGFloat(self.ratio), y: CGFloat(self.ratio))
            if self.useAlphaAnimation{self.alpha = 0.6}
        })
    }
    private func endAnimating(){
        UIView.animate(withDuration: 0.1/speed, animations: {
            self.transform = CGAffineTransform(scaleX: CGFloat(1.0/self.ratio), y: CGFloat(1.0/self.ratio))
            if self.useAlphaAnimation{self.alpha = 0.8}
        })
        UIView.animate(withDuration: 0.1/speed, delay: 0.1/speed, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            if self.useAlphaAnimation{self.alpha = 1}
        })
    }
    
    //MARK: Other Methods.
    private func checkEnabledState(){
        if self.isEnabled{
            self.alpha = 1
        }else{
            self.alpha = 0.3
        }
    }
    
    //MARK: Detection for Tracking
    override func cancelTracking(with event: UIEvent?) {endAnimating()}
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {endAnimating()}
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {startAnimating();return true}
}





















