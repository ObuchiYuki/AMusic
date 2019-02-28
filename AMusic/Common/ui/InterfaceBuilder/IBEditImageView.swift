import UIKit

@IBDesignable
class IBEditImageView: UIImageView {
    @IBInspectable var cornerRadius:CGFloat = 0{didSet{updateImage()}}
    @IBInspectable var padding:CGFloat = 0{didSet{updateImage()}}
    
    @IBInspectable var shadowColor:UIColor = .clear{didSet{updateImage()}}
    @IBInspectable var shadowRadius:CGFloat = 0{didSet{updateImage()}}
    @IBInspectable var shadowOffset:CGSize = .zero{didSet{updateImage()}}
    @IBInspectable var shadowOpacity:Float = 0{didSet{updateImage()}}
    
    @IBInspectable var borderColor:UIColor = .clear{didSet{updateImage()}}
    @IBInspectable var borderWidth:CGFloat = 0{didSet{updateImage()}}
    
    @IBInspectable var blurRadius:CGFloat = 0{didSet{updateImage()}}
    @IBInspectable var blurOffset:CGSize = .zero{didSet{updateImage()}}
    @IBInspectable var blurDiffusion:CGFloat = 0{didSet{updateImage()}}
    
    
    override var image: UIImage?{
        get{
            return super.image
        }
        set{
            super.image = newValue
            self._originalImage = newValue
        }
    }
    private var _originalImage:UIImage? = nil
    
    func updateImage(){
        self.image = _originalImage?
            .editable(for: self.frame.size)
            .setPadding(padding)
            .setCorner(cornerRadius)
            .setShadow(shadowColor, radius: shadowRadius, offset: shadowOffset, opacity: shadowOpacity)
            .setBorder(borderColor, width: borderWidth)
            .setBlur(blurRadius, offset: blurOffset, diffusion: blurDiffusion)
            .rendered()
    }
}
