import UIKit

@IBDesignable
class IBImageView:UIImageView{
    private let kBackgroundColor = UIColor.black
    override var isHighlighted: Bool{
        set{
            super.isHighlighted = newValue
            self.backgroundColor = kBackgroundColor
        }
        get{return super.isHighlighted}
    }
    @IBInspectable var cornerRadius:CGFloat{
        get{return self.layer.cornerRadius}
        set{self.layer.cornerRadius = newValue}
    }
    @IBInspectable var borderWidth:CGFloat{
        get{return self.layer.borderWidth}
        set{self.layer.borderWidth = newValue}
    }
    @IBInspectable var borderColor:UIColor{
        get{return UIColor(cgColor: self.layer.borderColor!)}
        set{self.layer.borderColor = newValue.cgColor}
    }
}
