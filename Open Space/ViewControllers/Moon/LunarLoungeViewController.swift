import UIKit
import WebKit

class LunarLoungeViewController: BackgroundImageViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    var webView: WKWebView!
    let titleLabel = UILabel()
    var checkTimer: Timer?
    let originalURL = "https://server3.openspace.greenrobot.com/comments/index2.php"

    func setCustomUserAgent(for webView: WKWebView) {
        #if targetEnvironment(macCatalyst)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        #else
        #if targetEnvironment(simulator)
        // Code specific to the simulator
        //webView.customUserAgent = "Mozilla/5.0 (iPhone Simulator; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        #else
        let deviceType = UIDevice.current.userInterfaceIdiom
        if deviceType == .phone {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        } else if deviceType == .pad {
            webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        }
        #endif
        #endif
    }


    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        //unneeded javascript enabled by default
        //webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        let contentController = WKUserContentController()
        contentController.add(self, name: "logHandler")
        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        //webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        //webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        setCustomUserAgent(for: webView)
        view = UIView()

        view.addSubview(webView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupTitleLabel()
        setupWebViewConstraints()
        enableConsoleLogCapture()

        let returnButton = UIButton(type: .system)
        let logoutButton = UIButton(type: .system)

        setupReturnButton(returnButton)
        setupLogoutButton(logoutButton, above: returnButton)

        if let url = URL(string: originalURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        startCheckingForContent()

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        navigationItem.rightBarButtonItem = refreshButton
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webViewDidClose(_ webView: WKWebView) {
        //print("openspace webview closed")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //print("Failed to load page: \(error.localizedDescription)")
        handleWebViewError(error)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("Page finished loading: \(webView.url?.absoluteString ?? "unknown URL")")
        printCookies()
        checkPageContentWithoutJavaScript()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        handleWebViewError(NSError(domain: "WebContentProcessTerminated", code: 1, userInfo: nil))
    }

    func handleWebViewError(_ error: Error) {
        //print("WebView encountered an error: \(error.localizedDescription)")

        if self.presentedViewController == nil {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "An error occurred: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func startCheckingForContent() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkPageContentWithoutJavaScript), userInfo: nil, repeats: true)
    }

    @objc func checkPageContentWithoutJavaScript() {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self] (result, error) in
            guard let self = self else { return }

            if let htmlContent = result as? String {
                //print("Page HTML content:")
                //print(htmlContent)

                if htmlContent.contains("<body>1<script") {
                    //print("Detected problematic HTML content, reloading original page...")
                    self.loadOriginalPage()
                }
            } else if let error = error {
                //print("Error getting HTML content: \(error.localizedDescription)")
            }
        }
    }

    func loadOriginalPage() {
        if let url = URL(string: originalURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @objc func refreshButtonTapped() {
        clearWebViewCache()
        loadOriginalPage()
    }

    func printCookies() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                //print("Cookie: \(cookie)")
            }
        }
    }

    func clearWebViewCache() {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) {
            //print("Cleared all cookies and cache")
        }
    }

    func enableConsoleLogCapture() {
        let script = """
        function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
        console.log = captureLog;
        console.error = captureLog;
        console.warn = captureLog;
        console.info = captureLog;
        """

        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            //print("Console log: \(message.body)")
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "JavaScript Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "JavaScript Confirm", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "JavaScript Prompt", message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completionHandler(nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    // Setup the title label
    func setupTitleLabel() {
        titleLabel.text = "Lunar Lounge"
       // titleLabel.textColor =
        titleLabel.backgroundColor = .systemBackground
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    // Setup the gradient background
    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = randomGradientColors()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // Generate random gradient colors
    func randomGradientColors() -> [CGColor] {
        let colors = [
            UIColor.red.cgColor,
            UIColor.blue.cgColor,
            UIColor.green.cgColor,
            UIColor.orange.cgColor,
            UIColor.purple.cgColor,
            UIColor.yellow.cgColor
        ]
        return [colors.randomElement()!, colors.randomElement()!]
    }

    // Setup the web view constraints
    func setupWebViewConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120) // Adjust for buttons
        ])
    }

    // Setup the return button
    func setupReturnButton(_ returnButton: UIButton) {
        returnButton.setTitle("Return to Moon Base", for: .normal)
        returnButton.setTitleColor(.white, for: .normal)
        returnButton.backgroundColor = .systemBlue
        returnButton.layer.cornerRadius = 10
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.addTarget(self, action: #selector(returnToMoonBase), for: .touchUpInside)
        view.addSubview(returnButton)

        NSLayoutConstraint.activate([
            returnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            returnButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            returnButton.widthAnchor.constraint(equalToConstant: 200),
            returnButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Setup the logout button
    func setupLogoutButton(_ logoutButton: UIButton, above returnButton: UIButton) {
        logoutButton.setTitle("Logout of Facebook", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 10
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: returnButton.topAnchor, constant: -10),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func returnToMoonBase() {
        // Dismiss the current view controller to return to Moon Base
        self.dismiss(animated: true, completion: nil)
        //print("Returning to Moon Base")
    }

    @objc func logout() {
        clearWebViewCache()
        loadOriginalPage()
        //print("Logged out and reloaded the comment page")
    }
}
