import UIKit

class HSLColorSliderView: UIView {
    var viewModel: HSLColorSliderViewModel
    
    private lazy var cursorLayer: CALayer = {
        let cursor = CALayer()
        cursor.borderColor = UIColor.white.cgColor
        cursor.borderWidth = 2
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
        gradientLayer.frame.size.height = frame.height//intrinsicContentSize.height

        let cursorX = viewModel.positionToCoordinate(
            sliderLenght: self.gradientLayer.frame.width,
            cursorDiameter: self.cursorLayer.frame.width
        )
        
        cursorLayer.frame = CGRect(x: cursorX, y: 0, width: frame.height, height: frame.height)
        
        gradientLayer.cornerRadius = gradientLayer.frame.height / 2
        cursorLayer.cornerRadius = cursorLayer.frame.height / 2
    }
    
    private func setup() {
        layer.addSublayer(gradientLayer)
        gradientLayer.addSublayer(cursorLayer)
    }
    
    private func bind() {
        viewModel.position.bind { [weak self] position in
            guard let self else { return }
            let x = self.viewModel.positionToCoordinate(
                sliderLenght: self.gradientLayer.frame.width,
                cursorDiameter: self.cursorLayer.frame.width
            )
            self.cursorLayer.frame.origin.x = x
        }
        
        viewModel.settedParameters.bind { [weak self] _ in
            self?.gradientLayer.colors = self?.viewModel.gradient
        }
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
}
