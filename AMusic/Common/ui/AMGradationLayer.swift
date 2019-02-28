import UIKit

class AMGradationLayer: CAGradientLayer{
    enum Direction{
        case horizontal,vartical
    }
    
    var direction:Direction = .vartical{
        didSet{setup(size: .zero , direction: direction)}
    }
    private func colorSetup(direction:Direction = .horizontal){
        if direction == .horizontal{
            startPoint = [1,1]
            endPoint = [0,1]
        }
        colors = [ColorPalette.current.tintColor.sub.cgColor,ColorPalette.current.tintColor.main.cgColor]
    }
    private func setup(size:CGSize = .zero, direction:Direction = .horizontal){
        self.colorSetup(direction: direction)
        
        self.frame.size = size
        
        NotificationCenter.default.addObserver(forName: .AMColorThemeManagerDidChangeTheme){[weak self] in
            self?.colorSetup(direction: direction)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override init() {
        super.init()
        setup()
    }
    init(size:CGSize = .zero,direction:Direction = .horizontal) {
        super.init()
        setup(size:size,direction:direction)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
}
