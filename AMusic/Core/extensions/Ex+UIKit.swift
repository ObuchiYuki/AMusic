import UIKit

// MARK: - Extensions for UIView

extension UIView {
    
    /// Capture UIView as UIIImage.
    ///
    /// - Parameter rect: capture rect
    /// - Returns: Captured Image
    func getScreenShot(in rect:CGRect) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return capturedImage
    }
    func allSubviews<T : UIView>(of type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count > 0 else {return}
            view.subviews.forEach{getSubview(view: $0)}
        }
        getSubview(view: self)
        return all
    }
}
private extension UIView{
    func searchVisualEffectsSubview() -> UIVisualEffectView?{
        if let visualEffectView = self as? UIVisualEffectView{
            return visualEffectView
        }else{
            for subview in subviews{
                if let found = subview.searchVisualEffectsSubview(){
                    return found
                }
            }
        }
        
        return nil
    }
}
extension UIButton{
    func setImage(_ image:UIImage , with tintColor:UIColor){
        self.setImage(image.maskable, for: .normal)
        self.imageView?.tintColor = tintColor
    }
}
extension UIImageView{
    func setImage(_ image:UIImage , with tintColor:UIColor){
        self.image = image.maskable
        self.tintColor = tintColor
    }
}

extension UIViewController {
    func safePerformSegue(withIdentifier identifier: String, sender: Any?){
        if canPerformSegue(id: identifier){
            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    func canPerformSegue(id: String) -> Bool {
        let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject]
        let filtered = segues?.filter{ $0.value(forKey: "identifier") as? String == id } ?? []
        return filtered.count > 0
    }
}


extension UIAlertController{
    func addCancel(_ completion: (() -> Void )? = nil){
        self.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel){_ in completion?()})
    }
    func addAction(
        title:String,subTitle:String? = nil,style:UIAlertActionStyle = .default,image:UIImage? = nil,titleAlignment:NSTextAlignment? = nil,_ handler:@escaping ()->Void
    ){
        let action = UIAlertAction(title: title, style: style, handler: {_ in handler()})
        
        if let image = image{
            action.setValue(image, forKey: "_image")
            if titleAlignment == nil{
                action.setValue(NSTextAlignment.left.rawValue, forKey: "_titleTextAlignment")
            }
        }
        if let subTitle = subTitle{
            action.setValue(subTitle, forKey: "__descriptiveText")
        }
        if let titleAlignment = titleAlignment{
            action.setValue(titleAlignment.rawValue, forKey: "_titleTextAlignment")
        }
        
        self.addAction(action)
    }
}

// MARK: - Extensions for UITableView
extension UITableView{
    
    /// Scrolls the table view to the top.
    /// The display will collapse with the scrolling view method.
    ///
    /// - Parameter animated: Flag Animated.
    func scrollToTop(animated: Bool){
        self.scrollToRow(at: [0,0], at: .top, animated: animated)
    }
}

// MARK: - Extensions for UISlider
extension UISlider{
    func prepareForTintColorChanging(){
        let minTrackView = self.value(forKey: "_minValueImageView") as! UIImageView
        let maxTrackView = self.value(forKey: "_maxValueImageView") as! UIImageView
        
        minTrackView.image = minTrackView.image?.maskable
        maxTrackView.image = maxTrackView.image?.maskable
    }
    /// Set tint color to minTrackView and minTrackView.
    ///
    /// - Parameter color: Tint color for minTrackView and minTrackView.
    func setIconTintColor(_ color:UIColor){
        let minTrackView = self.value(forKey: "_minValueImageView") as! UIImageView
        let maxTrackView = self.value(forKey: "_maxValueImageView") as! UIImageView
        
        minTrackView.tintColor = color
        maxTrackView.tintColor = color
    }
}


// MARK: - Extensions for UIViewController
extension UIViewController{
    /// Make it possible to execute the Dissmiss method from StoryBoard.
    @IBAction func dismiss(){
        self.dismiss(animated: true)
    }
}

// MARK: - Extensions for UINavigationBar
class IBNavigationBar:UINavigationBar{
    /// Call Private Api to hide the Separator of NavigationBar.
    @IBInspectable var isSeparatorHidden:Bool{
        set{self.setValue(newValue, forKey: "hidesShadow")}
        get{return self.value(forKey: "hidesShadow") as! Bool}
    }
}

// MARK: - Extensions for UINavigationController
extension UINavigationController{
    /// Call Private Api to hide the Separator of NavigationBar.
    var isSeparatorHidden:Bool{
        set{self.navigationBar.setValue(newValue, forKey: "hidesShadow")}
        get{return self.navigationBar.value(forKey: "hidesShadow") as! Bool}
    }
}








