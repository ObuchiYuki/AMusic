import UIKit

///Private API展開
class UITableViewIndexWrapper{
    // MARK: - Properties
    var view:UIControl
    
    // MARK: - Private Properties
    private var _lastSelectedSectionTitle:String? = nil
    private var _actionHandler:(String?)->Void = {_ in}

    // MARK: - APIs
    var titles:[String]{
        get{return view.value(forKey: "titles") as? [String] ?? []}
        set{view.setValue(newValue, forKey: "titles")}
    }
    var indexColor:UIColor{
        get{return view.value(forKey: "indexColor") as? UIColor ?? .clear}
        set{view.setValue(newValue, forKey: "indexColor")}
    }
    var selectedSectionTitle:String?{
        get{return view.value(forKey: "selectedSectionTitle") as? String}
    }
    func addTarget(_ action: @escaping (String?)->Void){
        self._actionHandler = action
    }
    
    private func actionHandler(){
        _actionHandler(selectedSectionTitle)
    }
    init() {
        let entity = NSClassFromString("UITableViewIndex")?.alloc()
        _ = entity?.perform(NSSelectorFromString("initWithFrame:"),with: CGRect(x: 0, y: 0, width: 15, height: 400)).takeUnretainedValue()
        self.view = entity as! UIControl
        self.view.backgroundColor = .white

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){[weak self] timer in
            guard let s = self else {return timer.invalidate()}
            if s._lastSelectedSectionTitle != s.selectedSectionTitle{
                s.actionHandler()
            }
            s._lastSelectedSectionTitle = s.selectedSectionTitle
        }.fire()
    }
}









