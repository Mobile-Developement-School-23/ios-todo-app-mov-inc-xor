import UIKit

class HSLColorPickerView: UIView {
    var viewModel: HSLColorPickerViewModel

    private lazy var hueColorSlider: HSLColorSliderView = {
        let viewModel = HSLColorSliderViewModel(position: 0, parameter: .hue)

        let slider = HSLColorSliderView(viewModel: viewModel)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private lazy var saturationColorSlider: HSLColorSliderView = {
        let viewModel = HSLColorSliderViewModel(
            position: 0,
            parameter: .saturation,
            settedParameters: [.hue: hueColorSlider.viewModel.position.value]
        )

        let slider = HSLColorSliderView(viewModel: viewModel)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private lazy var lightnessColorSlider: HSLColorSliderView = {
        let viewModel = HSLColorSliderViewModel(
            position: 0,
            parameter: .lightness,
            settedParameters: [
                .hue: hueColorSlider.viewModel.position.value,
                .saturation: saturationColorSlider.viewModel.position.value
            ]
        )

        let slider = HSLColorSliderView(viewModel: viewModel)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 13
        stack.alignment = .center
        return stack
    }()

    init(viewModel: HSLColorPickerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)

        setup()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HSLColorPickerView {
    private func bind() {
        hueColorSlider.viewModel.didChangePosition = { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            viewModel.hue.value = $0
            viewModel.didChangedColor?(viewModel.color)
        }

        saturationColorSlider.viewModel.didChangePosition = { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            viewModel.saturation.value = $0
            viewModel.didChangedColor?(viewModel.color)
        }

        lightnessColorSlider.viewModel.didChangePosition = { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            viewModel.lightness.value = $0
            viewModel.didChangedColor?(viewModel.color)
        }

        viewModel.hue.bind { [weak self] in
            self?.saturationColorSlider.viewModel.settedParameters.value[.hue] = $0
            self?.lightnessColorSlider.viewModel.settedParameters.value[.hue] = $0

            self?.hueColorSlider.viewModel.position.value = $0
        }

        viewModel.saturation.bind { [weak self] in
            self?.hueColorSlider.viewModel.settedParameters.value[.saturation] = $0
            self?.lightnessColorSlider.viewModel.settedParameters.value[.saturation] = $0

            self?.saturationColorSlider.viewModel.position.value = $0
        }

        viewModel.lightness.bind { [weak self] in
            self?.hueColorSlider.viewModel.settedParameters.value[.lightness] = $0
            self?.saturationColorSlider.viewModel.settedParameters.value[.lightness] = $0

            self?.lightnessColorSlider.viewModel.position.value = $0
        }
    }
}

extension HSLColorPickerView {
    private func setup() {
        contentView.addArrangedSubview(hueColorSlider)
        contentView.addArrangedSubview(saturationColorSlider)
        contentView.addArrangedSubview(lightnessColorSlider)

        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            hueColorSlider.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            saturationColorSlider.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            lightnessColorSlider.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
}
