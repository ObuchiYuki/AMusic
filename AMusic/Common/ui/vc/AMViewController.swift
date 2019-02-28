import UIKit

class AMViewController: UIViewController{
    func colorThemeDidChange(with palette:ColorPalette){}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorThemeDidChange(with: ColorPalette.current)
        NotificationCenter.default.addObserver(forName: .AMColorThemeManagerDidChangeTheme){[weak self] in
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                self?.colorThemeDidChange(with: ColorPalette.current)
            }
        }
    }
}

