import UIKit
import Defaults

struct SpaceStationConfig {
    var name: String
    var parts: Int
    var torusMajor: Double
    var torusMinor: Double
    var bevelbox: Double
    var cylinder: Double
    var cylinderHeight: Double
    var storage: Double
    var color1: UIColor
    var color2: UIColor

    static func generateRandomConfig() -> SpaceStationConfig {
        return SpaceStationConfig(
            name: Defaults[.username] + "'s SpaceStation",
            parts: Int.random(in: 3...8),
            torusMajor: Double.random(in: 2.0...5.0),
            torusMinor: Double.random(in: 0.1...0.5),
            bevelbox: Double.random(in: 0.2...0.5),
            cylinder: Double.random(in: 0.5...3.0),
            cylinderHeight: Double.random(in: 0.3...1.0),
            storage: Double.random(in: 0.5...1.0),
            color1: .random,
            color2: .random
        )
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}

class ConfigureSpaceStationViewController: UIViewController, UIColorPickerViewControllerDelegate {

    var config = SpaceStationConfig(
        name: Defaults[.username] + "'s SpaceStation",
        parts: 3,
        torusMajor: 2.0,
        torusMinor: 0.1,
        bevelbox: 0.2,
        cylinder: 0.5,
        cylinderHeight: 0.3,
        storage: 0.5,
        color1: .lightGray,
        color2: .lightGray
    )

    let scrollView = UIScrollView()
    let contentView = UIView()

