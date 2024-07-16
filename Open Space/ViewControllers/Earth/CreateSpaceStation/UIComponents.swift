//
//  UIComponents.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/15/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

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

func createGenerateButton(target: Any, action: Selector) -> UIButton {
    let generateButton = UIButton(type: .system)
    generateButton.setTitle("Generate Random Values", for: .normal)
    generateButton.backgroundColor = .orange
    generateButton.setTitleColor(.white, for: .normal)
    generateButton.layer.cornerRadius = 10
    generateButton.translatesAutoresizingMaskIntoConstraints = false
    generateButton.addTarget(target, action: action, for: .touchUpInside)
    return generateButton
}

func createCreateButton(target: Any, action: Selector) -> UIButton {
    let createButton = UIButton(type: .system)
    createButton.setTitle("Create Space Station", for: .normal)
    createButton.backgroundColor = .green
    createButton.setTitleColor(.white, for: .normal)
    createButton.layer.cornerRadius = 10
    createButton.translatesAutoresizingMaskIntoConstraints = false
    createButton.addTarget(target, action: action, for: .touchUpInside)
    return createButton
}

func createBackButton(target: Any, action: Selector) -> UIButton {
    let backButton = UIButton(type: .system)
    backButton.setTitle("Back", for: .normal)
    backButton.backgroundColor = .blue
    backButton.setTitleColor(.white, for: .normal)
    backButton.layer.cornerRadius = 10
    backButton.translatesAutoresizingMaskIntoConstraints = false
    backButton.addTarget(target, action: action, for: .touchUpInside)
    return backButton
}

func createLocationPopupButton(target: Any, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle("Select Location", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(target, action: action, for: .touchUpInside)
    return button
}
