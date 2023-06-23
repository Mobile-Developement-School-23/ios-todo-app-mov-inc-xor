import UIKit

class TodoTextView: UITextView, UITextViewDelegate {
    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
    
    var onTextViewDidBeginEditing: (() -> ())?
    var didChangeText: ((_ text: String) -> ())?
    
    private lazy var placeholderLabel: UILabel = {
        let placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = "Что надо сделать?"
        placeholder.font = UIFont.systemFont(ofSize: 17)
        placeholder.textColor = R.Colors.disabledText
        placeholder.isHidden = !text.isEmpty
        return placeholder
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        delegate = self
        
        font = UIFont.systemFont(ofSize: 17)
        textContainerInset = padding
        backgroundColor = R.Colors.featureBackground
        textColor = R.Colors.text
        layer.cornerRadius = 16
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false
        
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
        ])
    }
    
    func setText(_ text: String) {
        self.text = text
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !text.isEmpty
        didChangeText?(text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        onTextViewDidBeginEditing?()
    }
}
