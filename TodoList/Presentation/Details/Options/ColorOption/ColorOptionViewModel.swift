import UIKit

final class ColorOptionViewModel {
    let color: Box<UIColor?>
    
    var didChangeSwitchValue: ((_ value: Bool) -> ())?
    
    init(color: UIColor?) {
        self.color = Box(color)
    }
}
