import UIKit

final class OptionsViewModel {
    let importance: Box<TodoItem.Importance>
    let color: Box<UIColor?>
    let deadline: Box<Date?>

    var didTapDeadlineOption: (() -> Void)?
    var didTapColorOption: (() -> Void)?
    var updateSuperviewLayout: (() -> Void)?

    init(importance: TodoItem.Importance, color: UIColor?, deadline: Date?) {
        self.importance = Box(importance)
        self.color = Box(color)
        self.deadline = Box(deadline)
    }
}
