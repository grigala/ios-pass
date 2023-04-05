//
// SettingView.swift
// Proton Pass - Created on 31/03/2023.
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

import Client
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct SettingView: View {
    @StateObject var viewModel: SettingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: kItemDetailSectionPadding) {
                untitledSection
                clipboardSection
                if let primaryVault = viewModel.vaultsManager.getPrimaryVault() {
                    primaryVaultSection(vault: primaryVault)
                }
                applicationSection
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: PassColor.backgroundNorm))
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.large)
        .theme(viewModel.selectedTheme)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleButton(icon: UIDevice.current.isIpad ?
                             IconProvider.chevronLeft : IconProvider.chevronDown,
                             color: PassColor.interactionNorm,
                             action: viewModel.goBack)
            }
        }
    }

    private var untitledSection: some View {
        VStack(spacing: 0) {
            OptionRow(action: viewModel.editDefaultBrowser,
                      title: "Default browser",
                      height: .tall,
                      content: { Text(viewModel.selectedBrowser.description) },
                      trailing: { ChevronRight() })

            PassDivider()

            OptionRow(
                action: viewModel.editTheme,
                title: "Theme",
                height: .tall,
                content: {
                    Label(title: {
                        Text(viewModel.selectedTheme.description)
                    }, icon: {
                        Image(uiImage: viewModel.selectedTheme.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    })
                },
                trailing: { ChevronRight() })
        }
        .roundedEditableSection()
    }

    private var clipboardSection: some View {
        VStack(spacing: kItemDetailSectionPadding) {
            Text("Clipboard")
                .sectionHeaderText()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                OptionRow(action: viewModel.editClipboardExpiration,
                          title: "Clear clipboard",
                          height: .tall,
                          content: { Text(viewModel.selectedClipboardExpiration.description) },
                          trailing: { ChevronRight() })

                PassDivider()

                OptionRow(height: .tall) {
                    Toggle(isOn: $viewModel.shareClipboard) {
                        Text("Share clipboard between devices")
                    }
                    .tint(Color(uiColor: PassColor.interactionNorm))
                }
            }
            .roundedEditableSection()
        }
    }

    private func primaryVaultSection(vault: Vault) -> some View {
        VStack(spacing: kItemDetailSectionPadding) {
            Text("Vaults")
                .sectionHeaderText()
                .frame(maxWidth: .infinity, alignment: .leading)

            OptionRow(action: { viewModel.edit(primaryVault: vault) },
                      title: "Primary vault",
                      height: .tall,
                      content: { Text(vault.name) },
                      leading: { VaultThumbnail(vault: vault) },
                      trailing: { ChevronRight() })
            .roundedEditableSection()

            Text("You can not delete a primary vault")
                .sectionTitleText()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var applicationSection: some View {
        VStack(spacing: kItemDetailSectionPadding) {
            Text("Application")
                .sectionHeaderText()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                TextOptionRow(title: "View logs", action: viewModel.viewLogs)

                PassDivider()

                OptionRow(
                    action: viewModel.forceSync,
                    height: .medium,
                    content: {
                        Text("Force Synchronization")
                            .foregroundColor(Color(uiColor: PassColor.interactionNorm))
                    },
                    trailing: {
                        CircleButton(icon: IconProvider.arrowRotateRight,
                                     color: PassColor.interactionNorm,
                                     action: {})
                        .disabled(true)
                    })
            }
            .roundedEditableSection()

            Text("Download all your items again to make sure you are in sync.")
                .sectionTitleText()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
