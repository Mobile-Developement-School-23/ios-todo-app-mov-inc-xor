import UIKit

class TodoSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        DispatchQueue.main.async { [weak self] in
            self?.setSegmentedControlBackground()
        }
    }

    // Хак для установки корректного цвета фона
    func setSegmentedControlBackground() {
        backgroundColor = R.Colors.segmentedControlBackground
        selectedSegmentTintColor = R.Colors.selectedSegmentedControl

        for i in 0..<3 {
            subviews[i].isHidden = true
        }
    }
}
