import UIKit

final class ColorOptionViewModel {
    let color: Box<UIColor>
    
    var didChangeColor: ((_ color: UIColor) -> ())?
    
    init(color: UIColor) {
        self.color = Box(color)
    }
}
