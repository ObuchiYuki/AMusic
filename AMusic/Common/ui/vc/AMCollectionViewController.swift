import UIKit

class AMCollectionViewController: UICollectionViewController {
    private let kCellCornerRadius:CGFloat = 20
    private let tableViewIndex = UITableViewIndexWrapper()
    private let kAlbumCellIdentifier = "album_cell"
    
    var useHeader:Bool = true{
        didSet{
            flowLayout.headerReferenceSize = useHeader ? CGSize(width: view.bounds.width, height: 50) : .zero
        }
    }
    private static var unloadImage:UIImage = {
       return UIImage.colorImage(color: UIColor.lightGray.a(0.5), size: [1, 1])
        .editable(for: CellLayoutProvider.default.imageSize)
        .setPadding(5)
        .setCorner(20)
        .rendered()
    }()
    var isAdjustInsetWithFloatingView = true{
        willSet{
            if newValue {
                self.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight
            }else{
                self.additionalSafeAreaInsets.bottom = 0
            }
        }
    }
    func collectionView(_ model: AMLongPressViewModel, willShowLongPressViewFor indexPath: IndexPath)->AMLongPressViewModel?{return nil}
    func didHeaderPlayButtonPush(){}
    func didHeaderShuffleButtonPush(){}
    func didSelect(itemAt indexPath: IndexPath){
        safePerformSegue(withIdentifier: "default", sender: indexPath)
    }
    func willMove(to destination:UIViewController,with indexPath: IndexPath){}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath{
            willMove(to: segue.destination,with: indexPath)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(itemAt: indexPath)
    }
    private func indexChangedHandler(to index:String){
        guard let collectionView = collectionView else {return}
        var indexPathToMove:IndexPath? = nil
        var firstReach = false
        
        for_all: for section in 0...collectionView.numberOfSections-1{
            for row in 0...collectionView.numberOfItems(inSection: section)-1{
                let indexPath = IndexPath(row: row, section: section)
                guard var title = self.collectionView(collectionView, titleForCellAt: indexPath) else {return}
                title = title.trimmingCharacters(in: .whitespaces)
                title = title.lowercased()
                
                if title.isEmpty {continue}
                if title.first == "a" {firstReach = true}
                if !firstReach {continue}
                
                print(title, index,title >= index)
                if title.lowercased() >= index{
                    indexPathToMove = indexPath
                    break for_all
                }
            }
        }
        guard let indexPath = indexPathToMove else {return}
        collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
    }
    func enableIndexIfNeeded(){
        guard let collectionView = collectionView else {return}
        let totalCellCount = (0...collectionView.numberOfSections-1).map{collectionView.numberOfItems(inSection: $0)}.reduce(0, +)
        if totalCellCount <= 20 {return}
        
        let tableViewIndexWidth:CGFloat = 15
        let tableViewIndexheight:CGFloat = collectionView.frame.height - 150
        
        tableViewIndex.view.frame = CGRect(
            origin: [UIScreen.main.bounds.width - tableViewIndexWidth , 100],
            size: [tableViewIndexWidth, tableViewIndexheight]
        )
        tableViewIndex.titles = UILocalizedIndexedCollation.current().sectionIndexTitles
        tableViewIndex.addTarget{[weak self] index in
            guard let index = index else {return}
            self?.indexChangedHandler(to: index)
        }
        tableViewIndex.view.backgroundColor = .clear
        
        self.view.addSubview(tableViewIndex.view)
    }
    override func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if useHeader{
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "header",
                for: indexPath
            ) as! AMToggleHeader
            header.setActions(play: {[weak self] in self?.didHeaderPlayButtonPush()}){[weak self] in self?.didHeaderShuffleButtonPush()}
            return header
        }else{
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if useHeader{
            return [view.bounds.width, 50]
        }else{
            return [0, 0]
        }
    }
    func collectionView(_ collectionView: UICollectionView, titleForCellAt indexPath: IndexPath) -> String? {return nil} 
    func collectionView(_ collectionView: UICollectionView, didItemLongPressAt indexPath: IndexPath) {
        if let model = self.collectionView(AMLongPressViewModel(), willShowLongPressViewFor: indexPath){
            self.present(AMLongPressViewManager.newVC(model: model), animated: true)
        }
    }
    func getAlbumCell(at indexPath:IndexPath)->AMAlbumCell{
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: kAlbumCellIdentifier, for: indexPath) as! AMAlbumCell
        let palette = ColorPalette.current
        
        cell.cover = AMCollectionViewController.unloadImage
        cell.indexPath = indexPath
        cell.titleLable.textColor = palette.textColor
        cell.subtitleLable.textColor = palette.subTextColor
        
        return cell
    }
    func colorThemeDidChange(with palette:ColorPalette){
        self.collectionView?.backgroundColor = palette.backgroundColor
    }
    func reloadAll(){}
    var flowLayout:UICollectionViewFlowLayout{
        return (collectionViewLayout as! UICollectionViewFlowLayout)
    }
    @objc private func didLongPress(sender: UILongPressGestureRecognizer){
        let position = sender.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: position) {
            self.collectionView(collectionView!, didItemLongPressAt: indexPath)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorThemeDidChange(with: ColorPalette.current)
        collectionView?.register(UINib(nibName: "AMAlbumCell", bundle: .main), forCellWithReuseIdentifier: kAlbumCellIdentifier)
        collectionView?.register(
            UINib(nibName: "AMToggleHeader", bundle: .main),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        
        let m = CellLayoutProvider.default.margin
        flowLayout.itemSize = CellLayoutProvider.default.cellSize
        flowLayout.minimumInteritemSpacing = CellLayoutProvider.default.margin
        flowLayout.minimumLineSpacing = CellLayoutProvider.default.margin
        flowLayout.sectionInset = UIEdgeInsets(top: m, left: m, bottom: m, right: m)
        flowLayout.headerReferenceSize = [view.bounds.width, 50]
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AMCollectionViewController.didLongPress))
        self.collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        
        if PlaylistEditingManager.default.isEditing{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(AMCollectionViewController.playlistEndEditing)
            )
        }
        NotificationCenter.default.addObserver(
        forName: .AMColorThemeManagerDidChangeTheme, object: nil, queue: .main){[weak self] _ in
            guard let weakSelf = self else {return}
            weakSelf.collectionView?.reloadVisibleCells()
            UIView.animate(withDuration: ColorThemeManager.fadeDuration){
                weakSelf.colorThemeDidChange(with: ColorPalette.current)
            }
        }
        NotificationCenter.default.addObserver(
        forName: .ADMediaLibraryItemDidChange, object: nil, queue: .main){[weak self] _ in
            self?.reloadAll()
            self?.collectionView?.reloadData()
        }
        if self.isAdjustInsetWithFloatingView {
            self.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight
        }
        NotificationCenter.default.addObserver(forName: .AMFloatingViewsManagerFloatingItemDidChange, object: nil, queue: .main){[weak self] _ in
            if self?.isAdjustInsetWithFloatingView ?? false{
                self?.additionalSafeAreaInsets.bottom = FloatingViewsManager.default.totalHeight
            }
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    @objc func playlistEndEditing(){
        PlaylistEditingManager.default.endEditing()
    }
}
private extension UICollectionView{
    func reloadVisibleCells(){
        self.reloadItems(at: visibleCells.map{indexPath(for: $0)!})
    }
}




