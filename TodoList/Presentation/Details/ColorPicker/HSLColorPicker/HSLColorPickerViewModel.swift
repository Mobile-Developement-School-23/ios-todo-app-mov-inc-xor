import UIKit

final class HSLColorPickerViewModel {
    let hue: Box<CGFloat>
    let saturation: Box<CGFloat>
    let lightness: Box<CGFloat>
    
    var color: UIColor {
        return UIColor(hue: hue.value, saturation: saturation.value, brightness: lightness.value, alpha: 1.0)
    }
    
    var didChangedColor: ((_ color: UIColor) -> ())?
    
    init(color: UIColor) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        
        color.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
        
        self.hue = Box(h)
        self.saturation = Box(s)
        self.lightness = Box(l)
    }
    
    func setColor(_ color: UIColor) {
        color.getHue(&hue.value, saturation: &saturation.value, brightness: &lightness.value, alpha: nil)
    }
}
