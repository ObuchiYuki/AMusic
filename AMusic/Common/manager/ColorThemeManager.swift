import UIKit

/// 所謂　ColorThemeManager
class ColorThemeManager{
    static let fadeDuration = 0.4
    static let `default` = ColorThemeManager()
    fileprivate var currentPalette:ColorPalette = .default
    func setTintColor(with tintColor:ColorPalette.TintColor){
        var palette = currentPalette
        palette.tintColor = tintColor
        if palette.colorType == .light{
            palette.cellSelectedColor = tintColor.main
        }
        changeColorTheme(with: palette)
    }
    func changeColorTheme(with palette:ColorPalette){
        currentPalette = palette
        NotificationCenter.default.post(name: .AMColorThemeManagerDidChangeTheme, object: nil)
        
        UIWindow.main.tintColor = palette.tintColor.main
        UIView.appearance().tintColor = palette.tintColor.main
    }
}

extension Notification.Name{
    static let AMColorThemeManagerDidChangeTheme = Notification.Name(rawValue: "AMColorThemeManagerDidChangeTheme")
}

struct ColorPalette{
    enum ColorType {
        case dark,light
    }
    struct TintColor {
        var main:UIColor
        var sub:UIColor
    }
    var id:UUID
    
    var tintColor:TintColor
    
    var mainColor:UIColor
    var invercedColor:UIColor
    var backgroundColor:UIColor
    var textColor:UIColor
    var subTextColor:UIColor
    var cellBackgroundColor:UIColor
    var cellSelectedColor:UIColor
    var separationColor:UIColor
    var navigationColor:UIColor?
    
    var groupeTableViewColor:UIColor
    
    var colorType:ColorType
}

extension ColorPalette{
    var naviBarStyle:UIBarStyle{return colorType == .dark ? .black : .default}
    var tabBarStyle:UIBarStyle{return colorType == .dark ? .black : .default}
    var blurStyle:UIBlurEffectStyle{return colorType == .dark ? .dark : .light}
    var indicatorStyle:UIActivityIndicatorViewStyle{return colorType == .dark ? .white : .gray}
    var keybordStyle:UIKeyboardAppearance{return colorType == .dark ? .dark : .default}
}

extension ColorPalette{
    static var current:ColorPalette{
        return ColorThemeManager.default.currentPalette
    }
}

extension ColorPalette.TintColor{
    static let framboise =  ColorPalette.TintColor(main: #colorLiteral(red: 1, green: 0.3386275172, blue: 0.4996665716, alpha: 1), sub: #colorLiteral(red: 0.9851529002, green: 0.1308721602, blue: 0.4081004858, alpha: 1))
    static let orange =     ColorPalette.TintColor(main: #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1), sub: #colorLiteral(red: 1, green: 0.368627451, blue: 0.2274509804, alpha: 1))
    static let lemon =      ColorPalette.TintColor(main: #colorLiteral(red: 1, green: 0.8588235294, blue: 0.2980392157, alpha: 1), sub: #colorLiteral(red: 1, green: 0.8039215686, blue: 0.007843137255, alpha: 1))
    static let macha =      ColorPalette.TintColor(main: #colorLiteral(red: 0.5294117647, green: 0.9882352941, blue: 0.4392156863, alpha: 1), sub: #colorLiteral(red: 0.0431372549, green: 0.8274509804, blue: 0.09411764706, alpha: 1))
    static let pistàcchio = ColorPalette.TintColor(main: #colorLiteral(red: 0.3215686275, green: 0.9294117647, blue: 0.7803921569, alpha: 1), sub: #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9843137255, alpha: 1))
    static let sea =        ColorPalette.TintColor(main: #colorLiteral(red: 0.1019607843, green: 0.8392156863, blue: 0.9921568627, alpha: 1), sub: #colorLiteral(red: 0.1137254902, green: 0.3843137255, blue: 0.9411764706, alpha: 1))
    static let sky =        ColorPalette.TintColor(main: #colorLiteral(red: 0.1137254902, green: 0.4666666667, blue: 0.937254902, alpha: 1), sub: #colorLiteral(red: 0.5058823529, green: 0.9529411765, blue: 0.9921568627, alpha: 1))
    static let grape =      ColorPalette.TintColor(main: #colorLiteral(red: 0.7764705882, green: 0.2666666667, blue: 0.9882352941, alpha: 1), sub: #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8392156863, alpha: 1))
    static let sesame =     ColorPalette.TintColor(main: #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), sub: #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1))
    
    static var allCollection: [ColorPalette.TintColor]{
        return [framboise,orange,lemon,macha,pistàcchio,sea,sky,grape,sesame]
    }
}

extension ColorPalette: IDEquatable{}

extension ColorPalette{
    static let `default` = ColorPalette(
        id: UUID(),
        
        tintColor:              .framboise,
    
        mainColor:              .white,
        invercedColor:          .black,
        backgroundColor:        .white,
        textColor:              UIColor(hex: 0x333333),
        subTextColor:           UIColor(hex: 0xaaaaaa),
        cellBackgroundColor:    .white,
        cellSelectedColor:      TintColor.framboise.main,
        separationColor:        UIColor(hex: 0xc8c7cc),
        navigationColor:        .white,
    
        groupeTableViewColor:#colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1),
    
        colorType:              .light
    )
    
    static let dark = ColorPalette(
        id: UUID(),
        
        tintColor:              .framboise,
        
        mainColor:              .black,
        invercedColor:          .white,
        backgroundColor:        UIColor(hex: 0x0D0D0D),
        textColor:              .white,
        subTextColor:           UIColor(hex: 0x8E8E93),
        cellBackgroundColor:    UIColor(hex: 0x171717),
        cellSelectedColor:      UIColor(hex: 0x444444),
        separationColor:        UIColor(hex: 0x333333),
        navigationColor:        .black,
        
        groupeTableViewColor:#colorLiteral(red: 0.02385410666, green: 0.02555504628, blue: 0.02829473838, alpha: 1),
        
        colorType:              .dark
    )
}
