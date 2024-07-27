import UIKit

class BackgroundImageViewController: UIViewController {

    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!
    static let availableBackgroundImages = ["conenebula.jpg", "rainbowgalaxy.jpg", "purplegalaxy.jpg",
    "starryai_3et02i.jpg", "starryai_5p4zs.jpg", "starryai_7ejn3.jpeg", "starryai_ddgnr.jpg", "starryai_i0q64.jpg",
    "starryai_ih7gql.jpg", "starryai_oafnf.jpg","starryai_ofj82.jpg", "starryai_qw7etf.jpg"]

    // Property to set the background image name
    var backgroundImageName: String = BackgroundImageViewController.availableBackgroundImages.randomElement() ?? "conenebula.jpg" {
          didSet {
              setupBackgroundImageView()
          }
      }

    // Property to set the overlay alpha
    var overlayAlpha: CGFloat = 0.4 {
        didSet {
            setupBackgroundOverlay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBackgroundImageView()
        setupBackgroundOverlay()
        applyFilterBasedOnUserInterfaceStyle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = calculateBackgroundFrame()
        if let backgroundImageView = backgroundImageView, let overlayView = overlayView {
            backgroundImageView.frame = frame
            overlayView.frame = frame
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyFilterBasedOnUserInterfaceStyle()
        }
    }

    private func calculateBackgroundFrame() -> CGRect {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let frameHeight = view.bounds.height - (tabBarHeight > 0 ? tabBarHeight : 0)
        return CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: frameHeight
        )
    }

    private func setupBackgroundImageView() {
        if backgroundImageView == nil {
            backgroundImageView = UIImageView(frame: calculateBackgroundFrame())
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            view.insertSubview(backgroundImageView, at: 0)
        }

        if let image = UIImage(named: backgroundImageName) {
            backgroundImageView.image = image
            print("Background image loaded successfully")
        } else {
            print("Failed to load background image")
            backgroundImageView.backgroundColor = .red
        }
    }

    private func setupBackgroundOverlay() {
        if overlayView == nil {
            overlayView = UIView(frame: calculateBackgroundFrame())
            view.insertSubview(overlayView, aboveSubview: backgroundImageView)
        }
        overlayView.backgroundColor = .systemBackground.withAlphaComponent(overlayAlpha)
    }

    private func applyFilterBasedOnUserInterfaceStyle() {
        guard let backgroundImageView = backgroundImageView, let backgroundImage = backgroundImageView.image else {
            print("No background image to apply filter to")
            return
        }

        let filteredImage: UIImage?
        if traitCollection.userInterfaceStyle == .dark {
            filteredImage = backgroundImage // .applyDarkFilter()
        } else {
            filteredImage = backgroundImage // .applyLightFilter()
        }

        if let filteredImage = filteredImage {
            backgroundImageView.image = filteredImage
            print("Filter applied based on user interface style: \(traitCollection.userInterfaceStyle.rawValue)")
        } else {
            print("Failed to apply filter. Using original image.")
            backgroundImageView.image = backgroundImage
        }
    }

    func configureButton(_ button: UIButton) {
        var config = UIButton.Configuration.filled()

        let backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.0, green: 0.0, blue: 0.502, alpha: 1.0) // Dark blue color
            default:
                return UIColor(red: 0.678, green: 0.847, blue: 0.902, alpha: 1.0) // Light blue color
            }
        }

        let foregroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }

        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = foregroundColor

        let borderColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }

        config.background.strokeColor = borderColor
        config.background.strokeWidth = 2.0

        config.cornerStyle = .medium

        button.configuration = config
    }

}
