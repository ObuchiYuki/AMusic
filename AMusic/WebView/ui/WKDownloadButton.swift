import UIKit

/// WebViewNaviItem
/// NaviBarItem with music icon.
class WKDownloadButton: UIBarButtonItem {
    // MARK: APIs
    func setAction(_ action:@escaping ()->Void){
        innerView.setAction(action)
    }
    func setPopingState(_ on:Bool){
        innerView.isPoping = on
    }
    
    // MARK: Private Properties
    private let innerView = _WebViewNaviItemInnerView()
    
    // MARK: Private Methods
    private func _setup(){
        self.customView = innerView
    }
    
    // MARK: Init
    override init() {
        super.init()
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
}

///_WebViewNaviItemInnerView (private class)
///Inner View with animation button.
private class _WebViewNaviItemInnerView:UIButton{
    // MARK: API
    var isPoping = false{
        didSet{
            checkState()
        }
    }
    func setAction(_  action:@escaping ()->Void){
        self._action = action
    }
    func startPoping(){
        isPoping = true
        checkState()
    }
    func endPoping(){
        isPoping = false
        checkState()
    }
    
    // MARK: Private Properties
    private var _action = {}
    private var _imageView:UIImageView!
    private var _isAnimating = false
    private let kAnimationDur = 0.3
    private let kTranceformTranslation:CGFloat = 10
    private var cTintColor:UIColor{return ColorPalette.current.tintColor.main}
    
    // MARK: Private Methods
    private func startPopAnimation(){
        if _isAnimating {return}
        _isAnimating = true
        self._runPopingAnimation()
    }
    private func _runPopingAnimation(){
        UIView.animate(withDuration: kAnimationDur,delay: 0.0, options: .curveEaseOut, animations: {
            self._imageView.transform = CGAffineTransform(translationX: 0, y: -self.kTranceformTranslation)
        })
        UIView.animate(withDuration: kAnimationDur,delay: kAnimationDur, options: .curveEaseIn, animations: {
            self._imageView.transform = CGAffineTransform(translationX: 0, y: 0)
        }){_ in
            if self.isPoping{///Continue...
                self._runPopingAnimation()
            }else{
                self._isAnimating = false
            }
        }
    }
    private func checkState(){
        if isPoping{
            UIView.animate(withDuration: kAnimationDur){
                self._imageView.tintColor = .white
                self._imageView.backgroundColor = self.cTintColor
            }
            startPopAnimation()
        }else{
            UIView.animate(withDuration: kAnimationDur){
                self._imageView.tintColor = self.cTintColor
                self._imageView.backgroundColor = .white
            }
        }
    }
    
    override var tintColor: UIColor!{
        set{
            super.tintColor = newValue
            self._imageView.tintColor = newValue
            _imageView.layer.borderColor = newValue.cgColor
        }
        get{return super.tintColor}
    }
    
    @objc private func didPush(){
        self._action()
    }
    //MARK: Setup
    private func _setup(){
        self.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        
        _imageView = UIImageView(frame: CGRect(origin: CGPoint(x: -10, y: -15), size: CGSize(width: 50, height: 50)))
        _imageView.image = #imageLiteral(resourceName: "musicBox").resized(toFit: CGSize(width: 27, height: 27)).maskable
        _imageView.tintColor = self.cTintColor
        _imageView.backgroundColor = .white
        _imageView.contentMode = .center
        _imageView.layer.cornerRadius = _imageView.frame.height/2
        _imageView.clipsToBounds = true
        _imageView.layer.borderColor = cTintColor.cgColor
        _imageView.layer.borderWidth = 2
        
        self.addTarget(self, action: #selector(_WebViewNaviItemInnerView.didPush), for: .touchUpInside)
        self.addSubview(_imageView)
        
    }
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
}








