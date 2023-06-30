import UIKit

class AddTodoItemCellConfiguration: UIContentConfiguration {
    var didTapReturnKey: ((_ text: String) -> ())?
    
    func makeContentView() -> UIView & UIContentView {
        return AddTodoItemCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
