import UIKit

class AMNotificationView: UIView {
    // MARK: Properies
    
    // MARK: IBOutlet Parts
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // MARK: IBAction
    @IBAction func closeButtonDidPush(_ sender: Any) {
        self._runCloseAnimation()
    }
    
    // MARK: Private Properies
    private var cViewHeight:CGFloat{return UIScreen.main.bounds.height == 812 ? 127 : 77}
    private let kAnimationDuration:TimeInterval = 0.2
    private let kAppealingDuration:TimeInterval = 3
    private var _closeButtonAction:(AMNotificationView)->Void = {_ in}
    private let identifire:String = UUID().uuidString
    
    // MARK: APIs
    func show(){
        UIWindow.main.addSubview(self)
        
        self.frame.size = [UIWindow.main.frame.width,cViewHeight]
        _runShowAnimation()
        Timer.scheduledTimer(withTimeInterval: kAppealingDuration, repeats: false){[weak self] _ in
            self?._runCloseAnimation()
        }
    }
    func setCloseAction(_ action:@escaping (AMNotificationView)->Void){
        self._closeButtonAction = action
    }
    // MARK: Private Methods
    private func _runShowAnimation(){
        UIView.animate(withDuration: kAnimationDuration*0.7,delay: 0.0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 10)
        })
        UIView.animate(withDuration: kAnimationDuration*0.4,delay: kAnimationDuration*0.7, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    private func _runCloseAnimation(){
        UIView.animate(withDuration: kAnimationDuration, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -self.cViewHeight)
        }){_ in
            self._closeButtonAction(self)
            self._closeButtonAction = {_ in}
            self.removeFromSuperview()
        }
    }
    
    // MARK: Initirizer
    static func newInstance()->AMNotificationView {
        let view = UINib(nibName: "AMNotificationView", bundle: .main).instantiate(withOwner: nil, options: nil)[0] as! AMNotificationView
        view.transform = CGAffineTransform(translationX: 0, y: -view.cViewHeight)
        return view
    }
}
