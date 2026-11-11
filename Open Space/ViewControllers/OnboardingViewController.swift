import UIKit
import SwiftUI
import Defaults

class OnboardingViewController: UIViewController {
    // Creating 3D objects is switched off and the mineral packs are no longer sold, so the
    // "Create Objects" (Replicator) and "Earn ... from Objects" pages were removed.
    private let pages: [(title: String, image: String)] = [
        ("Welcome To Open Space: Land On A Planet Or Navigate To A Space Object", "landornavigate"),
        ("Collect Minerals And View Them", "claimminerals"),
        ("Get To The Top Of The Galactic Leaderboard", "leaderboard")
    ]
    private var currentPage = 0

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Next To Continue"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .systemBlue
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContent()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        [titleLabel, imageView, instructionLabel, nextButton, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),

            instructionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            nextButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),

            pageControl.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func updateContent() {
        titleLabel.text = pages[currentPage].title
        imageView.image = UIImage(named: pages[currentPage].image)
        nextButton.setTitle(currentPage < pages.count - 1 ? "Next" : "Finish", for: .normal)
        pageControl.currentPage = currentPage
    }

    @objc private func nextButtonTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            updateContent()
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        // Set the flag indicating onboarding has been completed
        Defaults[.hasWatchedOnboarding] = 1

        // Dismiss the onboarding and return to the sign-in screen
        dismiss(animated: true) {
            if let signInViewController = self.presentingViewController as? SignInViewController {
                signInViewController.performSegue(withIdentifier: "goToSignedIn", sender: signInViewController)
            }
        }
    }
}
