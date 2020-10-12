import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    // セミモーダルビューの初期位置
    var initialPosition: FloatingPanelPosition {
        return .half
    }

    var topInteractionBuffer: CGFloat {
        return 0.0
    }

    var bottomInteractionBuffer: CGFloat {
        return 0.0
    }

    // セミモーダルビューの各表示パターンの高さを決定するためのInset
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        var ret: CGFloat!
        switch position {
        case .full:
            ret = nil
        case .half:
            ret = 262.0
        case .tip:
            ret = 130.0
        default:
            ret = nil
        }
        return ret
    }

    // セミモーダルビューの背景Viewの透明度
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
