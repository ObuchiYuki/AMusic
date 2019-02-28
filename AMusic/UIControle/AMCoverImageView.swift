import UIKit

@IBDesignable
class AMCoverImageView: IBButton{
    var subImageView = UIImageView()
    private var _originalSize:CGSize! = nil
    private var _originalOrigin:CGPoint! = nil
    
    private func _setup(){
        self.setBackgroundImage(nil, for: .normal)
        
        self.subImageView.clipsToBounds = true
        self.subImageView.contentMode = .scaleToFill
        self.subImageView.isUserInteractionEnabled = false
        self.addSubview(self.subImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    func adjust(animated:Bool){
        if self.subImageView.image == nil{return}
        
        if self._originalSize == nil{self._originalSize = self.bounds.size}
        if self._originalOrigin == nil{self._originalOrigin = self.frame.origin}
        
        let newSize = self.subImageView.image?.size ?? self._originalSize ?? .zero
        
        func resize(){
            self.subImageView.frame.size = newSize
            self.frame.size = newSize
            
            let dh = self._originalSize.height - newSize.height
            let dw = self._originalSize.width - newSize.width
            self.frame.origin.y = self._originalOrigin.y + dh/2
            self.frame.origin.x = self._originalOrigin.x + dw/2
        }
        
        DispatchQueue.main.async {
            if !animated{
                resize()
                return
            }
            UIView.animate(withDuration: 0.2){
                resize()
            }
        }
    }
    func setImage(_ image:UIImage?,animated:Bool){
        if self._originalSize == nil{self._originalSize = self.bounds.size}
        if self._originalOrigin == nil{self._originalOrigin = self.frame.origin}
        
        self.subImageView.image = image?.resized(toFit: self._originalSize)
        
        adjust(animated:animated)
    }
    @IBInspectable override var cornerRadius:CGFloat{
        set{
            self.layer.cornerRadius = newValue
            self.subImageView.layer.cornerRadius = newValue
        }
        get{return self.layer.cornerRadius}
    }
}






















