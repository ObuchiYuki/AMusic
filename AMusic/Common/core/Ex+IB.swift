import UIKit

extension UISwitch{
    private func _colorThemeDidChange(with palette:ColorPalette){
        self.onTintColor = palette.tintColor.main
        self.thumbTintColor = palette.mainColor
    }
    private struct AssociatedKeys {
        static var descriptiveName = "nsh_DescriptiveName"
    }
    @IBInspectable var isColorThemeObserveEnable:Bool{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if newValue{
                NotificationCenter.default.addObserver(
                forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: nil){[weak self] _ in
                    self?._colorThemeDidChange(with: ColorPalette.current)
                }
            }else{
                NotificationCenter.default.removeObserver(self)
            }
        }
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName) as! Bool
        }
    }
}