    let color1Button = UIButton(type: .system)
    let color2Button = UIButton(type: .system)

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setGradientBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
        setupForm()
    }

    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupScrollView() {
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear // Keep the content view transparent
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        // Add some padding to the content view
        let contentViewPadding: CGFloat = 20
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: contentViewPadding),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -contentViewPadding),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: contentViewPadding),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -contentViewPadding),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * contentViewPadding)
        ])
    }

    func setupForm() {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let padding: CGFloat = 20

        let titleLabel = createTitleLabel()
        let formStackView = createFormStackView()
        let generateButton = createGenerateButton()
        let createButton = createCreateButton()
        let backButton = createBackButton()

        contentView.addSubview(titleLabel)
        contentView.addSubview(formStackView)
        contentView.addSubview(generateButton)
        contentView.addSubview(createButton)
        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            formStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            generateButton.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: padding),
            generateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            generateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            generateButton.heightAnchor.constraint(equalToConstant: 50),

            createButton.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: padding),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            createButton.heightAnchor.constraint(equalToConstant: 50),

            backButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: padding),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -padding)
        ])
    }

    func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Space Station Configuration"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGray
        titleLabel.backgroundColor = .white // Set background color to white
        titleLabel.layer.cornerRadius = 10
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor.lightGray.cgColor
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical) // Ensure the label resizes correctly
        return titleLabel
    }

    func createFormStackView() -> UIStackView {
        let nameLabel = createPaddedLabel(text: "SpaceStation Name:")
        let nameTextField = createTextField(placeholder: "Enter name", value: config.name)
        nameTextField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)

        let partsLabel = createPaddedLabel(text: "Number of Parts:")
        let partsTextField = createTextField(placeholder: "Parts", value: "\(config.parts)")

        let torusMajorLabel = createPaddedLabel(text: "Torus Major:")
        let torusMajorTextField = createTextField(placeholder: "Torus Major", value: String(format: "%.2f", config.torusMajor))

        let torusMinorLabel = createPaddedLabel(text: "Torus Minor:")
        let torusMinorTextField = createTextField(placeholder: "Torus Minor", value: String(format: "%.2f", config.torusMinor))

        let bevelboxLabel = createPaddedLabel(text: "Bevel Box Size:")
        let bevelboxTextField = createTextField(placeholder: "Bevel Box", value: String(format: "%.2f", config.bevelbox))

        let cylinderLabel = createPaddedLabel(text: "Cylinder Diameter:")
        let cylinderTextField = createTextField(placeholder: "Cylinder Diameter", value: String(format: "%.2f", config.cylinder))

        let cylinderHeightLabel = createPaddedLabel(text: "Cylinder Height:")
        let cylinderHeightTextField = createTextField(placeholder: "Cylinder Height", value: String(format: "%.2f", config.cylinderHeight))

        let storageLabel = createPaddedLabel(text: "Storage Capacity:")
        let storageTextField = createTextField(placeholder: "Storage Capacity", value: String(format: "%.2f", config.storage))

        let color1Label = createPaddedLabel(text: "Color 1:")
        color1Button.setTitle("Select Color 1", for: .normal)
        color1Button.backgroundColor = config.color1
        color1Button.setTitleColor(.white, for: .normal)
        color1Button.layer.cornerRadius = 10
        color1Button.translatesAutoresizingMaskIntoConstraints = false
        color1Button.addTarget(self, action: #selector(selectColor1), for: .touchUpInside)

        let color2Label = createPaddedLabel(text: "Color 2:")
        color2Button.setTitle("Select Color 2", for: .normal)
        color2Button.backgroundColor = config.color2
        color2Button.setTitleColor(.white, for: .normal)
        color2Button.layer.cornerRadius = 10
        color2Button.translatesAutoresizingMaskIntoConstraints = false
        color2Button.addTarget(self, action: #selector(selectColor2), for: .touchUpInside)

        let formStackView = UIStackView(arrangedSubviews: [
            createHorizontalStackView(label: nameLabel, textField: nameTextField, isFullWidth: true),
            createHorizontalStackView(label: partsLabel, textField: partsTextField),
            createHorizontalStackView(label: torusMajorLabel, textField: torusMajorTextField),
            createHorizontalStackView(label: torusMinorLabel, textField: torusMinorTextField),
            createHorizontalStackView(label: bevelboxLabel, textField: bevelboxTextField),
            createHorizontalStackView(label: cylinderLabel, textField: cylinderTextField),
            createHorizontalStackView(label: cylinderHeightLabel, textField: cylinderHeightTextField),
            createHorizontalStackView(label: storageLabel, textField: storageTextField),
            createHorizontalStackView(label: color1Label, textField: color1Button),
            createHorizontalStackView(label: color2Label, textField: color2Button)
        ])
        formStackView.axis = .vertical
        formStackView.spacing = 20
        formStackView.alignment = .fill
        formStackView.translatesAutoresizingMaskIntoConstraints = false

        return formStackView
    }

    func createGenerateButton() -> UIButton {
        let generateButton = UIButton(type: .system)
        generateButton.setTitle("Generate Random Values", for: .normal)
        generateButton.backgroundColor = .orange
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 10
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateRandomValues), for: .touchUpInside)
        return generateButton
    }

    func createCreateButton() -> UIButton {
        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Space Station", for: .normal)
        createButton.backgroundColor = .green
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createSpaceStation), for: .touchUpInside)
        return createButton
    }

    func createBackButton() -> UIButton {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .blue
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return backButton
    }

    func createPaddedLabel(text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.lightGray.cgColor
        container.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor)
        ])

        return container
    }

    func createTextField(placeholder: String, value: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = value
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }

    func createHorizontalStackView(label: UIView, textField: UIView, isFullWidth: Bool = false) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill

        if isFullWidth {
            NSLayoutConstraint.activate([
                textField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -10) // Full width minus padding
            ])
        } else {
            label.widthAnchor.constraint(equalToConstant: 150).isActive = true
            textField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        }

        return stackView
    }

    @objc func nameChanged(_ textField: UITextField) {
        config.name = textField.text ?? ""
    }

    @objc func generateRandomValues() {
        config = SpaceStationConfig.generateRandomConfig()
        setupForm()
    }

    @objc func createSpaceStation() {
        // Add your creation logic here
    }

    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func selectColor1() {
        presentColorPicker(for: &config.color1, button: color1Button)
    }

    @objc func selectColor2() {
        presentColorPicker(for: &config.color2, button: color2Button)
    }

    func presentColorPicker(for color: inout UIColor, button: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = color
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        colorPicker.popoverPresentationController?.sourceView = button
        colorPicker.popoverPresentationController?.sourceRect = button.bounds
        colorPicker.popoverPresentationController?.permittedArrowDirections = .up
        self.present(colorPicker, animated: true, completion: nil)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if viewController.popoverPresentationController?.sourceView == color1Button {
            config.color1 = viewController.selectedColor
            color1Button.backgroundColor = config.color1
        } else if viewController.popoverPresentationController?.sourceView == color2Button {
            config.color2 = viewController.selectedColor
            color2Button.backgroundColor = config.color2
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
