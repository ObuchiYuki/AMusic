import UIKit
import MediaPlayer

class SearchViewController: AMTableViewController {
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var searchResults:[MediaLibrary.SearchResultList] = []
    private var recentSearchHistories:[String] = []
    private var kRecentSearchHistoriesSaveKey = "recent_search_histories"
    
    override func colorThemeDidChange(with palette: ColorPalette) {
        super.colorThemeDidChange(with: palette)
        
        self.navigationController?.navigationBar.barStyle = palette.naviBarStyle
        self.navigationController?.navigationBar.barTintColor = palette.navigationColor
        
        self.tableView.reloadData()
    
        self.searchController.searchBar.keyboardAppearance = palette.keybordStyle
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = palette.textColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationController?.isSeparatorHidden = true
        
        recentSearchHistories = UserDefaults.standard.stringArray(forKey: kRecentSearchHistoriesSaveKey) ?? []
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}


extension SearchViewController: UISearchResultsUpdating ,UISearchBarDelegate{
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        saveCurrentSearch()
    }
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty {
            searchResults = []
            self.tableView.reloadData()
        } else {
            MediaLibrary.default.searchForPreview(with: text){results in
                self.searchResults = results
                self.tableView.reloadData()
            }
        }
    }
    func saveCurrentSearch(){
        searchController.endAppearanceTransition()
        
        if let text = searchController.searchBar.text{
            if text.isEmpty{return}
            if recentSearchHistories.contains(text){
                recentSearchHistories.remove(at: recentSearchHistories.index(of: text)!)
            }
            recentSearchHistories.insert(text,at: 0)
        }
        
        UserDefaults.standard.set(recentSearchHistories, forKey: kRecentSearchHistoriesSaveKey)
    }
}


extension SearchViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchResults.isEmpty{
            let word = recentSearchHistories[indexPath.row]
            self.searchController.searchBar.text = word
            self.searchController.isActive = true
            return
        }
        
        saveCurrentSearch()
        let result = searchResults[indexPath.section].items[indexPath.row]
        
        switch result.type {
        case .artist:
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
            let artist = result.data as! ArtistInfo
            vc.albums = artist.albums
            vc.title = artist.name
            self.navigationController?.pushViewController(vc, animated: true)
        case .album:
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "SingleListViewController") as! SingleListViewController
            let album = result.data as! AlbumInfo
            vc.albums = [album]
            self.navigationController?.pushViewController(vc, animated: true)
        case .song:
            let song = result.data as! MediaItem
            NowPlayingViewController.show().startMusic(list: [song], start: song)
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchResults.isEmpty{return 53}
        return 70
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.separatorStyle = searchResults.isEmpty ? .none : .singleLine
        if searchResults.isEmpty{return recentSearchHistories.isEmpty ? 0 : 1}
        return searchResults.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AMLargeTitleSectionHeaderView()
        if searchResults.isEmpty{
            header.titleLabel.text = "検索履歴"
            header.identifire = "search_history_header"
            header.setAction(with: "削除"){[weak self] id in
                guard let weakSelf = self else {return}
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                sheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
                sheet.addAction(UIAlertAction(title: "検索履歴を削除", style: .default){_ in
                  
                    UserDefaults.standard.set([], forKey: weakSelf.kRecentSearchHistoriesSaveKey)
                    weakSelf.recentSearchHistories = []
                    weakSelf.tableView.reloadData()
                })
                weakSelf.present(sheet, animated: true)
            }
        }else{
            header.titleLabel.text = searchResults[section].title
            header.identifire = searchResults[section].title
            header.setAction(with: "全て見る"){[weak self] id in
                guard let weakSelf = self else {return}
                if let word = weakSelf.searchController.searchBar.text{
                    weakSelf.saveCurrentSearch()
                    let sv = UIStoryboard.main
                    let vc = sv.instantiateViewController(withIdentifier: "SearchFullResultsViewController") as! SearchFullResultsViewController
                    vc.type = weakSelf.searchResults[section].items.first!.type
                    vc.word = word
                    vc.title = "\(word)の検索結果"
                    
                    weakSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        return header
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.isEmpty{return recentSearchHistories.count}
        return searchResults[section].items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.isEmpty{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "search_history_cell", for: indexPath)
            (cell.viewWithTag(1) as! UILabel).text = recentSearchHistories[indexPath.row]
            return cell
        }else{
            let cell = self.getCurrentColorThemedCell(withIdentifier: "cell", for: indexPath)
            let result = searchResults[indexPath.section].items[indexPath.row]
            
            (cell.viewWithTag(1) as! UIImageView).image = result.image
            (cell.viewWithTag(2) as! UILabel).text = result.title
            (cell.viewWithTag(3) as! UILabel).text = result.subtitle
            
            return cell
        }
    }
}
