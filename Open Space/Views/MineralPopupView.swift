import UIKit
import SwiftUI

struct MineralPopupView: View {
    let mineral: String
    let amount: Int
    let onDismiss: () -> Void

    // Determine the background color based on the color scheme
    private var backgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        })
    }

    // Determine the text color based on the color scheme
    private var textColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        })
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: UIImage(named: mineral.lowercased()) ?? UIImage(systemName: "mountain.2.fill")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Text("Congratulations!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(textColor)

            Text("You claimed your hourly treasure of \(amount) \(mineral).")
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)

            Button("OK") {
                onDismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
