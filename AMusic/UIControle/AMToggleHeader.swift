import UIKit

class AMToggleHeader: UICollectionReusableView{
    @IBOutlet private weak var buttonWidth1: NSLayoutConstraint!
    @IBOutlet private weak var buttonWidth2: NSLayoutConstraint!
    @IBOutlet private weak var stackView: UIStackView!
    private var shuffleAction = {}
    private var playAction = {}
    
    @IBAction private func didPlayButtonPush(_ sender: UIButton) {
        playAction()
    }
    @IBAction private func didShuffleButtonPush(_ sender: UIButton) {
        shuffleAction()
    }
    func setActions(play: (()->Void)?, shuffle: (()->Void)?){
        self.shuffleAction = shuffle ?? {}
        self.playAction = play ?? {}
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonWidth1.constant = CellLayoutProvider.default.cellWidth
        buttonWidth2.constant = CellLayoutProvider.default.cellWidth
        
        stackView.spacing = self.frame.width - 32 - CellLayoutProvider.default.cellWidth * 2
        
        stackView.layoutIfNeeded()
    }
}
