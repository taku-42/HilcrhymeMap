import Foundation
import UIKit

@IBDesignable
class PositiveSimpleButton: UIButton {
    
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
        backgroundColor = UIColor(red: 98/255, green: 210/255, blue: 162/255, alpha: 1.0)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 15.0
        layer.shadowColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
//        contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
}
