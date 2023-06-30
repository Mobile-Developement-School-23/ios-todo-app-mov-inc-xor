import UIKit

final class TodoTextViewModel {
    let text: Box<String>
    let color: Box<UIColor>

    var onTextViewDidBeginEditing: (() -> Void)?
    var didChangeText: ((_ text: String) -> Void)?

    init(text: String, color: UIColor) {
        self.text = Box(text)
        self.color = Box(color)
    }
}
