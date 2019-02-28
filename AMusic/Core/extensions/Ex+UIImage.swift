import UIKit

// MARK: - Extension for UIColor
extension UIImage {
    // MARK: - ここからSwiftで書かれたもの
    
    
    /// syntax sugar for UIImage::withRenderingMode(.alwaysTemplate)
    var maskable:UIImage{
        return self.withRenderingMode(.alwaysTemplate)
    }
    
    /// UIImage witch is filled with a color of size.
    /// 単一色で塗りつぶした画像を生成
    ///
    /// Sample:
    /// let redImage = UIImage.colorImage(.red, size: CGSize(width: 100, height: 100))
    ///
    /// - Parameters:
    ///   - color: Fill Color
    ///   - size: Image Size
    class func colorImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(origin: .zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// Resize the image. The aspect ratio is not kept.
    /// 画像をリサイズ、アスペクト比は保証せず。
    ///
    /// - Parameter size: Size to resize
    /// - Returns: Resized image
    func resized(to size:CGSize)->UIImage{
        if size.width < 0 || size.height < 0 {fatalError("Resize size must bigger than zero.")}
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// Resize the image like an aspectfit.
    /// 画像をリサイズ、アスペクト比も保証。Size内に収まるようにリサイズ
    ///
    /// - Parameter size: Max size to resize
    /// - Returns: Resized image
    func resized(toFit size:CGSize)->UIImage{
        let aspect = self.size.width / self.size.height
        if size.width/aspect <= size.height{
            return self.resized(to: CGSize(width: size.width, height: size.width/aspect))
        }else{
            return self.resized(to: CGSize(width: size.height * aspect,height: size.height))
        }
    }
    // MARK: - ここから Obj-Cで書かれたものの翻訳
    ///挙動不明のため非推奨
    func image(with cornerRadius: CGFloat) -> UIImage{
        var imageBounds: CGRect;
        let scaleForDisplay = UIScreen.main.scale;
        let cornerRadius = cornerRadius * scaleForDisplay;
        
        imageBounds = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.height);
        
        let path = UIBezierPath.init(roundedRect: imageBounds, cornerRadius: cornerRadius);
        UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, 0.0);
        let fillColor = UIColor.black;
        fillColor.setFill();
        path.fill();
        let maskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        context?.clip(to: imageBounds, mask: maskImage!.cgImage!)
        
        self.draw(at:CGPoint.zero);
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage!;
    }
    func representativeColor()->UIColor{
        return self.getPixelColor(atPosition: CGPoint(x: 10, y: 10))
    }
    func getPixelColor(atPosition position: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data:UnsafePointer = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(position.y)) + Int(position.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func masked(byColor color:UIColor)->UIImage{
        defer {UIGraphicsEndImageContext()}
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {return self}
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        context.setBlendMode(.multiply)
        
        let rect = CGRect(origin: .zero, size: size)
        context.clip(to: rect, mask: cgImage!)
        color.setFill()
        context.fill(rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {return self}
        
        return newImage.resizableImage(withCapInsets: capInsets, resizingMode: resizingMode)
    }
    @available(*, unavailable, deprecated: 3.0)///挙動不明
    func append(newImage:UIImage)->UIImage{
        let topImage = newImage
        let bottomImage = self
        
        let newSize = bottomImage.size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, bottomImage.scale);
        
        bottomImage.draw(in: CGRect(x:0,y:0,width:newSize.width,height:newSize.height));
        
        topImage.draw(in: CGRect(x:0,y:0,width:newSize.width,height:newSize.height),blendMode:CGBlendMode.normal, alpha:1.0)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    func masked(byImage maskImage:UIImage)->UIImage{
        let maskRef = maskImage.cgImage!
        let mask = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: maskRef.dataProvider!,
            decode: nil,
            shouldInterpolate: false
            )!
        let maskedImageRef = self.cgImage!.masking(mask)!
        let maskedImage = UIImage(cgImage: maskedImageRef)
        
        return maskedImage
    }
}

private class _UIImageHelper {
    static let `default` = _UIImageHelper()
    
    var _maskImages = [String:UIImage]()
    func getMaskImage(with size:CGSize, for cornerRadius:CGFloat)->UIImage{
        let key = size.debugDescription+cornerRadius.description
        if let maskImage = _maskImages[key] {return maskImage}
        
        let imageBounds = CGRect(origin: .zero, size: size)
        
        //Create a context to mask the image.
        let path = UIBezierPath(roundedRect: imageBounds, cornerRadius: cornerRadius)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.black.setFill()
        path.fill()
        
        //Get a mask image from current context.
        let newMaskImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        _maskImages[key] = newMaskImage
        
        return newMaskImage
    }
}

class UIImageEditingConfig {
    var size:CGSize
    var padding:CGFloat = 0
    var cornerRadius:CGFloat?
    
    var shadowColor:UIColor?
    var shadowRadius:CGFloat?
    var shadowOffset:CGSize?
    var shadowOpacity:Float?
    
    var borderColor:UIColor?
    var borderWidth:CGFloat?
    
    var blurRadius:CGFloat?
    var blurOffset:CGSize?
    var blurDiffusion:CGFloat?
    
    private var _rawImage:UIImage
    
