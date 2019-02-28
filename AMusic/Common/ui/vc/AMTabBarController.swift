import UIKit

/// AMTabBarController

class AMTabBarController:UITabBarController{
    // MARK: - Properties
    // MARK: - APIs
    var currentVC:UIViewController?{return viewControllers?.at(self.selectedIndex)}
    
    /// Method for `moreNavigationController`
    /// Copied from `ADTableViewController`
    private func _customizeCell(cell:UITableViewCell){
        cell.backgroundColor = ColorPalette.current.cellBackgroundColor
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = ColorPalette.current.cellSelectedColor
        
        for subview in cell.contentView.subviews{
            if let label = subview as? UILabel{
                if label.font.pointSize >= 17{
                    label.textColor = ColorPalette.current.textColor
                }else{
                    label.textColor = ColorPalette.current.subTextColor
                }
                label.highlightedTextColor = .white
            }else if let imageView = subview as? IBImageView{
                imageView.borderColor = ColorPalette.current.separationColor
            }
        }
    }
    
    func colorThemeDidChange(with palette:ColorPalette){
        if let barColor = palette.navigationColor{
            self.moreNavigationController.navigationBar.barTintColor = barColor
        }
        self.moreNavigationController.isSeparatorHidden = true
        self.moreNavigationController.navigationBar.barStyle = palette.naviBarStyle

        self.tabBar.barStyle = palette.tabBarStyle
        self.tabBar.barTintColor = palette.mainColor
        
        moreNavigationController.view.backgroundColor = palette.backgroundColor
        if let tableView = moreNavigationController.topViewController?.view as? UITableView{
            for cell in tableView.visibleCells {
                _customizeCell(cell: cell)
            }
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = palette.backgroundColor
            tableView.separatorColor = .clear
            tableView.sectionIndexColor = palette.subTextColor
        }
    }
    // MARK: - Override Methods
    
    ///Scroll To Top when tabbarItem tounched
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let vc = self.viewControllers?.filter({$0.tabBarItem.tag == item.tag}).first else {return}
        guard self.selectedViewController == vc else {return}
        guard let navigationVc = vc as? UINavigationController else {return}
        guard navigationVc.viewControllers.count == 1 else {return}
        if let tableVc = navigationVc.topViewController as? UITableViewController{
            guard !tableVc.tableView.visibleCells.isEmpty else {return}
            tableVc.tableView.scrollToTop(animated: true)
        }else if let collectionVc = navigationVc.topViewController as? UICollectionViewController{
            guard !(collectionVc.collectionView?.visibleCells.isEmpty ?? true) else {return}
            collectionVc.collectionView?.scrollToItem(at: [0, 0], at: .top, animated: true)
        }
    }
    private func mediaLibraryDidChange(){
        viewControllers?.lazy.compactMap{$0 as? UINavigationController}.forEach{$0.popViewController(animated: false)}
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorThemeDidChange(with: ColorPalette.current)
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: nil){[weak self] _ in
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                self?.colorThemeDidChange(with: ColorPalette.current)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ADMediaLibraryItemDidChange){[weak self] in
            self?.mediaLibraryDidChange()
        }
    }
}
