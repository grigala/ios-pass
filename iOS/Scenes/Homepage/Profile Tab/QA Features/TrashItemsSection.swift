//
// TrashItemsSection.swift
// Proton Pass - Created on 05/05/2023.
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
import SwiftUI
import UIComponents

struct TrashItemsSection: View {
    private let itemRepository: ItemRepositoryProtocol
    private let shareRepository: ShareRepositoryProtocol
    private let bannerManager: BannerManager

    init(itemRepository: ItemRepositoryProtocol,
         shareRepository: ShareRepositoryProtocol,
         bannerManager: BannerManager) {
        self.itemRepository = itemRepository
        self.shareRepository = shareRepository
        self.bannerManager = bannerManager
    }

    var body: some View {
        NavigationLink(destination: {
            TrashItemsView(itemRepository: itemRepository,
                           shareRepository: shareRepository,
                           bannerManager: bannerManager)
        }, label: {
            Text("Trash all items")
        })
    }
}

private struct TrashItemsView: View {
    @StateObject private var viewModel: TrashItemsViewModel
    @State private var selectedUiModel: VaultListUiModel?

    init(itemRepository: ItemRepositoryProtocol,
         shareRepository: ShareRepositoryProtocol,
         bannerManager: BannerManager) {
        _viewModel = .init(wrappedValue: .init(itemRepository: itemRepository,
                                               shareRepository: shareRepository,
                                               bannerManager: bannerManager))
    }

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case let .loaded(uiModels):
            vaultList(uiModels)
        case let .error(error):
            RetryableErrorView(errorMessage: error.localizedDescription,
                               onRetry: viewModel.loadVaults)
        }
    }

    @ViewBuilder
    private func vaultList(_ uiModels: [VaultListUiModel]) -> some View {
        let showingAlert = Binding<Bool>(get: {
            selectedUiModel != nil
        }, set: { newValue in
            if !newValue {
                selectedUiModel = nil
            }
        })
        Form {
            Section(content: {
                ForEach(uiModels, id: \.hashValue) { uiModel in
                    let vault = uiModel.vault
                    let icon = vault.displayPreferences.icon.icon.bigImage
                    let color = vault.displayPreferences.color.color.color
                    Button(action: {
                        selectedUiModel = uiModel
                    }, label: {
                        VaultRow(thumbnail: {
                                     CircleButton(icon: icon,
                                                  iconColor: color,
                                                  backgroundColor: color.withAlphaComponent(0.16))
                                 },
                                 title: vault.name,
                                 itemCount: uiModel.itemCount,
                                 isSelected: false,
                                 height: 44)
                    })
                    .buttonStyle(.plain)
                }
            }, header: {
                Text("\(uiModels.count) vault(s) in total")
            })
        }
        .navigationTitle("Select to trash all items")
        .alert("Trash all items",
               isPresented: showingAlert,
               actions: {
                   Button(role: .cancel, label: { Text("Cancel") })
                   Button(role: .destructive,
                          action: {
                              if let selectedUiModel {
                                  viewModel.trashItems(for: selectedUiModel.vault)
                              }
                          },
                          label: {
                              Text("Yes")
                          })
               },
               message: {
                   if let selectedUiModel {
                       Text("Vault \"\(selectedUiModel.vault.name)\" with \(selectedUiModel.itemCount) item(s)")
                   }
               })
    }
}

private final class TrashItemsViewModel: ObservableObject {
    enum State {
        case loading
        case loaded([VaultListUiModel])
        case error(Error)
    }

    @Published private(set) var state = State.loading

    private let itemRepository: ItemRepositoryProtocol
    private let shareRepository: ShareRepositoryProtocol
    private let bannerManager: BannerManager

    init(itemRepository: ItemRepositoryProtocol,
         shareRepository: ShareRepositoryProtocol,
         bannerManager: BannerManager) {
        self.itemRepository = itemRepository
        self.shareRepository = shareRepository
        self.bannerManager = bannerManager
        loadVaults()
    }

    func loadVaults() {
        Task { @MainActor in
            do {
                state = .loading
                let items = try await itemRepository.getAllItems()
                let vaults = try await shareRepository.getVaults()

                let vaultListUiModels: [VaultListUiModel] = vaults.map { vault in
                    let activeItems =
                        items.filter { $0.item.itemState == .active && $0.shareId == vault.shareId }
                    return .init(vault: vault, itemCount: activeItems.count)
                }
                state = .loaded(vaultListUiModels)
            } catch {
                state = .error(error)
            }
        }
    }

    func trashItems(for vault: Vault) {
        Task { @MainActor in
            do {
                bannerManager.displayBottomInfoMessage("Trashing all items of \"\(vault.name)\"")
                let items = try await itemRepository.getItems(shareId: vault.shareId, state: .active)
                try await itemRepository.trashItems(items)
                loadVaults()
                bannerManager.displayBottomSuccessMessage("Trashed all items of \"\(vault.name)\"")
            } catch {
                bannerManager.displayTopErrorMessage(error)
            }
        }
    }
}
