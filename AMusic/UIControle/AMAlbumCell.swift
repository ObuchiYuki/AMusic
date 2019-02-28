import UIKit

class AMAlbumCell: UICollectionViewCell{
    var shadowUpdateEnd = false
    var indexPath:IndexPath!
    override var isHighlighted: Bool{
        set{
            super.isHighlighted = newValue
            let bgView = viewWithTag(5)!
            if newValue{
                bgView.isHidden = false
                guard let cover = self.cover else {return}
                let size = CellLayoutProvider.default.imageSize
                let aspect = cover.size.width / cover.size.height
                var targetSize = CGSize.zero
                
                if size.width/aspect <= size.height{
                    targetSize = CGSize(width: size.width, height: size.width/aspect)
                }else{
                    targetSize = CGSize(width: size.height * aspect,height: size.height)
                }
                bgView.frame = CGRect(origin: [(size.width-targetSize.width)/2,(size.height-targetSize.height)/2], size: targetSize)
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    bgView.alpha = 0
                }){_ in
                    bgView.isHidden = true
                    bgView.alpha = 1
                }
            }
            
        }
        get{return super.isHighlighted}
    }
    var cover:UIImage?{
        get{return self.coverImageView.image}
        set{self.coverImageView.image = newValue}
    }
    var title:String?{
        get{return self.titleLable.text}
        set{self.titleLable.text = newValue}
    }
    var subtitle:String?{
        get{return self.subtitleLable.text}
        set{self.subtitleLable.text = newValue}
    }
    var coverImageView: UIImageView{
        return self.viewWithTag(1) as! UIImageView
    }
    var titleLable:UILabel{
        return self.viewWithTag(2) as! UILabel
    }
    var subtitleLable: UILabel{
        return self.viewWithTag(3) as! UILabel
    }
}
