import UIKit
import WebKit
import AVFoundation
import HidingNavigationBar

class KVOSample: NSObject{
    @objc dynamic var value:Int = 0
}

class AWWebViewController: AMViewController {
    // MARK: IBOutlet Parts
    @IBOutlet weak var downloadButton: WKDownloadButton!
    @IBOutlet weak var toolBar: UIToolbar!
    
    // MARK: IBActions
    @IBAction func backButtonDidPush(_ sender: Any) {webview.goBack()}
    @IBAction func forwordButtonDidPush(_ sender: Any) {webview.goForward()}
    @IBAction func tabButtonDidPush(_ sender: Any) {
        NotificationManager.default.post(
            "タブボタンが押されたよ。タブボタンが押されたよ。タブボタンが押されたよ。タブボタンが押されたよ。",
            subTitle: "TabButtonDidPush...",
            image:#imageLiteral(resourceName: "cover")
        )
    }
    
    // MARK: Properties
    ///UIs
    private var webview: WKWebView!
    private let searchBar = WebViewSearchBar()
    ///Values
    private var currentAppealingVideoTask:ADDownloadTask?
    private var _observers = [NSKeyValueObservation]()
    private var _hidingNavBarManager: HidingNavigationBarManager?
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self._setupUI()
        self._hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: webview.scrollView)
        webview.load("https://youtube.com".request.raw!)///(仮)
        
        NotificationCenter.default.addObserver(forName: .ADTaskManagerDidTaskAdded, object: nil, queue: .main){notice in
            guard let task = notice.object as? ADDownloadTask else {return}
            self.currentAppealingVideoTask = task
            self.downloadButton.setPopingState(true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        AWWebViewManager.default.cuurentWebView = self.webview
        FloatingViewsManager.default.hideAll()
        _hidingNavBarManager?.viewWillAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        FloatingViewsManager.default.showAll()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        _hidingNavBarManager?.viewDidLayoutSubviews()
        webview.frame = self.view.frame
    }
    override func viewWillDisappear(_ animated: Bool) {
        _hidingNavBarManager?.viewWillDisappear(animated)
    }
    override func colorThemeDidChange(with palette: ColorPalette) {}
    // MARK: Private Methods
    private func _search(with word:String){
        let url = AWSearchManager.default.search(with: word)
        self.webview.load(URLRequest(url: url))
    }
    private func _didURLChange(to url:URL){
        currentAppealingVideoTask = nil
        downloadButton.setPopingState(false)
        searchBar.setURL(url)
    }
    private func _didDownloadButtonPush(){
        guard let task = currentAppealingVideoTask else {return}
        ADTaskManager.default.enableTask(task)
        downloadButton.setPopingState(false)
    }
    // MARK: Setup UIs
    private func _setupUI(){
        _setupNavigationBar()
        _setupWebView()
    }
    private func _setupWebView(){
        webview = WKWebView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-view.safeAreaInsets.bottom-52),
            configuration: AWWebViewManager.default.getConfig()
        )
        webview.allowsBackForwardNavigationGestures = true
        
        _observers.append(webview.observe(\.url, options: .new){_,change in
            guard let _url = change.newValue, let url = _url else {return}
            self._didURLChange(to: url)
        })
        _observers.append(webview.observe(\.estimatedProgress, options: .new){_,change in
            self.searchBar.setProgress(Float(change.newValue ?? 0.0))
        })
        
        self.view.insertSubview(webview, at: 0)
    }
    private func _setupNavigationBar(){
        downloadButton.setAction{[weak self] in self?._didDownloadButtonPush()}
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .red
        navigationController?.isSeparatorHidden = true
        searchBar.setup()
        searchBar.setSearchAction{[weak self] word in self?._search(with: word)}
        searchBar.setChangeAction{word in}
    }
}






