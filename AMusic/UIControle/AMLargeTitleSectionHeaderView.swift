import UIKit

class AMLargeTitleSectionHeaderView:UIView{
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var actionButton:UIButton!
    var identifire:String? = nil
    private let kHeight:CGFloat = 64
    private var action:(String?)->Void = {_ in}
    
    override var tintColor: UIColor!{
        set{
            super.tintColor = newValue
            self.actionButton.setTitleColor(newValue, for: .normal)
        }
        get{return super.tintColor}
    }
    
    @IBAction func actionButtonDidPush(_ sender: Any) {
        action(identifire)
    }
    
    func setAction(with title:String,action:@escaping (String?)->Void){
        self.actionButton.setTitle(title, for: .normal)
        self.action = action
    }
    private func setup(){
        let view = Bundle.main.loadNibNamed("AMLargeTitleSectionHeaderView", owner: self, options: nil)?.first as! UIView
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kHeight)
        view.frame = self.bounds
        self.addSubview(view)
        
        titleLabel.textColor = ColorPalette.current.textColor
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
