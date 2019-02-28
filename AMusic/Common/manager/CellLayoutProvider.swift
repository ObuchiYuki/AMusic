import UIKit

class CellLayoutProvider {
    static let `default` = CellLayoutProvider()
    var margin:CGFloat = 16
    var cellBottomContentHeight:CGFloat = 8+21+4+21
    lazy var cellWidth:CGFloat = {
        let screenWidth = UIScreen.main.bounds.width
        let cellCount:CGFloat = screenWidth > 500 ? 4 : 2
        let width = ((screenWidth - margin * (cellCount+1)) / cellCount)
        return width
    }()
    lazy var imageSize:CGSize = {
        return [cellWidth, cellWidth]
    }()
    lazy var cellSize:CGSize = {
        return [cellWidth, cellWidth+cellBottomContentHeight]
    }()
}
