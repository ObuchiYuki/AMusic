import UIKit
import MarqueeLabel


class MarqueeButton: UIButton{
    private let marqueeLabel = MarqueeLabel()
    private var _oldTitle:String? = nil
    private let kTitleChangeAnimationDelay = 0.15
    private let kHighlightChangeAnimationDelay = 0.1
    
    private func didTitleChange(from fromValue:String?,to toValue:String?){
        if fromValue != toValue{
            UIView.animate(withDuration: kTitleChangeAnimationDelay, delay: 0, animations: {
                self.marqueeLabel.alpha = 0
            }){_ in self.marqueeLabel.text = toValue}
            UIView.animate(withDuration: kTitleChangeAnimationDelay, delay: kTitleChangeAnimationDelay, animations: {
                self.marqueeLabel.alpha = 1
            })
        }
    }
    override var isHighlighted: Bool{
        get{return super.isHighlighted}
        set{
            super.isHighlighted = newValue
            UIView.animate(withDuration: kHighlightChangeAnimationDelay){
                self.marqueeLabel.alpha = newValue ? 0.5 :1
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        marqueeLabel.frame.size = self.bounds.size
    }
    private func setup(){
        marqueeLabel.fadeLength = 10
        marqueeLabel.animationDelay = 3
        marqueeLabel.font = self.titleLabel?.font
        
        switch self.effectiveContentHorizontalAlignment {
        case .leading, .left : marqueeLabel.textAlignment = .left
        case .right, .trailing: marqueeLabel.textAlignment = .right
        default: marqueeLabel.textAlignment = .center
        }
        
        marqueeLabel.textColor = self.tintColor
        
        self.addSubview(marqueeLabel)
    }
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(nil, for: state)
        _oldTitle = marqueeLabel.text
        didTitleChange(from: _oldTitle, to: title)
    }
    override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitle(nil, for: state)
        self.marqueeLabel.textColor = color
    }
    override func tintColorDidChange() {
        super.tintColorDidChange()
        marqueeLabel.textColor = self.tintColor
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}
