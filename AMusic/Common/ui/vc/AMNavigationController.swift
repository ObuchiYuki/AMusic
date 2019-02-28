import UIKit

class AMNavigationController: UINavigationController {
    func colorThemeDidChange(with palette:ColorPalette){
        self.navigationBar.barTintColor = palette.navigationColor
        self.navigationBar.barStyle = palette.naviBarStyle
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isSeparatorHidden = true
        
        self.colorThemeDidChange(with: ColorPalette.current)
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: nil){[weak self] _ in
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                self?.colorThemeDidChange(with: ColorPalette.current)
            }
        }
    }
}
