import SwiftUI
import Defaults

struct UsernameEntryView: View {
    var completion: (String) -> Void
    @Binding var username: String
    @State private var enteredUsername: String = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Enter username", text: $enteredUsername)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Button(action: submitUsername) {
                Text("Submit")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
    }

    func submitUsername() {
        print("Entered username: \(enteredUsername)")
        if isValidUsername(enteredUsername) {
            errorMessage = nil
            username = enteredUsername
            print("Username set: \(username)")

            let email = Defaults[.email]

            OpenspaceAPI.shared.submitToServer(username: username, email: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error submitting to server: \(error.localizedDescription)")
                    } else {
                        print("Successfully submitted to server")
                        completion(enteredUsername)
                        presentationMode.wrappedValue.dismiss()  // Dismiss the view
                    }
                }
            }
        } else {
            errorMessage = "Username must contain only letters and numbers and be between 3 and 20 characters."
        }
    }

    func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }
}
