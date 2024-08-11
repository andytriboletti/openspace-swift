import UIKit

class MineralTableViewCell: UITableViewCell {
    let mineralImageView = UIImageView()
    let mineralLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Disable autoresizing mask translation for Auto Layout
        mineralImageView.translatesAutoresizingMaskIntoConstraints = false
        mineralLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure image view
        mineralImageView.contentMode = .scaleAspectFit
        contentView.addSubview(mineralImageView)

        // Configure label
        mineralLabel.textColor = .label
        mineralLabel.numberOfLines = 1
        contentView.addSubview(mineralLabel)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            // Image view constraints
            mineralImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mineralImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mineralImageView.widthAnchor.constraint(equalToConstant: 40),
            mineralImageView.heightAnchor.constraint(equalToConstant: 40),

            // Label constraints
            mineralLabel.leadingAnchor.constraint(equalTo: mineralImageView.trailingAnchor, constant: 10),
            mineralLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mineralLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mineralLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
