import UIKit

class AddButton: UIButton {
    private lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.shadowColor = R.Colors.addButtonShadow?.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 8)

        return layer
    }()
    
    private lazy var addButtonImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.Images.addButton
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 22).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.insertSublayer(shadowLayer, at: 0)
        
        addSubview(addButtonImageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44),
            
            addButtonImageView.widthAnchor.constraint(equalTo: widthAnchor),
            addButtonImageView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}
