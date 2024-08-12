//
//  PopupContainerView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 8/11/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import SwiftUI

struct PopupContainerView: View {
    @State private var showPopup: Bool = true
    let mineral: String
    let amount: Int
    let checkDailyTreasureAvailability: () -> Void
    let dismiss: () -> Void

    var body: some View {
        Color.clear
            .popup(isPresented: $showPopup) {
                MineralPopupView(mineral: mineral, amount: amount) {
                    showPopup = false
                    dismiss()
                }
            } customize: {
                $0
                    .type(.floater())
                    .position(.center)
                    .animation(.spring())
                    .autohideIn(nil)
                    .dragToDismiss(true)
                    .closeOnTap(false)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }
            .onChange(of: showPopup) { newValue in
                if !newValue {
                    dismiss()
                }
            }
    }
}
