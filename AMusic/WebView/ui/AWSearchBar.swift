import UIKit

class WebViewSearchBar: UISearchBar{
    
    // MARK: APIs
    func setURL(_ url:URL){
        self.url = url
    }
    func setSearchAction(_ action:@escaping (String)->Void){
        self._searchAction = action
    }
    func setChangeAction(_ action:@escaping (String)->Void){
        self._changeAction = action
    }
    func setProgress(_ value:Float){
        self._checkProgress(with: value)
    }
    
    // MARK: Private Properties
    private var url:URL? = nil {didSet{_checkURL()}}
    private let _progressBar = UIProgressView()
    private let _progressBarMaskView = UIView()
    private let _reloadButton = UIButton()
    private var _textField:UITextField{return self.value(forKey: "searchField") as! UITextField}
    
    private var _searchAction:(String)->Void = {_ in}
    private var _changeAction:(String)->Void = {_ in}

    private var currentMode:Mode = .label{didSet{_checkCurrentMode()}}
    
    // MARK: Private Methods
    private func _checkProgress(with value:Float){
        UIView.animate(withDuration: 0.3, delay: 0.1, animations: {
            self._progressBar.alpha = value == 1 ? 0 : 1
        }){_ in
            if value == 1{self._progressBar.progress = 0}
        }
        _progressBar.setProgress(value, animated: true)
    }
    private func _checkURL(){
        guard let url = url else {self._textField.text = nil;return}
        if currentMode == .label{
            if let query = AWSearchManager.default.getQuery(with: url){
                self._textField.text = query
            }else{
                let comp = URLComponents(url: url, resolvingAgainstBaseURL: true)
                self._textField.text = comp?.host
            }
        }else{
            self._textField.text = url.absoluteString
        }
    }
    private func _checkCurrentMode(){
        if currentMode == .label{
            self.showsCancelButton = false
            self._textField.textAlignment = .center
            
            UIView.animate(withDuration: 0.2){
                if self._progressBar.progress != 1{
                    self._progressBar.alpha = 1
                }
            }
        }else{
            self.setShowsCancelButton(true, animated: true)
            self._textField.textAlignment = .left
            UIView.animate(withDuration: 0.2){
                self._progressBar.alpha = 0
            }
        }
        _checkURL()
    }
    @objc
    private func _reloadButtonDidPush(){
        UIView.animate(withDuration: 0.2, animations: {
            self._reloadButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }){_ in self._reloadButton.setImage(#imageLiteral(resourceName: "locked"), for: .normal)}
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self._reloadButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    // MARK: Setup UIs
    func setup(){
        self.delegate = self
        
        _setupTextField()
        _setupProgressBar()
    }
    private func _setupTextField(){
        _textField.delegate = self
        _textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        _textField.clearButtonMode = .whileEditing
        _textField.textAlignment = .center
        _textField.leftViewMode = .never
        _textField.font = UIFont(name: "Helvetica Neue", size: 16)
        
        _reloadButton.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width-50, y: 17), size: CGSize(width: 17, height: 17))
        _reloadButton.setImage(#imageLiteral(resourceName: "realod"), for: .normal)
        _reloadButton.addTarget(self, action: #selector(WebViewSearchBar._reloadButtonDidPush), for: .touchUpInside)
        
        self.addSubview(_reloadButton)
    }
    private func _setupProgressBar(){
        _progressBar.frame = CGRect(x: 0, y: 34, width: UIScreen.main.bounds.width-40, height: 2)
        _progressBar.progress = 1.0
        _progressBar.alpha = 0
        _progressBar.backgroundColor = .clear
        _progressBar.trackTintColor = .clear
        
        _progressBarMaskView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-41, height: 36)
        _progressBarMaskView.layer.cornerRadius = 9
        _progressBarMaskView.clipsToBounds = true
        
        _textField.addSubview(_progressBarMaskView)
        _progressBarMaskView.addSubview(_progressBar)
    }
    
    // MARK: Enums
    private enum Mode {case editing,label}
}

extension WebViewSearchBar:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self._changeAction(textField.text ?? "")
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentMode = .editing
        UIView.animate(withDuration: 0.2){
            self._reloadButton.transform = CGAffineTransform(scaleX: 0.000001, y: 0.000001)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {return false}
        self._searchAction(text)
        textField.resignFirstResponder()
        textFieldDidEndEditing(textField)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.currentMode = .label
        UIView.animate(withDuration: 0.2){
            self._reloadButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

extension WebViewSearchBar:UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}





