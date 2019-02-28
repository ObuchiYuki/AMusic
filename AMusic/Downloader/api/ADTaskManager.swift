import Foundation
import WebKit

class ADTaskManager {
    // MARK: Singleton
    static let `default` = ADTaskManager()
    
    // MARK: Properties
    // MARK: Private Properties
    private var _tasks = [ADDownloadTask]()
    private var _specificators = [ADSpecificator]()
    
    // MARK: APIs
    func register(with specificator:ADSpecificator) {
        self._specificators.append(specificator)
    }
    func enableTask(_ task:ADDownloadTask){
        guard let webView = AWWebViewManager.default.cuurentWebView else {return}
        task.applyWebView(webView)
        task.isEnabled = true
        
        if task.currentState == .completed{
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self._addTaskToLibrary(task)
            }
        }
    }
    
    // MARK: Private Methods
    private func _applyMetadata(to task:ADDownloadTask,completion:@escaping ()->Void){
        guard let url = task.webpage?.url else {return}
        var _specificator:ADSpecificator? = nil
        for specificator in self._specificators{
            if specificator.chargedHosts.contains(url.host!){
                _specificator = specificator
                break
            }
        }
        if let specificator = _specificator{
            specificator.applyMetadata(with: task, completion: completion)
        }
    }
    private func _addTaskToLibrary(_ task:ADDownloadTask){
        self._applyMetadata(to: task){
            ADMediaLibrary.default.createItem(with: task.metadata!, data: task.data!){item in
                if let item = item{
                    ADMediaLibrary.default.addItem(item: item)
                }else{
                    NotificationManager.default.post("Convering ADMediaEntity Error!")
                }
            }
        }
    }
    private func _removeTask(_ task:ADDownloadTask){
        let task = _tasks.remove(of: task)
        if let _task = task, _task.isEnabled{
            _addTaskToLibrary(_task)
        }
        NotificationCenter.default.post(name: .ADTaskManagerDidTaskRemoved, object: task)
    }
    private func _registerTask(_ task:ADDownloadTask) {
        _tasks.append(task)
        NotificationCenter.default.post(name: .ADTaskManagerDidTaskAdded, object: task)
    }
    
    /// MARK:initialize
    func initialize(){
        NotificationCenter.default.addObserver(forName: .AWWebViewDidDetecteVideo, object: nil, queue: .main){notice in
            guard let task = notice.object as? ADDownloadTask else {return}
            self._registerTask(task)
        }
        NotificationCenter.default.addObserver(forName: .AWWebViewDidDownloadVideo, object: nil, queue: .main){notice in
            guard let task = notice.object as? ADDownloadTask else {return}
            self._removeTask(task)
        }
    }
}

extension Notification.Name{
    ///ADTaskManager::  didTaskAdded:   ADDownloadTask
    static let ADTaskManagerDidTaskAdded   = Notification.Name(rawValue: "ADTaskManagerDidVideoAdded")
    ///ADTaskManager::  didTaskRemoved:   ADDownloadTask
    static let ADTaskManagerDidTaskRemoved   = Notification.Name(rawValue: "ADTaskManagerDidTaskRemoved")
}

