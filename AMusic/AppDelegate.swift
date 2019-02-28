import UIKit
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIView.appearance().tintColor = ColorPalette.current.tintColor.main
        
        
        // MARK: Initialize various Singletons.
        MediaLibrary.default.initialize()
        MediaPlayer.default.initialize()
        
        TabBarManager.default.initialize(with: window?.rootViewController as! UITabBarController)
        StatusbarManager.default.initialize()
        
        ADTaskManager.default.initialize()
        ADTaskManager.default.register(with: ADSYoutube())//(仮)
        
        AMNowPlayingFloatingView.shared.initialize()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {
        MediaPlayer.default.stop()
    }
}

