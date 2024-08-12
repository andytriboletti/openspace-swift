//
//  MineralPopupView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 8/11/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import SwiftUI

struct MineralPopupView: View {
    let mineral: String
    let amount: Int
    let onDismiss: () -> Void

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

            Text("You claimed your hourly treasure of \(amount) \(mineral).")
                .multilineTextAlignment(.center)

            Button("OK") {
                onDismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
