import UIKit

final class ColorOptionViewModel {
    let color: Box<UIColor?>

    var didChangeSwitchValue: ((_ value: Bool) -> Void)?

    init(color: UIColor?) {
        self.color = Box(color)
    }
}
