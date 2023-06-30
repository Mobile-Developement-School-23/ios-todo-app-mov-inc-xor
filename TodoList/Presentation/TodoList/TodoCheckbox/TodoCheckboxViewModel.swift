enum CheckboxType {
    case basic
    case important
}

final class TodoCheckboxViewModel {
    let checked: Box<Bool>
    let type: Box<CheckboxType>

    var didChangeValue: ((_ value: Bool) -> Void)?

    init(checked: Bool = false, type: CheckboxType = .basic) {
        self.checked = Box(checked)
        self.type = Box(type)
    }
}
