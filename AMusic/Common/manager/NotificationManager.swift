import UIKit

class NotificationManager {
    // MARK: Singleton
    static let `default` = NotificationManager()
    
    // MARK: APIs
    func post(_ title:String,subTitle:String? = nil,image:UIImage? = nil){//どこからでも呼べます。
        DispatchQueue.main.async {
            let task =  _NotificationTask(title: title, subTitle: subTitle, image: image)
            self._penddingTask.append(task)
            self._startRunLoop()
        }
    }
    
    // MARK: Private Properties
    private var _penddingTask = [_NotificationTask]()
    private var _runloopEnabled = false
    
    // MARK: Private Methods
    private func _didAllTaskComplete(){
        _runloopEnabled = false
    }
    private func _startRunLoop(){
        if _runloopEnabled {return}
        _runloopEnabled = true
        _runLoop()
    }
    private func _runLoop(){
        if _penddingTask.isEmpty{
            self._didAllTaskComplete()
            return
        }
        let task = _penddingTask.removeLast()
        let view = _createNotificationView(with: task)
        view.setCloseAction{view in
            self._runLoop()
        }
        view.show()
    }
    private func _createNotificationView(with task: _NotificationTask)->AMNotificationView{
        let view = AMNotificationView.newInstance()
        view.titleLabel.text = task.title
        if let subTitle = task.subTitle{
            view.subTitleLabel.text = subTitle
        }else{
            view.subTitleLabel.isHidden = true
        }
        if let image = task.image{
            view.imageView.image = image
        }else{
            view.imageView.isHidden = true
        }
        return view
    }
}
private class _NotificationTask {
    var title:String
    var subTitle:String?
    var image:UIImage?
    
    init(title:String,subTitle:String? = nil,image:UIImage? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
    }
}
