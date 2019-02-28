import UIKit

class AMTimeSlider: AMSlider{
    @IBOutlet weak var progressView: AMGradationView!
    
    override func moveView(with movement: CGFloat) {
        progressView.frame.origin.x = -movement
    }
    override func modefyPanGesture(x: CGFloat) -> CGFloat {
        return -x
    }
    override func setup() {
        super.setup()
        
        let mainView = Bundle.main.loadNibNamed("AMTimeSlider", owner: self, options: nil)?.first as! UIView
        mainView.frame.size = self.frame.size
        
        self.addSubview(mainView)
    }
}
