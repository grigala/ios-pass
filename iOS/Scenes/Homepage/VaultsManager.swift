//
// VaultsManager.swift
// Proton Pass - Created on 07/03/2023.
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
import Core
import CryptoKit
import ProtonCore_Login

enum VaultManagerState {
    case loading
    case loaded(vaults: [VaultContentUiModel], trashedItems: [ItemUiModel])
    case error(Error)
}

enum VaultSelection {
    case all
    case precise(Vault)
    case trash

    var searchBarPlacehoder: String {
        switch self {
        case .all:
            return "Search in all vaults..."
        case let .precise(vault):
            return "Search in \(vault.name)..."
        case .trash:
            return "Search in trash..."
        }
    }
}

final class VaultsManager: ObservableObject, DeinitPrintable {
    deinit { print(deinitMessage) }

    private let itemRepository: ItemRepositoryProtocol
    private var manualLogIn: Bool
    private let logger: Logger
    private let shareRepository: ShareRepositoryProtocol
    private let symmetricKey: SymmetricKey

    /// Can be removed after going public
    private let preferences: Preferences

    @Published private(set) var state = VaultManagerState.loading
    @Published private(set) var vaultSelection = VaultSelection.all

    private var isRefreshing = false

    init(itemRepository: ItemRepositoryProtocol,
         manualLogIn: Bool,
         logManager: LogManager,
         shareRepository: ShareRepositoryProtocol,
         symmetricKey: SymmetricKey,
         preferences: Preferences) {
        self.itemRepository = itemRepository
        self.manualLogIn = manualLogIn
        logger = .init(manager: logManager)
        self.shareRepository = shareRepository
        self.symmetricKey = symmetricKey
        self.preferences = preferences
    }
}

// MARK: - Private APIs

private extension VaultsManager {
    @MainActor
    func createDefaultVault(isPrimary: Bool) async throws {
        let userId = shareRepository.userData.user.ID
        logger.trace("Creating default vault for user \(userId)")
        let vault = VaultProtobuf(name: "Personal",
                                  description: "Personal vault",
                                  color: .color1,
                                  icon: .icon1)
        let createdShare = try await shareRepository.createVault(vault)
        if isPrimary {
            logger.trace("Created default vault. Setting as primary \(createdShare.shareID)")
            _ = try await shareRepository.setPrimaryVault(shareId: createdShare.shareID)
            logger.info("Created default primary vault for user \(userId)")
        } else {
            logger.info("Created default vault for user \(userId)")
        }
    }

    @MainActor
    func loadContents(for vaults: [Vault]) async throws {
        let allItems = try await itemRepository.getAllItems()
        let allItemUiModels = try allItems.map { try $0.toItemUiModel(symmetricKey) }

        var vaultContentUiModels = vaults.map { vault in
            let items = allItemUiModels
                .filter { $0.shareId == vault.shareId }
                .filter { $0.state == .active }
            return VaultContentUiModel(vault: vault, items: items)
        }
        vaultContentUiModels.sortAlphabetically()

        let trashedItems = allItemUiModels.filter { $0.state == .trashed }

        // Reset to `all` when last selected vault is deleted
        if case let .precise(selectedVault) = vaultSelection {
            if !vaults.contains(where: { $0 == selectedVault }) {
                vaultSelection = .all
            }
        }

        state = .loaded(vaults: vaultContentUiModels, trashedItems: trashedItems)
    }
}

// MARK: - Public APIs

extension VaultsManager {
    func refresh() {
        guard !isRefreshing else { return }

        Task { @MainActor in
            defer { isRefreshing = false }
            isRefreshing = true

            do {
                // No need to show loading indicator once items are loaded beforehand.
                switch state {
                case .loaded:
                    break
                default:
                    state = .loading
                }

                if manualLogIn {
                    logger.info("Manual login, doing full sync")
                    try await fullSync()
                    manualLogIn = false
                    logger.info("Manual login, done full sync")
                    preferences.didReencryptAllItems = true
                } else {
                    if !preferences.didReencryptAllItems {
                        try await itemRepository.reencryptAllItemsTemp()
                        preferences.didReencryptAllItems = true
                    }
                    logger.info("Not manual login, getting local shares & items")
                    let vaults = try await shareRepository.getVaults()
                    try await loadContents(for: vaults)
                    logger.info("Not manual login, done getting local shares & items")
                }
            } catch {
                state = .error(error)
            }
        }
    }

    // Delete everything and download again
    func fullSync() async throws {
        // 1. Delete all local items & shares
        try await itemRepository.deleteAllItemsLocally()
        try await shareRepository.deleteAllSharesLocally()

        // 2. Get all remote shares and their items
        let remoteShares = try await shareRepository.getRemoteShares()
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for share in remoteShares {
                taskGroup.addTask { [unowned self] in
                    try await shareRepository.upsertShares([share])
                    try await itemRepository.refreshItems(shareId: share.shareID)
                }
            }
        }

        // 3. Create default vault if no vaults
        if remoteShares.isEmpty {
            try await createDefaultVault(isPrimary: false)
        }

        // 4. Load vaults and their contents
        var vaults = try await shareRepository.getVaults()

        // 5. Check if in "forgot password" scenario. Create a new primary vault if applicable
        let hasRemoteVaults = remoteShares.contains(where: { $0.shareType == .vault })
        // We see that there are remote vaults but we can't decrypt any of them
        // => "forgot password" happened
        if hasRemoteVaults, vaults.isEmpty {
            try await createDefaultVault(isPrimary: true)
            vaults = try await shareRepository.getVaults()
        }

