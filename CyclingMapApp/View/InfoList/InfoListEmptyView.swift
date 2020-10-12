import UIKit

class InfoListEmptyTableView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customDesign()
    }
    
    func customDesign() {
        let view = Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)?.first as? UIView ?? UIView()
        view.frame = bounds
        addSubview(view)
    }
    
}
