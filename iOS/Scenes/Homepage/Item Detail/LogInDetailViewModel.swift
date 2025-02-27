//
// LogInDetailViewModel.swift
// Proton Pass - Created on 07/09/2022.
// Copyright (c) 2022 Proton Technologies AG
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
import Combine
import Core
import SwiftUI
import UIComponents
import UIKit

protocol LogInDetailViewModelDelegate: AnyObject {
    func logInDetailViewModelWantsToShowAliasDetail(_ itemContent: ItemContent)
}

enum TOTPTokenState {
    case loading
    case allowed
    case notAllowed
}

final class LogInDetailViewModel: BaseItemDetailViewModel, DeinitPrintable, ObservableObject {
    deinit { print(deinitMessage) }

    @Published private(set) var name = ""
    @Published private(set) var username = ""
    @Published private(set) var urls: [String] = []
    @Published private(set) var password = ""
    @Published private(set) var note = ""
    @Published private(set) var totpTokenState = TOTPTokenState.loading
    @Published private(set) var totpManager: TOTPManager
    @Published private var aliasItem: SymmetricallyEncryptedItem?

    var isAlias: Bool { aliasItem != nil }

    private var cancellables = Set<AnyCancellable>()
    weak var logInDetailViewModelDelegate: LogInDetailViewModelDelegate?

    var coloredPasswordTexts: [Text] { PasswordUtils.generateColoredPasswords(password) }

    override init(isShownAsSheet: Bool,
                  itemContent: ItemContent,
                  favIconRepository: FavIconRepositoryProtocol,
                  itemRepository: ItemRepositoryProtocol,
                  upgradeChecker: UpgradeCheckerProtocol,
                  vault: Vault?,
                  logManager: LogManager,
                  theme: Theme) {
        totpManager = .init(logManager: logManager)
        super.init(isShownAsSheet: isShownAsSheet,
                   itemContent: itemContent,
                   favIconRepository: favIconRepository,
                   itemRepository: itemRepository,
                   upgradeChecker: upgradeChecker,
                   vault: vault,
                   logManager: logManager,
                   theme: theme)
        totpManager.attach(to: self, storeIn: &cancellables)
    }

    override func bindValues() {
        if case let .login(data) = itemContent.contentData {
            name = itemContent.name
            note = itemContent.note
            username = data.username
            password = data.password
            urls = data.urls
            totpManager.bind(uri: data.totpUri)
            getAliasItem(username: data.username)

            if !data.totpUri.isEmpty {
                checkTotpState(createTime: itemContent.item.createTime)
            } else {
                totpTokenState = .allowed
            }
        } else {
            fatalError("Expecting login type")
        }
    }
}

// MARK: - Private APIs

private extension LogInDetailViewModel {
    func getAliasItem(username: String) {
        Task { @MainActor in
            do {
                self.aliasItem = try await itemRepository.getAliasItem(email: username)
            } catch {
                logger.error(error)
                delegate?.itemDetailViewModelDidEncounter(error: error)
            }
        }
    }

    func checkTotpState(createTime: Int64) {
        Task { @MainActor in
            do {
                if try await upgradeChecker.canShowTOTPToken(creationDate: itemContent.item.createTime) {
                    self.totpTokenState = .allowed
                } else {
                    self.totpTokenState = .notAllowed
                }
            } catch {
                logger.error(error)
                delegate?.itemDetailViewModelDidEncounter(error: error)
            }
        }
    }
}

// MARK: - Public actions

extension LogInDetailViewModel {
    func copyUsername() {
        copyToClipboard(text: username, message: "Username copied")
    }

    func copyPassword() {
        guard !password.isEmpty else { return }
        copyToClipboard(text: password, message: "Password copied")
    }

    func copyTotpCode() {
        if let code = totpManager.totpData?.code {
            copyToClipboard(text: code, message: "Two Factor Authentication code copied")
        }
    }

    func showLargePassword() {
        showLarge(password)
    }

    func showAliasDetail() {
        guard let aliasItem else { return }
        do {
            let symmetricKey = itemRepository.symmetricKey
            let itemContent = try aliasItem.getItemContent(symmetricKey: symmetricKey)
            logInDetailViewModelDelegate?.logInDetailViewModelWantsToShowAliasDetail(itemContent)
        } catch {
            delegate?.itemDetailViewModelDidEncounter(error: error)
        }
    }

    func openUrl(_ urlString: String) {
        delegate?.itemDetailViewModelWantsToOpen(urlString: urlString)
    }
}
