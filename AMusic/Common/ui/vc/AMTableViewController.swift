import UIKit

class AMTableViewController: UITableViewController{
    var isAdjustInsetWithFloatingView = true{
        willSet{
            if newValue {
                self.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight
            }else{
                self.additionalSafeAreaInsets.bottom = 0
            }
        }
    }
    func reloadAll(){}
    var useAlternatelyCell = true
    func colorThemeDidChange(with palette:ColorPalette){
        self.tableView.backgroundColor = palette.backgroundColor
        self.tableView.sectionIndexColor = palette.subTextColor
        self.view.backgroundColor = palette.backgroundColor
    }
    func getCurrentColorThemedCell(withIdentifier identifier:String,for indexPath: IndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return adjustCellToColorTheme(cell, for: indexPath, with: identifier)
    }
    func adjustCellToColorTheme(_ cell:UITableViewCell,for indexPath:IndexPath,with identifier:String = "nil")->UITableViewCell{
        let palette = ColorPalette.current
        if useAlternatelyCell{
            if indexPath.row%2 == 1 || identifier == "all_items_cell"{
                if ColorPalette.current.colorType == .dark{
                    cell.backgroundColor = palette.cellBackgroundColor.add(overlay: UIColor.white.withAlphaComponent(0.04))
                }else{
                    cell.backgroundColor = palette.cellBackgroundColor.add(overlay: UIColor.black.withAlphaComponent(0.025))
                }
            }else{
                cell.backgroundColor = palette.cellBackgroundColor
            }
        }else{
            cell.backgroundColor = ColorPalette.current.cellBackgroundColor
        }
        
        cell.selectedBackgroundView =  UIView()
        cell.selectedBackgroundView?.backgroundColor = ColorPalette.current.cellSelectedColor
        
        for subview in cell.contentView.subviews{
            if let label = subview as? UILabel{
                label.highlightedTextColor = .white
                if label.font.pointSize >= 17{
                    label.textColor = ColorPalette.current.textColor
                }else{
                    label.textColor = ColorPalette.current.subTextColor
                }
            }else if let imageView = subview as? IBImageView{
                imageView.layer.borderColor = ColorPalette.current.separationColor.cgColor
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorThemeDidChange(with: ColorPalette.current)
        if useAlternatelyCell{
            self.tableView.separatorColor = .clear
        }
        self.tableView.register(UINib(nibName: "AMAllItemsCell", bundle: nil), forCellReuseIdentifier: "all_items_cell")
        if PlaylistEditingManager.default.isEditing{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(AMTableViewController.playlistEndEditing)
            )
        }
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: .main){[weak self] _ in
            guard let weakSelf = self else {return}
            weakSelf.tableView.reloadRows(
                at: weakSelf.tableView.visibleCells.map{weakSelf.tableView.indexPath(for: $0)!}, with: .fade
            )
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                weakSelf.colorThemeDidChange(with: ColorPalette.current)
            }
        }
        NotificationCenter.default.addObserver(
        forName: .ADMediaLibraryItemDidChange, object: nil, queue: .main){[weak self] _ in
            self?.reloadAll()
            self?.tableView.reloadData()
        }
        if self.isAdjustInsetWithFloatingView {
            if #available(iOS 11.0, *){self.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight}
        }
        NotificationCenter.default.addObserver(forName: .AMFloatingViewsManagerFloatingItemDidChange, object: nil, queue: .main){[weak self] _ in
            if self?.isAdjustInsetWithFloatingView ?? false{
                if #available(iOS 11.0, *){self?.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight}
            }
        }
    }
    @objc func playlistEndEditing(){
        PlaylistEditingManager.default.endEditing()
    }
}
