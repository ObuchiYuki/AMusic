import UIKit

// MARK: - AMusic用のExtension
// 一般化するほどのものでもないもの、もしくはAppのCommonに依存があるもの

extension UIWindow{
    static var main: UIWindow{
        return UIApplication.shared.delegate!.window!!
    }
}
extension UIStoryboard{
    static var main:UIStoryboard{
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
}
