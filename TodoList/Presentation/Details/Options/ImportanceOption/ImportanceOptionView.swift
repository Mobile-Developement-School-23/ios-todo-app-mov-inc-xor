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
    
    private lazy var segmentedControl: TodoSegmentedControl = {
        let items: [Any] = [
            R.Images.lowImportanceIcon.withRenderingMode(.alwaysOriginal),
            "нет",
            R.Images.highImportanceIcon.withRenderingMode(.alwaysOriginal)
        ]
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: R.Colors.text ?? .black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
        ]
        
        let action = UIAction { [weak self] in
            guard let self, let sender = ($0.sender as? UISegmentedControl) else {
                return
            }
            self.viewModel.didChangeImportance?(self.importance(from: sender.selectedSegmentIndex))
        }
        
        let segmentedControl = TodoSegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = index(from: viewModel.importance.value)
        segmentedControl.setTitleTextAttributes(textAttributes, for:.normal)
        segmentedControl.addAction(action, for: .valueChanged)
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
            segmentedControl.widthAnchor.constraint(equalToConstant: 150),
        ])
    }
}
