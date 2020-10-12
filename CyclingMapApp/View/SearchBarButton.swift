import UIKit
import Foundation

@IBDesignable
class SearchBarButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customDesign()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customDesign()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customDesign()
    }
    
    private func customDesign() {
        setTitle("検索", for: .normal)
        setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        setTitleColor(.white, for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        layer.cornerRadius = 8.0
        
    }
}
