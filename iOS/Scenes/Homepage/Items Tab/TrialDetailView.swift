//
// TrialDetailView.swift
// Proton Pass - Created on 26/05/2023.
// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct TrialDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let daysLeft: Int
    let onUpgrade: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Image(uiImage: PassIcon.trialDetail)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text("Enjoy your free trial")
                    .font(.title.bold())

                Text("For next-level password management:")
                    .padding(.bottom)

                VStack {
                    perk(title: "Multiple vaults", icon: PassIcon.trialVaults)
                    PassDivider()
                    perk(title: "Integrated 2FA authenticator", icon: PassIcon.trial2FA)
                    PassDivider()
                    perk(title: "Custom fields", icon: PassIcon.trialCustomFields)
                }
                .padding()
                .background(Color(uiColor: PassColor.inputBackgroundNorm))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.vertical, 32)

                Button(action: onUpgrade) {
                    Text("Upgrade to keep these features")
                        .font(.title3)
                        .padding(16)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(LinearGradient(colors: [
                        .init(red: 174 / 255, green: 80 / 255, blue: 96 / 255),
                        .init(red: 113 / 255, green: 77 / 255, blue: 255 / 255)
                    ], // swiftlint:disable:this literal_expression_end_indentation
                    startPoint: .leading,
                    endPoint: .trailing))
                .clipShape(Capsule())

                Text("\(daysLeft) day(s) left in your trial period")
                    .font(.callout)
                    .padding(.top)

                Button(action: onLearnMore) {
                    Text("Learn more")
                        .font(.callout)
                        .foregroundColor(Color(uiColor: PassColor.interactionNormMajor2))
                        .underline(color: Color(uiColor: PassColor.interactionNormMajor2))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .foregroundColor(Color(uiColor: PassColor.textNorm))
            .background(Color(uiColor: PassColor.backgroundNorm))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CircleButton(icon: IconProvider.cross,
                                 iconColor: PassColor.interactionNormMajor2,
                                 backgroundColor: PassColor.interactionNormMinor1,
                                 action: dismiss.callAsFunction)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func perk(title: String, icon: UIImage) -> some View {
        Label(title: {
            Text(title)
        }, icon: {
            Image(uiImage: icon)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 32)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
