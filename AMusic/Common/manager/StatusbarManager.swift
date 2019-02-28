import UIKit

class StatusbarManager {
    // MARK: - Singleton
    static let `default` = StatusbarManager()
    
    // MARK: - APIs
    var style:UIStatusBarStyle = .default{
        didSet{
            //UIApplication.shared.statusBarStyle = style            
        }
    }
    func resetStatusbar(){
        UIApplication.shared.statusBarStyle = self._getStatusBarStyleForCurrentPalette()
    }
    
    // MARK: - Private Methods
    private func _getStatusBarStyleForCurrentPalette()->UIStatusBarStyle{///なげえよ...
        if ColorPalette.current.colorType == .dark{
            return .lightContent
        }else{
            return .default
        }
    }
    
    func initialize(){
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: nil){[weak self] _ in
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                self?.resetStatusbar()
            }
        }
    }
}
