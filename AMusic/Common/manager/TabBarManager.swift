import UIKit

class TabBarManager:NSObject, UITabBarControllerDelegate {
    static let `default` = TabBarManager()
    private let kTabBarTabsOrderSaveKey = "tabBarTabsOrder"
    private let kTabBarLastTabSaveKay = "kTabBarLastTabSaveKay"
    
    func initialize(with tabBarController:UITabBarController){
        tabBarController.delegate = self
        let vcOrder = UserDefaults.standard.array(forKey: kTabBarTabsOrderSaveKey) as? [Int] ?? []
        if !vcOrder.isEmpty{
            var viewcontrollers = tabBarController.viewControllers ?? []
            var results = [UIViewController]()
            for tag in vcOrder{
                let vc = viewcontrollers.filter{$0.tabBarItem.tag == tag}.first
                if let _vc = vc{
                    results.append(_vc)
                }
            }
            if viewcontrollers.count > results.count{
                for result in results{
                    viewcontrollers.remove(at: viewcontrollers.index(of: result)!)
                }
                results.append(contentsOf: viewcontrollers)
            }
            tabBarController.viewControllers = results
            
            let lastTag = UserDefaults.standard.integer(forKey: kTabBarLastTabSaveKay)
            guard let lastVc = tabBarController.viewControllers?.filter({$0.tabBarItem.tag == lastTag}).first else {return}
            tabBarController.selectedIndex = tabBarController.viewControllers?.index(of: lastVc) ?? 0
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        UserDefaults.standard.set(tabBarController.viewControllers?.map{vc in vc.tabBarItem.tag}, forKey: kTabBarTabsOrderSaveKey)
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UserDefaults.standard.set(viewController.tabBarItem.tag, forKey: kTabBarLastTabSaveKay)
    }
}
