
import OnboardingKit
import SwiftUI

public struct OnboardingView: View {
    @State private var currentPage: Int = 0
    private let pages = ["Welcome", "Features", "Get Started"]
    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    public var body: some View {
        VStack {
            Text(pages[currentPage])
                .font(.largeTitle)
                .padding()

            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
                .padding()

            Text("This is some descriptive text for page \(currentPage + 1)")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                if currentPage < pages.count - 1 {
                    currentPage += 1
                } else {
                    onFinish()
                }
            }) {
                Text(currentPage < pages.count - 1 ? "Next" : "Finish")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
