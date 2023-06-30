import UIKit

class TodoTextView: UITextView, UITextViewDelegate {
    var viewModel: TodoTextViewModel

    private let padding = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)

    private lazy var placeholderLabel: UILabel = {
        let placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = "Что надо сделать?"
        placeholder.font = UIFont.systemFont(ofSize: 17)
        placeholder.textColor = R.Colors.disabledText
        placeholder.isHidden = !text.isEmpty
        return placeholder
    }()

    init(viewModel: TodoTextViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null, textContainer: nil)

        bind()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidChange(_ textView: UITextView) {
        let text = String(textView.text.trimmingPrefix(/\s*/))
        placeholderLabel.isHidden = !text.isEmpty
        viewModel.didChangeText?(text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.onTextViewDidBeginEditing?()
    }
}

extension TodoTextView {
    private func bind() {
        viewModel.text.bind { [weak self] in
            let text = String($0.trimmingPrefix(/\s*/))
            self?.text = text
            self?.placeholderLabel.isHidden = !text.isEmpty
        }

        viewModel.color.bind { [weak self] in
            self?.textColor = $0
        }
    }

    private func setup() {
        delegate = self

        font = UIFont.systemFont(ofSize: 17)
        textContainerInset = padding
        backgroundColor = R.Colors.featureBackground
        textColor = viewModel.color.value
        layer.cornerRadius = 16
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false

        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left)
        ])
    }
}
