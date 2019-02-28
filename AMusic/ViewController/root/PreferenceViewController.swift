import UIKit

class PreferenceViewController: NPTableViewContoller {
    
}
class PreferenceHandler:NSObject, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBAction func didSwitchChange(_ sender: UISwitch){
        switch sender.accessibilityIdentifier {
        case "is_effect_on":
            Preference.default.isEffectOn = sender.isOn
        case "enable_dark_theme":
            if sender.isOn{
                ColorThemeManager.default.changeColorTheme(with: .dark)
            }else{
                ColorThemeManager.default.changeColorTheme(with: .default)
            }
        default: break
        }
    }
    var tintColors:[ColorPalette.TintColor] = ColorPalette.TintColor.allCollection
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ColorThemeManager.default.setTintColor(with: tintColors[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.viewWithTag(2)?.backgroundColor = tintColors[indexPath.row].main
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
}
