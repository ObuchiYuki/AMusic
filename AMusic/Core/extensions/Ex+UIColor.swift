import UIKit

// MARK: - Extension for UIColor
extension UIColor {
    
    
    /// Returns is the color right or not.
    var isLight:Bool{
        let (r,g,b,_) = getRBGA()
        return ((r * 299) + (g * 587) + (b * 114)) / 1000 >= 0.5
    }
    
    /// Suger syntax of UIColor::withAlphaComponent(:_)
    func a(_ a:CGFloat)->UIColor{
        return self.withAlphaComponent(a)
    }
    /// Hex initializer like css.
    /// Css風なUIColorのイニシャライザー。
    ///
    /// Sample:
    /// let lightGray = UIColor(hex: 0xf3f3f3)
    /// let transparentRed = UIColor(hex: 0x670000,alpha: 0.5)
    ///
    /// - Parameters:
    ///   - hex: Hex value of the color (ex 0xf3f3f3 or 0x676767
    ///   - alpha: Alpha value of the color default is 1.0
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Add anothor color to Self
    /// 自身に別の色を足した色を返す。少し暗くしたり、影をつけたり。
    ///
    /// Sample:
    /// let green = UIColor.red
    /// let white = UIColor.white.withAlphaComponent(0.5)
    /// let lightGreen = green.add(overlay: white)
    ///
    /// - Parameter overlay: Anothor color to overlay
    /// - Returns: Overlaied Color
    func add(overlay: UIColor) -> UIColor {
        let (bgR,bgB,bgG,_) = self.getRBGA()
        let (fgR,fgB,fgG,fgA) = overlay.getRBGA()
        
        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// Color Paramators of self.
    /// RBGAをタプルで返す。ほとんどUIColor::add用。
    ///
    /// - Returns: Tuple of CGFloat. The order is (r, g, b, a)
    func getRBGA()->(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat){
        var r,g,b,a:CGFloat
        r = 0;g = 0;b = 0;a = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r:r,g:g,b:b,a:a)
    }
}

//MARK: - Add Color Operators
/// メソッド add の簡易使用用
func += (left:inout UIColor,right:UIColor){
    left = left.add(overlay: right)
}
func + (left:UIColor,right:UIColor)->UIColor{
    return left.add(overlay: right)
}















