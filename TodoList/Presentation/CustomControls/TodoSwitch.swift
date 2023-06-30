import UIKit

class TodoSwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        onTintColor = R.Colors.switchOnBackground
        layer.cornerRadius = frame.height / 2.0
        clipsToBounds = true

        setSwitcherBackground()
    }

    // Хак для корректного изменения цвета фона
    private func setSwitcherBackground() {
        subviews.first?.subviews.first?.backgroundColor = R.Colors.switchOffBackground
    }

    override func didChangeValue(forKey key: String) {
        setSwitcherBackground()
        super.didChangeValue(forKey: key)
    }

    // При изменении темы нужно повторно изменить цвет фона
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Также хак для изменения цвета, без DispatchQueue не сработает
        DispatchQueue.main.async { [weak self] in
            self?.setSwitcherBackground()
        }
    }
}
