import UIKit

protocol InfoListHeaderViewDelegate: class {
    func backButtonPressed()
    func postButtonPressed()
    func editButtonPressed()
    func deleteButtonPressed()
}

class InfoListHeaderView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    weak var delegate: InfoListHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customDesign()
    }
    
    private func customDesign() {
        let view = Bundle.main.loadNibNamed("InfoListHeaderView", owner: self, options: nil)!.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.backButtonPressed()
    }
     
    @IBAction func postButtonPressed(_ sender: UIButton) {
        delegate?.postButtonPressed()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.editButtonPressed()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed()
    }
}
