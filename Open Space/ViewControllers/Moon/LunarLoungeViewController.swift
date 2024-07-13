import UIKit
import WebKit

class LunarLoungeViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    var webView: WKWebView!
    let titleLabel = UILabel()
    var checkTimer: Timer?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        let contentController = WKUserContentController()
        contentController.add(self, name: "logHandler")
        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        view = UIView()
        view.addSubview(webView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupTitleLabel()
        setupWebViewConstraints()
        enableConsoleLogCapture()

        if let url = URL(string: "https://server3.openspace.greenrobot.com/comments/index2.php") {
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
        print("openspace webview closed")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed to load page: \(error.localizedDescription)")
        handleWebViewError(error)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page finished loading: \(webView.url?.absoluteString ?? "unknown URL")")
        printCookies()
        inspectPageContent()
    }


    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        handleWebViewError(NSError(domain: "WebContentProcessTerminated", code: 1, userInfo: nil))
    }

    func handleWebViewError(_ error: Error) {
        print("WebView encountered an error: \(error.localizedDescription)")

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
        checkTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkPageContent), userInfo: nil, repeats: true)
    }

    @objc func checkPageContent() {
        let script = """
        try {
            return {
                content: document.body.innerText,
                url: window.location.href,
                readyState: document.readyState
            };
        } catch (error) {
            return {
                error: error.toString(),
                stack: error.stack,
                line: error.lineNumber,
                column: error.columnNumber
            };
        }
        """

        webView.evaluateJavaScript(script) { [weak self] (result, error) in
            guard let self = self else { return }

            if let info = result as? [String: Any] {
                if let jsError = info["error"] as? String {
                    print("JavaScript error: \(jsError)")
                    if let stack = info["stack"] as? String {
                        print("Error stack: \(stack)")
                    }
                    if let line = info["line"] as? Int, let column = info["column"] as? Int {
                        print("Error location: Line \(line), Column \(column)")
                    }
                } else if let content = info["content"] as? String {
                    print("Page content: \(content)")
                    if content.contains("1") {
                        self.reloadPage()
                    }
                }
            } else if let error = error {
                print("Evaluation error: \(error.localizedDescription)")
            }
        }
    }

    func reloadPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performReload), object: nil)
        perform(#selector(performReload), with: nil, afterDelay: 5.0)
    }

    @objc func performReload() {
        let randomValue = Int.random(in: 0..<10000)
        if let currentURL = webView.url,
           var urlComponents = URLComponents(url: currentURL, resolvingAgainstBaseURL: true) {

            urlComponents.queryItems = urlComponents.queryItems?.filter { $0.name != "rand" } ?? []
            urlComponents.queryItems?.append(URLQueryItem(name: "rand", value: String(randomValue)))

            if let newURL = urlComponents.url {
                let request = URLRequest(url: newURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                webView.load(request)
            }
        }
    }

    func printCookies() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("Cookie: \(cookie)")
            }
        }
    }

    func inspectPageContent() {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
            if let htmlContent = result as? String {
                print("Page HTML content:")
                print(htmlContent)
            } else if let error = error {
                print("Error getting HTML content: \(error.localizedDescription)")
            }
        }
    }

    func clearWebViewCache() {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0)) { }

        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
            }
        }
    }

    @objc func refreshButtonTapped() {
        clearWebViewCache()
        reloadPage()
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
            print("Console log: \(message.body)")
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
        titleLabel.textColor = .white
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
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
