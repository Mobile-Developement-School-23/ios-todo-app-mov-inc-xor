import UIKit

final class HSLColorPickerViewModel {
    let hue: Box<CGFloat>
    let saturation: Box<CGFloat>
    let lightness: Box<CGFloat>

    var color: UIColor {
        return UIColor(hue: hue.value, saturation: saturation.value, brightness: lightness.value, alpha: 1.0)
    }

    var didChangedColor: ((_ color: UIColor) -> Void)?

    init(color: UIColor) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var lightness: CGFloat = 0

        color.getHue(&hue, saturation: &saturation, brightness: &lightness, alpha: nil)

        self.hue = Box(hue)
        self.saturation = Box(saturation)
        self.lightness = Box(lightness)
    }

    func setColor(_ color: UIColor) {
        color.getHue(&hue.value, saturation: &saturation.value, brightness: &lightness.value, alpha: nil)
    }
}