    init(image: UIImage, for size:CGSize) {
        self._rawImage = image
        self.size = size
    }
}
extension UIImageEditingConfig{
    func setPadding(_ padding:CGFloat)->UIImageEditingConfig{
        self.padding = padding
        
        return self
    }
    func setBorder(_ color: UIColor, width: CGFloat)->UIImageEditingConfig{
        self.borderColor = color
        self.borderWidth = width
        
        return self
    }
    func setCorner(_ radius:CGFloat)->UIImageEditingConfig{
        self.cornerRadius = radius
        
        return self
    }
    func setShadow(_ color: UIColor,radius: CGFloat?=nil,offset: CGSize?=nil,opacity:Float?=nil)->UIImageEditingConfig{
        self.shadowColor = color
        self.shadowRadius = radius
        self.shadowOffset = offset
        self.shadowOpacity = opacity
        
        return self
    }
    func setBlur(_ radius:CGFloat, offset:CGSize = .zero, diffusion: CGFloat?=nil)->UIImageEditingConfig{
        self.blurRadius = radius
        self.blurOffset = offset
        self.blurDiffusion = diffusion
        
        return self
    }
}
extension UIImageEditingConfig{
    func rendered()->UIImage{
        return _rawImage.cornerRadiused(
            cornerRadius ?? 0, size: size,padding: padding,
            borderColor:borderColor,borderWidth:borderWidth,
            shadowColor: shadowColor, radius: shadowRadius, offset: shadowOffset, opacity: shadowOpacity,
            blurRadius: blurRadius,blurOffset: blurOffset, blurDiffusion: blurDiffusion
        )
    }
}
extension UIImage{
    func editable(for size: CGSize)->UIImageEditingConfig{
        return UIImageEditingConfig(image: self,for: size)
    }
}

extension UIImage{
    
    /// objC時代最大の遺品にして現役
    func cornerRadiused(
        _ cornerRadius:CGFloat,size targetSize: CGSize,padding:CGFloat? = nil,
        borderColor:UIColor?=nil,borderWidth:CGFloat?=nil,
        shadowColor:UIColor?=nil, radius:CGFloat?=nil,offset: CGSize?=nil,opacity:Float?=nil,
        blurRadius:CGFloat?=nil,blurOffset:CGSize?=nil,blurDiffusion:CGFloat?=nil
        )->UIImage{
        var targetSize:CGSize = targetSize
        let aspect = self.size.width / self.size.height
        if targetSize.width/aspect <= targetSize.height{
            targetSize = CGSize(width: targetSize.width, height: targetSize.width/aspect)
        }else{
            targetSize = CGSize(width: targetSize.height * aspect,height: targetSize.height)
        }
        
        let scale = UIScreen.main.scale
        let padding = (padding ?? 0)*2*scale
        let imageSize = CGSize(width: targetSize.width*scale-padding, height: targetSize.height*scale-padding)
        
        let baseLayer = CALayer()
        baseLayer.frame.size = imageSize
        
        if let blurRadius = blurRadius{
            let blurLayer = CALayer()
            let radius = blurRadius*self.size.width*0.003
            let blurPadding = (radius+(blurDiffusion ?? 0)) * scale * 2
            blurLayer.frame.size = CGSize(width: imageSize.width+blurPadding, height: imageSize.height+blurPadding)
            blurLayer.frame.origin = CGPoint(
                x: (blurOffset?.width  ?? 0)-blurPadding/2+padding/2,
                y: (blurOffset?.height ?? 0)-blurPadding/2+padding/2
            )
            
            let context = CIContext(options: nil)
            
            let currentFilter = CIFilter(name: "CIGaussianBlur")
            let beginImage = CIImage(image: self)
            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter!.setValue(radius, forKey: kCIInputRadiusKey)
            
            let output = currentFilter!.outputImage
            let cgimg = context.createCGImage(output!, from: output!.extent)
            blurLayer.contents = cgimg
            
            baseLayer.addSublayer(blurLayer)
        }
        
        let imageLayer = CALayer()
        imageLayer.masksToBounds = true
        if borderColor != nil{
            imageLayer.borderColor = borderColor!.cgColor
        }
        if borderWidth != nil{
            imageLayer.borderWidth = borderWidth!*scale
        }
        imageLayer.cornerRadius = cornerRadius*scale
        imageLayer.frame.size = imageSize
        imageLayer.contents = self.cgImage
        
        if shadowColor == nil && radius == nil && offset == nil && opacity == nil{
            imageLayer.frame.origin = CGPoint(x: padding/2, y: padding/2)
            baseLayer.addSublayer(imageLayer)
        }else{
            let shadowLayer = CALayer()
            shadowLayer.frame.size = imageSize
            shadowLayer.frame.origin = CGPoint(x: padding/2, y: padding/2)
            
            if let shadowColor = shadowColor{
                shadowLayer.shadowPath = UIBezierPath(roundedRect: baseLayer.bounds, cornerRadius: cornerRadius*scale).cgPath
                shadowLayer.shadowColor = shadowColor.cgColor
            }
            if let radius = radius{
                shadowLayer.shadowRadius = radius
            }
            if let offset = offset{
                shadowLayer.shadowOffset = offset
            }
            if let opacity = opacity{
                shadowLayer.shadowOpacity = opacity
            }
            
            baseLayer.addSublayer(shadowLayer)
            shadowLayer.addSublayer(imageLayer)
        }
        
        UIGraphicsBeginImageContext(targetSize*scale)
        let context = UIGraphicsGetCurrentContext()!
        
        baseLayer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
}

