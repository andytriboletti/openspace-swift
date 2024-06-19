import UIKit

struct SpaceStationConfig {
    var parts: Int
    var torusMajor: Double
    var torusMinor: Double
    var bevelbox: Double
    var cylinder: Double
    var cylinderHeight: Double
    var storage: Double

    static func generateRandomConfig() -> SpaceStationConfig {
        return SpaceStationConfig(
            parts: Int.random(in: 3...8),
            torusMajor: Double.random(in: 2.0...5.0),
            torusMinor: Double.random(in: 0.1...0.5),
            bevelbox: Double.random(in: 0.2...0.5),
            cylinder: Double.random(in: 0.5...3.0),
            cylinderHeight: Double.random(in: 0.3...1.0),
            storage: Double.random(in: 0.5...1.0)
        )
    }
}

class ConfigureSpaceStationViewController: UIViewController {

    var config = SpaceStationConfig(parts: 3, torusMajor: 2.0, torusMinor: 0.1, bevelbox: 0.2, cylinder: 0.5, cylinderHeight: 0.3, storage: 0.5)

    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        setupScrollView()
        setupForm()
    }

    func setupScrollView() {
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
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupForm() {
        let titleLabel = UILabel()
        titleLabel.text = "Space Station Configuration"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .white
        titleLabel.textColor = .black
        let partsLabel = createLabel(text: "Number of Parts:")
        let partsTextField = createTextField(placeholder: "Parts", value: "\(config.parts)")

        let torusMajorLabel = createLabel(text: "Torus Major:")
        let torusMajorTextField = createTextField(placeholder: "Torus Major", value: "\(config.torusMajor)")

        let torusMinorLabel = createLabel(text: "Torus Minor:")
        let torusMinorTextField = createTextField(placeholder: "Torus Minor", value: "\(config.torusMinor)")

        let bevelboxLabel = createLabel(text: "Bevel Box Size:")
        let bevelboxTextField = createTextField(placeholder: "Bevel Box", value: "\(config.bevelbox)")

        let cylinderLabel = createLabel(text: "Cylinder Diameter:")
        let cylinderTextField = createTextField(placeholder: "Cylinder Diameter", value: "\(config.cylinder)")

        let cylinderHeightLabel = createLabel(text: "Cylinder Height:")
        let cylinderHeightTextField = createTextField(placeholder: "Cylinder Height", value: "\(config.cylinderHeight)")

        let storageLabel = createLabel(text: "Storage Capacity:")
        let storageTextField = createTextField(placeholder: "Storage Capacity", value: "\(config.storage)")

        let generateButton = UIButton(type: .system)
        generateButton.setTitle("Generate Random Values", for: .normal)
        generateButton.backgroundColor = .orange
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 10
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateRandomValues), for: .touchUpInside)

        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Space Station", for: .normal)
        createButton.backgroundColor = .green
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createSpaceStation), for: .touchUpInside)

        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .blue
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let formStackView = UIStackView(arrangedSubviews: [
            createHorizontalStackView(label: partsLabel, textField: partsTextField),
            createHorizontalStackView(label: torusMajorLabel, textField: torusMajorTextField),
            createHorizontalStackView(label: torusMinorLabel, textField: torusMinorTextField),
            createHorizontalStackView(label: bevelboxLabel, textField: bevelboxTextField),
            createHorizontalStackView(label: cylinderLabel, textField: cylinderTextField),
            createHorizontalStackView(label: cylinderHeightLabel, textField: cylinderHeightTextField),
            createHorizontalStackView(label: storageLabel, textField: storageTextField)
        ])
        formStackView.axis = .vertical
        formStackView.spacing = 20
        formStackView.alignment = .leading
        formStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(formStackView)
        contentView.addSubview(generateButton)
        contentView.addSubview(createButton)
        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            formStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            generateButton.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 20),
            generateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            generateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            generateButton.heightAnchor.constraint(equalToConstant: 50),

            createButton.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),

            backButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createTextField(placeholder: String, value: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = value
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return textField
    }

    func createHorizontalStackView(label: UILabel, textField: UITextField) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill

        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 150).isActive = true

        return stackView
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
}
