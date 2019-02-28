import UIKit

class AMVolumeSlider: AMSlider {
    @IBOutlet weak private var progressView: AMGradationView!
    
    @IBOutlet weak private var iconLeft: UIImageView!
    @IBOutlet weak private var iconRight: UIImageView!
    
    var iconTintColor:UIColor? = nil{
        didSet{
            guard let iconTintColor = iconTintColor else {return}
            
            iconLeft.image = iconLeft.image?.maskable 
            iconRight.image = iconRight.image?.maskable
            
            iconLeft.tintColor = iconTintColor
            iconRight.tintColor = iconTintColor
        }
    }
    
    override func moveView(with movement: CGFloat) {
        progressView.frame.origin.x = -movement
    }
    override func modefyPanGesture(x: CGFloat) -> CGFloat {
        return -x
    }
    override func progressViewWidth() -> CGFloat {
        return progressView.frame.width
    }
    override func setup() {
        super.setup()
        
        let mainView = Bundle.main.loadNibNamed("AMVolumeSlider", owner: self, options: nil)?.first as! UIView
        mainView.frame.size = self.frame.size
        
        self.addSubview(mainView)
    }
}
