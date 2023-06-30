import UIKit

final class TodoTextViewModel {
    let text: Box<String>
    let color: Box<UIColor>
    
    var onTextViewDidBeginEditing: (() -> ())?
    var didChangeText: ((_ text: String) -> ())?
    
    init(text: String, color: UIColor) {
        self.text = Box(text)
        self.color = Box(color)
    }
}
