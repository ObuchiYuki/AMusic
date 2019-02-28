import UIKit
import MarqueeLabel

class NPSheetHeader: UIView {
    @IBOutlet weak var coverImageView: IBImageView!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    static func instance(with sheet:UIAlertController)->NPSheetHeader {
        let view = Bundle.main.loadNibNamed("NPSheetHeader", owner: self)?.first as! NPSheetHeader
        
        view.frame = CGRect(x: 8.0, y: 8.0, width: sheet.view.bounds.size.width - 8.0 * 2, height: 120.0)
        let lableWidth = view.frame.width - 100 - 16 * 2
        view.viewWithTag(1)?.frame.size.width = lableWidth
        view.viewWithTag(2)?.frame.size.width = lableWidth
        
        return view
    }
}