        try await loadContents(for: vaults)
    }

    func select(_ selection: VaultSelection) {
        vaultSelection = selection
    }

    func isSelected(_ selection: VaultSelection) -> Bool {
        vaultSelection == selection
    }

    func getItem(for selection: VaultSelection) -> [ItemUiModel] {
        guard case let .loaded(vaults, trashedItems) = state else { return [] }
        switch vaultSelection {
        case .all:
            return vaults.map(\.items).reduce(into: []) { $0 += $1 }
        case let .precise(selectedVault):
            return vaults.first { $0.vault == selectedVault }?.items ?? []
        case .trash:
            return trashedItems
        }
    }

    func getItemCount(for selection: VaultSelection) -> Int {
        guard case let .loaded(vaults, trashedItems) = state else { return 0 }
        switch selection {
        case .all:
            return vaults.map(\.items.count).reduce(into: 0) { $0 += $1 }
        case let .precise(vault):
            return vaults.first { $0.vault == vault }?.items.count ?? 0
        case .trash:
            return trashedItems.count
        }
    }

    func getAllVaultContents() -> [VaultContentUiModel] {
        guard case let .loaded(vaults, _) = state else { return [] }
        return vaults
    }

    func getAllVaults() -> [Vault] {
        guard case let .loaded(vaults, _) = state else { return [] }
        return vaults.map(\.vault)
    }

    func vaultHasTrashedItems(_ vault: Vault) -> Bool {
        guard case let .loaded(_, trashedItems) = state else { return false }
        return trashedItems.contains { $0.shareId == vault.shareId }
    }

    func delete(vault: Vault) async throws {
        let shareId = vault.shareId
        logger.trace("Deleting vault \(shareId)")
        try await shareRepository.deleteVault(shareId: shareId)
        switch state {
        case let .loaded(vaults, trashedItems):
            logger.trace("Deleting local active items of vault \(shareId)")
            if let deletedVault = vaults.first(where: { $0.vault.shareId == shareId }) {
                let itemIds = deletedVault.items.map(\.itemId)
                try await itemRepository.deleteItemsLocally(itemIds: itemIds, shareId: shareId)
            }

            logger.trace("Deleting local trashed items of vault \(shareId)")
            let trashedItemsToBeRemoved = trashedItems.filter { $0.shareId == shareId }
            try await itemRepository.deleteItemsLocally(itemIds: trashedItemsToBeRemoved.map(\.itemId),
                                                        shareId: shareId)

        default:
            break
        }
        // Delete local items of the vault
        logger.info("Deleted vault \(shareId)")
    }

    func restoreAllTrashedItems() async throws {
        logger.trace("Restoring all trashed items")
        let trashedItems = try await itemRepository.getItems(state: .trashed)
        try await itemRepository.untrashItems(trashedItems)
        logger.info("Restored all trashed items")
    }

    func permanentlyDeleteAllTrashedItems() async throws {
        logger.trace("Permanently deleting all trashed items")
        let trashedItems = try await itemRepository.getItems(state: .trashed)
        try await itemRepository.deleteItems(trashedItems, skipTrash: false)
        logger.info("Permanently deleted all trashed items")
    }

    func getPrimaryVault() -> Vault? {
        guard case let .loaded(uiModels, _) = state else { return nil }
        let vaults = uiModels.map(\.vault)
        return vaults.first(where: { $0.isPrimary }) ?? vaults.first
    }

    func getSelectedShareId() -> String? {
        switch vaultSelection {
        case .all, .trash:
            return getPrimaryVault()?.shareId
        case let .precise(vault):
            return vault.shareId
        }
    }
}

// MARK: - LimitationCounterProtocol

extension VaultsManager: LimitationCounterProtocol {
    func getAliasCount() -> Int {
        switch state {
        case let .loaded(vaults, trash):
            let activeAliases = vaults.flatMap(\.items).filter(\.isAlias)
            let trashedAliases = trash.filter(\.isAlias)
            return activeAliases.count + trashedAliases.count
        default:
            return 0
        }
    }

    func getTOTPCount() -> Int {
        guard case let .loaded(vaults, trashedItems) = state else { return 0 }
        let activeItemsWithTotpUri = vaults.flatMap(\.items).filter(\.hasTotpUri).count
        let trashedItemsWithTotpUri = trashedItems.filter(\.hasTotpUri).count
        return activeItemsWithTotpUri + trashedItemsWithTotpUri
    }

    func getVaultCount() -> Int {
        switch state {
        case let .loaded(vaults, _):
            return vaults.count
        default:
            return 0
        }
    }
}

extension VaultManagerState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.loaded(lhsVaults, lhsTrashedItems), .loaded(rhsVaults, rhsTrashedItems)):
            return lhsVaults.hashValue == rhsVaults.hashValue &&
                lhsTrashedItems.hashValue == rhsTrashedItems.hashValue
        case let (.error(lhsError), .error(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

extension VaultSelection: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.trash, .trash):
            return true
        case let (.precise(lhsVault), .precise(rhsVault)):
            return lhsVault.id == rhsVault.id && lhsVault.shareId == rhsVault.shareId
        default:
            return false
        }
    }
}
