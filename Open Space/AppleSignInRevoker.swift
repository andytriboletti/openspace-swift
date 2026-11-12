//
//  AppleSignInRevoker.swift
//  Open Space
//
//  Apple requires apps that offer Sign in with Apple to revoke the user's Apple tokens when the
//  account is deleted. This asks the player to confirm with Apple once more, which returns a fresh
//  authorization code and identity token. It signs Firebase in again with them (deleting a Firebase
//  account needs a recent sign-in) and then revokes the Apple token.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

final class AppleSignInRevoker: NSObject {

    enum Outcome {
        case revoked
        case cancelled
        case failed(Error)
    }

    /// True when the signed-in Firebase account uses Sign in with Apple (directly, or a guest
    /// account that was saved with Apple).
    static func isAppleUser(_ user: User?) -> Bool {
        user?.providerData.contains { $0.providerID == "apple.com" } ?? false
    }

    /// Shows Apple's confirmation sheet, then re-authenticates Firebase and revokes the Apple token.
    /// `completion` runs on the main queue.
    static func revoke(presentingFrom view: UIView, completion: @escaping (Outcome) -> Void) {
        let revoker = AppleSignInRevoker(anchor: view.window, completion: completion)
        active = revoker
        revoker.start()
    }

    // Keeps the revoker alive while Apple's sheet is up (the controller holds its delegate weakly).
    private static var active: AppleSignInRevoker?

    private weak var anchor: UIWindow?
    private var completion: ((Outcome) -> Void)?
    private var rawNonce = ""

    private init(anchor: UIWindow?, completion: @escaping (Outcome) -> Void) {
        self.anchor = anchor
        self.completion = completion
    }

    private func start() {
        rawNonce = Self.randomNonce()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
        request.nonce = Self.sha256(rawNonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func finish(_ outcome: Outcome) {
        DispatchQueue.main.async {
            self.completion?(outcome)
            self.completion = nil
            Self.active = nil
        }
    }

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, length, &bytes) == errSecSuccess else {
            return UUID().uuidString + UUID().uuidString
        }
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private static func error(_ message: String) -> NSError {
        NSError(domain: "AppleSignInRevoker", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

extension AppleSignInRevoker: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let codeData = appleCredential.authorizationCode,
              let authorizationCode = String(data: codeData, encoding: .utf8),
              let tokenData = appleCredential.identityToken,
              let identityToken = String(data: tokenData, encoding: .utf8) else {
            finish(.failed(Self.error("Apple didn't return a sign-in code.")))
            return
        }
        guard let user = Auth.auth().currentUser else {
            finish(.failed(Self.error("You're not signed in.")))
            return
        }

        // Re-authenticating first also checks that this is the same Apple ID as the account:
        // a different Apple ID fails here, so its token is never revoked by mistake.
        let credential = OAuthProvider.appleCredential(withIDToken: identityToken, rawNonce: rawNonce, fullName: nil)
        user.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                self.finish(.failed(error))
                return
            }
            Auth.auth().revokeToken(withAuthorizationCode: authorizationCode) { error in
                if let error = error {
                    self.finish(.failed(error))
                } else {
                    self.finish(.revoked)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            finish(.cancelled)
        } else {
            finish(.failed(error))
        }
    }
}

extension AppleSignInRevoker: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        anchor ?? ASPresentationAnchor()
    }
}
