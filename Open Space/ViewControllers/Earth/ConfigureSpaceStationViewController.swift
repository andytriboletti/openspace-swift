import UIKit
import Defaults

struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    var codableColor: CodableColor {
        return CodableColor(color: self)
    }
}

struct SpaceStationConfig: Codable {
    var name: String
    var parts: Int
    var torusMajor: Double
    var torusMinor: Double
    var bevelbox: Double
    var cylinder: Double
    var cylinderHeight: Double
    var storage: Double
    var color1: CodableColor
    var color2: CodableColor
    var location: String

    static func generateRandomConfig(locations: [String]) -> SpaceStationConfig {
        return SpaceStationConfig(
            name: Defaults[.username] + "'s SpaceStation",
            parts: Int.random(in: 3...8),
            torusMajor: Double.random(in: 2.0...5.0),
            torusMinor: Double.random(in: 0.1...0.5),
            bevelbox: Double.random(in: 0.2...0.5),
            cylinder: Double.random(in: 0.5...3.0),
            cylinderHeight: Double.random(in: 0.3...1.0),
            storage: Double.random(in: 0.5...1.0),
            color1: UIColor.random.codableColor,
            color2: UIColor.random.codableColor,
            location: locations.randomElement() ?? "Low Earth Orbit (LEO)"
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
        color1: UIColor.lightGray.codableColor,
        color2: UIColor.lightGray.codableColor,
        location: "Low Earth Orbit (LEO)"
    )

    let scrollView = UIScrollView()
    let contentView = UIView()

    let color1Button = UIButton(type: .system)
    let color2Button = UIButton(type: .system)

    var colorPickerCompletion: ((UIColor) -> Void)?

    let locations = ["Low Earth Orbit (LEO)", "Geostationary Orbit (GEO)", "Lunar Orbit", "Lagrange Point (L1)", "Lagrange Point (L2)", "Mars Orbit", "Asteroid Belt", "Deep Space", "Jupiter's Moon (Europa)", "Jupiter's Moon (Ganymede)"]

    // TextField references
    var nameTextField: UITextField!
    var partsTextField: UITextField!
    var torusMajorTextField: UITextField!
    var torusMinorTextField: UITextField!
    var bevelboxTextField: UITextField!
    var cylinderTextField: UITextField!
    var cylinderHeightTextField: UITextField!
    var storageTextField: UITextField!
    var locationPopupButton: UIButton!

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
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

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
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor            , constant: padding),
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
        titleLabel.backgroundColor = .white
        titleLabel.layer.cornerRadius = 10
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor.lightGray.cgColor
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return titleLabel
    }

    func createFormStackView() -> UIStackView {
        let nameLabel = createPaddedLabel(text: "SpaceStation Name:")
        nameTextField = createTextField(placeholder: "Enter name", value: config.name)

        let partsLabel = createPaddedLabel(text: "Number of Parts:")
        partsTextField = createTextField(placeholder: "Parts", value: "\(config.parts)")

        let torusMajorLabel = createPaddedLabel(text: "Torus Major:")
        torusMajorTextField = createTextField(placeholder: "Torus Major", value: String(format: "%.2f", config.torusMajor))

        let torusMinorLabel = createPaddedLabel(text: "Torus Minor:")
        torusMinorTextField = createTextField(placeholder: "Torus Minor", value: String(format: "%.2f", config.torusMinor))

        let bevelboxLabel = createPaddedLabel(text: "Bevel Box Size:")
        bevelboxTextField = createTextField(placeholder: "Bevel Box", value: String(format: "%.2f", config.bevelbox))

        let cylinderLabel = createPaddedLabel(text: "Cylinder Diameter:")
        cylinderTextField = createTextField(placeholder: "Cylinder Diameter", value: String(format: "%.2f", config.cylinder))

        let cylinderHeightLabel = createPaddedLabel(text: "Cylinder Height:")
        cylinderHeightTextField = createTextField(placeholder: "Cylinder Height", value: String(format: "%.2f", config.cylinderHeight))

        let storageLabel = createPaddedLabel(text: "Storage Capacity:")
        storageTextField = createTextField(placeholder: "Storage Capacity", value: String(format: "%.2f", config.storage))

        let color1Label = createPaddedLabel(text: "Color 1:")
        color1Button.setTitle("Select Color 1", for: .normal)
        color1Button.backgroundColor = config.color1.uiColor
        color1Button.setTitleColor(.white, for: .normal)
        color1Button.layer.cornerRadius = 10
        color1Button.translatesAutoresizingMaskIntoConstraints = false
        color1Button.addTarget(self, action: #selector(selectColor1), for: .touchUpInside)

        let color2Label = createPaddedLabel(text: "Color 2:")
        color2Button.setTitle("Select Color 2", for: .normal)
        color2Button.backgroundColor = config.color2.uiColor
        color2Button.setTitleColor(.white, for: .normal)
        color2Button.layer.cornerRadius = 10
        color2Button.translatesAutoresizingMaskIntoConstraints = false
        color2Button.addTarget(self, action: #selector(selectColor2), for: .touchUpInside)

        let locationLabel = createPaddedLabel(text: "Location:")
        locationPopupButton = createLocationPopupButton(locations: locations)

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
            createHorizontalStackView(label: color2Label, textField: color2Button),
            createHorizontalStackView(label: locationLabel, textField: locationPopupButton)
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
                textField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -10)
            ])
        } else {
            label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        }

        return stackView
    }

    @objc func generateRandomValues() {
        config = SpaceStationConfig.generateRandomConfig(locations: locations)
        setupForm()
        locationPopupButton.setTitle(config.location, for: .normal)
        locationPopupButton.tag = locations.firstIndex(of: config.location) ?? 0
    }

    @objc func createSpaceStation() {
        // Gather data from text fields
        config.name = nameTextField.text ?? ""
        config.parts = Int(partsTextField.text ?? "") ?? 0
        config.torusMajor = Double(torusMajorTextField.text ?? "") ?? 0.0
        config.torusMinor = Double(torusMinorTextField.text ?? "") ?? 0.0
        config.bevelbox = Double(bevelboxTextField.text ?? "") ?? 0.0
        config.cylinder = Double(cylinderTextField.text ?? "") ?? 0.0
        config.cylinderHeight = Double(cylinderHeightTextField.text ?? "") ?? 0.0
        config.storage = Double(storageTextField.text ?? "") ?? 0.0
        config.location = locations[locationPopupButton.tag]

        // Convert config to JSON string
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let configJsonData = try? encoder.encode(config),
              let configJson = String(data: configJsonData, encoding: .utf8) else {
            print("Failed to encode config to JSON")
            return
        }

        print("Sending config: \(configJson)")

        // Retrieve email and authToken
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        // Call the API to create the space station
        OpenspaceAPI.shared.createSpaceStation(email: email, authToken: authToken, configJson: configJson, spaceStationName: config.name) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Handle success (e.g., show a success message)
                    print("Space station created successfully")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    // Handle error (e.g., show an error message)
                    print("Failed to create space station: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func selectColor1() {
        colorPickerCompletion = { selectedColor in
            self.config.color1 = selectedColor.codableColor
            self.color1Button.backgroundColor = selectedColor
        }
        presentColorPicker(for: config.color1.uiColor)
    }

    @objc func selectColor2() {
        colorPickerCompletion = { selectedColor in
            self.config.color2 = selectedColor.codableColor
            self.color2Button.backgroundColor = selectedColor
        }
        presentColorPicker(for: config.color2.uiColor)
    }

    func presentColorPicker(for color: UIColor) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = color
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        colorPicker.popoverPresentationController?.sourceView = self.view
        colorPicker.popoverPresentationController?.sourceRect = self.view.bounds
        colorPicker.popoverPresentationController?.permittedArrowDirections = .up
        self.present(colorPicker, animated: true, completion: nil)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorPickerCompletion?(viewController.selectedColor)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorPickerCompletion?(viewController.selectedColor)
        colorPickerCompletion = nil
    }

    func createLocationPopupButton(locations: [String]) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Location", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showLocationMenu), for: .touchUpInside)
        return button
    }

    @objc func showLocationMenu() {
        let alertController = UIAlertController(title: "Select Location", message: nil, preferredStyle: .actionSheet)

        for (index, location) in locations.enumerated() {
            let action = UIAlertAction(title: location, style: .default) { _ in
                self.locationPopupButton.setTitle(location, for: .normal)
                self.locationPopupButton.tag = index
                self.config.location = location
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = locationPopupButton
            popoverController.sourceRect = locationPopupButton.bounds
        }

        present(alertController, animated: true, completion: nil)
    }
}

