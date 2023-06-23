import UIKit

class ImportanceOptionView: UIView {
    var viewModel: ImportanceOptionViewModel
    
    private lazy var importanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Важность"
        label.textColor = R.Colors.text
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items: [Any] = [
            R.Images.lowImportanceIcon.withRenderingMode(.alwaysOriginal),
            "нет",
            R.Images.highImportanceIcon.withRenderingMode(.alwaysOriginal)
        ]
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: R.Colors.text ?? .black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
        ]
        
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = index(from: viewModel.importance.value)
        segmentedControl.setTitleTextAttributes(textAttributes, for:.normal)
        
        segmentedControl.addAction(UIAction { [weak self] in
            guard
                let self,
                let sender = ($0.sender as? UISegmentedControl)
            else {
                return
            }
            self.viewModel.didChangeImportance?(self.importance(from: sender.selectedSegmentIndex))
            self.setSegmentedControlBackground(segmentedControl)
        }, for: .valueChanged)
        
        DispatchQueue.main.async { [weak self] in
            self?.setSegmentedControlBackground(segmentedControl)
        }
        
        return segmentedControl
    }()
    
    private func importance(from index: Int) -> TodoItem.Importance {
        switch index {
        case 2:
            return .important
        case 0:
            return .low
        default:
            return .basic
        }
    }
    
    private func index(from importance: TodoItem.Importance) -> Int {
        switch importance {
        case .important:
            return 2
        case .basic:
            return 1
        case .low:
            return 0
        }
    }
    
    // Хак для установки корректного цвета фона
    func setSegmentedControlBackground(_ segmentedControl: UISegmentedControl) {
        segmentedControl.backgroundColor = R.Colors.segmentedControlBackground
        segmentedControl.selectedSegmentTintColor = R.Colors.selectedSegmentedControl
        
        for i in 0..<3 {
            segmentedControl.subviews[i].isHidden = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.setSegmentedControlBackground(self.segmentedControl)
        }
    }
    
    init(viewModel: ImportanceOptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(importanceLabel)
        addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            importanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            importanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
