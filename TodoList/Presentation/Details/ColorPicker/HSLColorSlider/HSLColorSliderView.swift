import UIKit

class HSLColorSliderView: UIView {
    var viewModel: HSLColorSliderViewModel

    private static let height: CGFloat = 25

    private lazy var cursorLayer: CALayer = {
        let cursor = CALayer()
        cursor.borderColor = UIColor.white.cgColor
        cursor.borderWidth = 5
        return cursor
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = viewModel.gradient
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.cornerRadius = 16
        return gradient
    }()

    init(viewModel: HSLColorSliderViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)

        setup()
        bind()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        gradientLayer.frame.size.width = frame.width
        gradientLayer.frame.size.height = Self.height

        let cursorX = viewModel.positionToCoordinate(
            sliderLenght: self.gradientLayer.frame.width,
            cursorDiameter: self.cursorLayer.frame.width
        )

        cursorLayer.frame = CGRect(x: cursorX, y: 4, width: Self.height - 8, height: Self.height - 8)

        gradientLayer.cornerRadius = Self.height / 2
        cursorLayer.cornerRadius = cursorLayer.frame.height / 2
    }

    private func setupGestureRecognizers() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        let midX = point.x - cursorLayer.frame.width / 2

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let position = viewModel.coordinateToPosition(
            sliderCoordinate: midX,
            sliderLenght: gradientLayer.frame.width,
            cursorDiameter: cursorLayer.frame.width
        )
        viewModel.position.value = position
        viewModel.didChangePosition?(position)
        CATransaction.commit()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.height)
    }
}

extension HSLColorSliderView {
    private func bind() {
        viewModel.position.bind { [weak self] _ in
            guard let self else { return }
            let originX = self.viewModel.positionToCoordinate(
                sliderLenght: self.gradientLayer.frame.width,
                cursorDiameter: self.cursorLayer.frame.width
            )
            self.cursorLayer.frame.origin.x = originX
        }

        viewModel.settedParameters.bind { [weak self] _ in
            self?.gradientLayer.colors = self?.viewModel.gradient
        }
    }

    private func setup() {
        layer.addSublayer(gradientLayer)
        gradientLayer.addSublayer(cursorLayer)
    }
}
