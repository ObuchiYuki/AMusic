import UIKit

class NPTableViewContoller: UITableViewController {
    private var headerView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let naviHeight = (self.navigationController?.navigationBar.frame.height ?? 0) + 20
        
        headerView = UIView(frame: [0,-naviHeight,UIScreen.main.bounds.width,naviHeight])
        
        self.view.addSubview(self.headerView)
        
        /// Updater
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true){[weak self] timer in
            if self == nil {timer.invalidate();return}
            self?.headerView.removeFromSuperview()
            self?.view.addSubview(self!.headerView)
        }
        
        self.colorThemeDidChange(with: ColorPalette.current)
    }
    func adjustCellToColorTheme(_ cell:UITableViewCell,for indexPath:IndexPath,with identifier:String = "nil")->UITableViewCell{
        let palette = ColorPalette.current
        
        cell.backgroundColor = palette.cellBackgroundColor
        
        cell.selectedBackgroundView =  UIView()
        cell.selectedBackgroundView?.backgroundColor = palette.cellSelectedColor
        
        for subview in cell.contentView.subviews{
            if let label = subview as? UILabel{
                label.highlightedTextColor = .white
                if label.font.pointSize >= 17{
                    label.textColor = palette.textColor
                }else{
                    label.textColor = palette.subTextColor
                }
            }else if let imageView = subview as? IBImageView{
                imageView.layer.borderColor = palette.separationColor.cgColor
            }else if let textField = subview as? UITextField{
                textField.textColor = palette.textColor
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [.foregroundColor : palette.subTextColor])
            }
        }
        return cell
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.frame.origin.y = scrollView.contentOffset.y
    }
    func colorThemeDidChange(with palette:ColorPalette){
        headerView?.backgroundColor = palette.navigationColor
        self.view.backgroundColor = palette.groupeTableViewColor
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return self.adjustCellToColorTheme(cell, for: indexPath)
    }
}







