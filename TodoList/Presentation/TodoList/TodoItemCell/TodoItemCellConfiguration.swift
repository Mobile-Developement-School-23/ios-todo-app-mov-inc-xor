import UIKit

class TodoItemCellConfiguration: UIContentConfiguration {
    let item: TodoItem
    
    var checked: Bool
    var didChangeChecked: ((_ value: Bool) -> ())?
    
    init(item: TodoItem) {
        self.item = item
        
        self.checked = item.done
    }
    
    func makeContentView() -> UIView & UIContentView {
        return TodoItemCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
