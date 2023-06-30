import UIKit

final class HSLColorSliderViewModel {
    enum Parameter {
        case hue
        case saturation
        case lightness
    }

    let position: Box<CGFloat>
    let parameter: Box<Parameter>
    let settedParameters: Box<[Parameter: CGFloat]>

    var didChangePosition: ((_ position: CGFloat) -> Void)?

    var gradient: [CGColor] {
        return stride(from: 0.0, through: 1.0, by: 0.1).map {
            var hue = settedParameters.value[.hue] ?? 0.0
            var saturation = settedParameters.value[.saturation] ?? 1.0
            var lightness = settedParameters.value[.lightness] ?? 1.0

            switch parameter.value {
            case .hue:
                hue = $0
            case .saturation:
                saturation = $0
            case .lightness:
                lightness = $0
            }
            return UIColor(hue: hue, saturation: saturation, brightness: lightness, alpha: 1.0).cgColor
        }
    }

    init(position: CGFloat, parameter: Parameter, settedParameters: [Parameter: CGFloat]? = nil) {
        self.position = Box(position)
        self.parameter = Box(parameter)
        self.settedParameters = Box(settedParameters ?? [:])
    }

    func positionToCoordinate(sliderLenght: CGFloat, cursorDiameter: CGFloat) -> CGFloat {
        let left = position.value * (sliderLenght - cursorDiameter)

        if left < 0 {
            return 0
        }

        if sliderLenght - left < cursorDiameter {
            return sliderLenght - cursorDiameter
        }
        return left
    }

    func coordinateToPosition(sliderCoordinate: CGFloat, sliderLenght: CGFloat, cursorDiameter: CGFloat) -> CGFloat {
        if sliderCoordinate < 0 {
            return 0
        }

        if sliderLenght - sliderCoordinate < cursorDiameter {
            return 1
        }

        guard sliderLenght != cursorDiameter else {
            return .infinity
        }

        return sliderCoordinate / (sliderLenght - cursorDiameter)
    }
}
