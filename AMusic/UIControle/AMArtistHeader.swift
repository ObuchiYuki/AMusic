import UIKit
import MarqueeLabel

class AMArtistHeader: UICollectionReusableView {
    var title:String? {
        get{return titleLabel.text}
        set{titleLabel.text = newValue}
    }
    var subtitle:String? {
        get{return subtitleLabel.text}
        set{subtitleLabel.text = newValue}
    }
    var cover:UIImage? {
        get{return imageView.image}
        set{self.imageView.image = newValue}
    }
    private func setup(){
        NotificationCenter.default.addObserver(forName: .AMColorThemeManagerDidChangeTheme){[weak self] in
            let palette = ColorPalette.current
            self?.titleLabel.textColor = palette.textColor
            self?.subtitleLabel.textColor = palette.subTextColor
            self?.vebView.effect = UIBlurEffect(style: palette.blurStyle == .light ? .extraLight : .dark)
            self?.shadowView.shadowColor = palette.invercedColor
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBOutlet private weak var shadowView: IBView!
    @IBOutlet private weak var vebView: UIVisualEffectView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: MarqueeLabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
}
