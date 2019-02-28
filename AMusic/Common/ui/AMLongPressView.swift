import UIKit

class AMLongPressViewManager {
    class func newVC(model: AMLongPressViewModel)->UIAlertController{
        let vc = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        let header = NPSheetHeader.instance(with: vc)
        header.titleLabel.text = model.title
        header.artistLabel.text = model.subtitle
        header.discriptionLabel.text = model.description
        header.coverImageView.image = model.image
        
        vc.view.addSubview(header)
        
        for action in model.actions{
            vc.addAction(title: action.title, style: .default, image: action.image, titleAlignment: .left, action.action)
        }
        vc.addCancel()
        
        return vc
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}
}

class AMLongPressViewModel {
    var title:String = ""
    var subtitle:String = ""
    var description:String = ""
    var image:UIImage? = nil
    var actions:[Action] = []
    
    class Action {
        var title:String
        var image:UIImage
        var action: ()->Void
        
        init(title: String, image:UIImage, action: @escaping ()->Void) {
            self.title = title
            self.image = image
            self.action = action
        }
    }
}

extension AMLongPressViewModel{
    func addAction(title: String, image:UIImage,_ action:@escaping ()->Void){
        let action = Action(title: title, image: image, action: action)
        self.actions.append(action)
    }
}



