import UIKit

protocol FloatingViewType{
    var instance:UIView {get}
    var viewHeight:CGFloat {get}
    var primary:Int {get}
    var floatingViewIdentifier:String {get}
}

class FloatingViewsManager {
    static let `default` = FloatingViewsManager()
    
    var totalHeight:CGFloat{return _floatingViews.map{$0.viewHeight}.reduce(0, +)}
    var floatingViews:[UIView]{return _floatingViews.map{$0.instance}}
    
    private var _floatingViews:[FloatingViewType] = []
    
    func showAll(){
        for floatingView in floatingViews{
            UIView.animate(withDuration: 0.3){
                floatingView.transform = CGAffineTransform(translationX: 0, y: 0)
                floatingView.alpha = 1
            }
        }
    }
    func hideAll(){
        for floatingView in floatingViews{
            UIView.animate(withDuration: 0.3){
                floatingView.transform = CGAffineTransform(translationX: 0, y: self.totalHeight)
                floatingView.alpha = 0
            }
        }
    }
    func update(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001){
            var totalHeight:CGFloat = 0
            let tabBarHeight = (UIWindow.main.rootViewController as! UITabBarController).tabBar.frame.height
            for view in self.floatingViews.filter({!UIWindow.main.subviews.contains($0)}){
                let origin = CGPoint(x: 0, y: UIScreen.main.bounds.height-tabBarHeight-totalHeight-view.frame.height)
                view.frame.origin = origin
                UIWindow.main.rootViewController!.view.addSubview(view)
                totalHeight += view.frame.height
            }
            NotificationCenter.default.post(name: .AMFloatingViewsManagerFloatingItemDidChange, object: nil)
        }
    }
    
    func addFloatingView(with view:FloatingViewType){
        let ids = _floatingViews.map{$0.floatingViewIdentifier}
        if !ids.contains(view.floatingViewIdentifier){
            _floatingViews.append(view)
            update()
        }
    }
    func removeView(with identifier:String){
        _floatingViews = _floatingViews.filter{$0.floatingViewIdentifier != identifier}
        update()
    }
}
extension Notification.Name{
    static let AMFloatingViewsManagerFloatingItemDidChange = Notification.Name("AMFloatingViewsManagerFloatingItemDidChange")
}
