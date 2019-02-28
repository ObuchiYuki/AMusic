import UIKit

@IBDesignable
class AMRoundedVisualEffectView : UIVisualEffectView{
    @IBInspectable var cornerRadius:CGFloat{
        get{return self._cornerRadius}
        set{self._cornerRadius = newValue}
    }
    private var _cornerRadius:CGFloat = 15
}
@IBDesignable
class IBVisualEffectView:UIVisualEffectView{
    @IBInspectable var cornerRadius:CGFloat{
        get{return self.layer.cornerRadius}
        set{self.layer.cornerRadius = newValue}
    }
}
@IBDesignable
class IBButton: UIButton{
    @IBInspectable var cornerRadius:CGFloat{
        set{self.layer.cornerRadius = newValue}
        get{return self.layer.cornerRadius}
    }
    @IBInspectable var shadowColor:UIColor{
        set{self.layer.shadowColor = newValue.cgColor}
        get{return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor)}
    }
    @IBInspectable var shadowOpacity:Float{
        set{self.layer.shadowOpacity = newValue}
        get{return self.layer.shadowOpacity}
    }
    @IBInspectable var shadowOffset:CGSize{
        set{self.layer.shadowOffset = newValue}
        get{return self.layer.shadowOffset}
    }
    @IBInspectable var shadowRadius:CGFloat{
        set{self.layer.shadowRadius = newValue}
        get{return self.layer.shadowRadius}
    }
}
@IBDesignable
class IBView: UIView{
    @IBInspectable var cornerRadius:CGFloat{
        set{
            self.layer.cornerRadius = newValue
        }
        get{return self.layer.cornerRadius}
    }
    @IBInspectable var shadowColor:UIColor{
        set{self.layer.shadowColor = newValue.cgColor}
        get{return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor)}
    }
    @IBInspectable var shadowOpacity:Float{
        set{self.layer.shadowOpacity = newValue}
        get{return self.layer.shadowOpacity}
    }
    @IBInspectable var shadowOffset:CGSize{
        set{self.layer.shadowOffset = newValue}
        get{return self.layer.shadowOffset}
    }
    
    @IBInspectable var shadowRadius:CGFloat = 0{
        willSet{self.layer.shadowRadius = newValue}
    }
}
