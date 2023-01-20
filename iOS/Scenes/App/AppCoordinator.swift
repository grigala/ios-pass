//
// AppCoordinator.swift
// Proton Pass - Created on 02/07/2022.
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
import CoreData
import CryptoKit
import GoLibs
import ProtonCore_Authentication
import ProtonCore_Keymaker
import ProtonCore_Login
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Utilities
import SwiftUI
import UIComponents
import UIKit

enum AppCoordinatorError: Error {
    case noSessionData
    case failedToGetOrCreateSymmetricKey
}

final class AppCoordinator {
    private let window: UIWindow
    private let appStateObserver: AppStateObserver
    private let keymaker: Keymaker
    private let apiService: PMAPIService
    private let logManager: LogManager
    private var authHelper: AuthHelper
    private let logger: Logger
    private var container: NSPersistentContainer
    private let credentialManager: CredentialManagerProtocol
    private var preferences: Preferences

    @KeychainStorage(key: .sessionData)
    private var sessionData: SessionData?

    @KeychainStorage(key: .symmetricKey)
    private var symmetricKey: String?

    private var homeCoordinator: HomeCoordinator?
    private var welcomeCoordinator: WelcomeCoordinator?

    private var rootViewController: UIViewController? { window.rootViewController }

    private var appLockedViewController: UIViewController?

    private var cancellables = Set<AnyCancellable>()

    init(window: UIWindow) {
        self.window = window
        self.appStateObserver = .init()
        // The sessionUID will be used in the short future. It is empty by default.
        // we will have another migration to cache session and pass it to this initial
        self.apiService = PMAPIService.createAPIService(doh: PPDoH(bundle: .main), sessionUID: "")
        self.logManager = .init(module: .hostApp)
        self.logger = .init(subsystem: Bundle.main.bundleIdentifier ?? "",
                            category: "\(Self.self)",
                            manager: self.logManager)
        let keychain = PPKeychain()
        let keymaker = Keymaker(autolocker: Autolocker(lockTimeProvider: keychain), keychain: keychain)
        self._sessionData.setKeychain(keychain)
        self._sessionData.setMainKeyProvider(keymaker)
        self._sessionData.setLogManager(self.logManager)
        self._symmetricKey.setKeychain(keychain)
        self._symmetricKey.setMainKeyProvider(keymaker)
        self._symmetricKey.setLogManager(self.logManager)
        self.keymaker = keymaker
        self.container = .Builder.build(name: kProtonPassContainerName,
                                        inMemory: false)
        self.credentialManager = CredentialManager(logManager: logManager)
        self.preferences = .init()
        self.authHelper = AuthHelper()
        authHelper.setUpDelegate(self, callingItOn: .immediateExecutor)
        self.apiService.authDelegate = authHelper

        self.apiService.serviceDelegate = self
        bindAppState()
        // if ui test reset everything
        if ProcessInfo.processInfo.arguments.contains("RunningInUITests") {
            self.wipeAllData(isUITest: true)
        }
    }

    private func bindAppState() {
        appStateObserver.$appState
            .receive(on: DispatchQueue.main)
            .dropFirst() // Don't react to default undefined state
            .sink { [weak self] appState in
                guard let self else { return }
                switch appState {
                case .loggedOut(let reason):
                    self.wipeAllData()
                    self.showWelcomeScene(reason: reason)

                case let .loggedIn(sessionData, manualLogIn):
                    self.sessionData = sessionData
                    // AuthHelper need to expose the setter to update authCredential.
                    // Then we don't need to initial AuthHelper again. Temporary
                    self.apiService.setSessionUID(uid: sessionData.userData.credential.sessionID)
                    self.authHelper = AuthHelper(authCredential: sessionData.userData.credential)
                    self.authHelper.setUpDelegate(self, callingItOn: .immediateExecutor)
                    self.apiService.authDelegate = self.authHelper

                    self.showHomeScene(sessionData: sessionData, manualLogIn: manualLogIn)

                case .undefined:
                    self.logger.warning("Undefined app state. Don't know what to do...")
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                // Make sure preferences are up to date
                self.preferences = .init()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.dismissAppLockedViewController()
            }
            .store(in: &cancellables)
    }

    func start() {
        if let sessionData {
            appStateObserver.updateAppState(.loggedIn(data: sessionData, manualLogIn: false))
        } else {
            appStateObserver.updateAppState(.loggedOut(.noSessionData))
        }
    }

    func getOrCreateSymmetricKey() throws -> SymmetricKey {
        if symmetricKey == nil {
            symmetricKey = String.random(length: 32)
        }

        guard let symmetricKey,
              let symmetricKeyData = symmetricKey.data(using: .utf8) else {
            // Something really nasty is going on 💥
            throw AppCoordinatorError.failedToGetOrCreateSymmetricKey
        }

        return .init(data: symmetricKeyData)
    }

    private func showWelcomeScene(reason: LogOutReason) {
        let welcomeCoordinator = WelcomeCoordinator(apiServiceDelegate: self)
        welcomeCoordinator.delegate = self
        self.welcomeCoordinator = welcomeCoordinator
        self.homeCoordinator = nil
        animateUpdateRootViewController(welcomeCoordinator.rootViewController) { [unowned self] in
            switch reason {
            case .expiredRefreshToken:
                self.alertRefreshTokenExpired()
            case .failedBiometricAuthentication:
                self.alertFailedBiometricAuthentication()
            default:
                break
            }
        }
    }

    private func showHomeScene(sessionData: SessionData, manualLogIn: Bool) {
        do {
            let symmetricKey = try getOrCreateSymmetricKey()
            let homeCoordinator = HomeCoordinator(sessionData: sessionData,
                                                  apiService: apiService,
                                                  symmetricKey: symmetricKey,
                                                  container: container,
                                                  credentialManager: credentialManager,
                                                  manualLogIn: manualLogIn,
                                                  preferences: preferences,
                                                  logManager: logManager)
            homeCoordinator.delegate = self
            self.homeCoordinator = homeCoordinator
            self.welcomeCoordinator = nil
            animateUpdateRootViewController(homeCoordinator.rootViewController) {
                homeCoordinator.onboardIfNecessary(force: false)
            }
            if !manualLogIn {
                self.requestBiometricAuthenticationIfNecessary()
            }
        } catch {
            logger.error(error)
            wipeAllData()
            appStateObserver.updateAppState(.loggedOut(.failedToGenerateSymmetricKey))
        }
    }

    private func animateUpdateRootViewController(_ newRootViewController: UIViewController,
                                                 completion: (() -> Void)? = nil) {
        window.rootViewController = newRootViewController
        UIView.transition(with: window,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: nil) { _ in completion?() }
    }

    private func wipeAllData(isUITest: Bool = false) {
        logger.info("Wiping all data")
        keymaker.wipeMainKey()
        sessionData = nil
        preferences.reset(isUITests: isUITest)
        Task {
            // Do things independently in different `do catch` blocks
            // because we don't want a failed operation prevents others from running
            do {
                try await credentialManager.removeAllCredentials()
                logger.info("Removed all credentials")
            } catch {
                logger.error(error)
            }

            do {
                // Delete existing persistent stores
                let storeContainer = container.persistentStoreCoordinator
                for store in storeContainer.persistentStores {
                    if let url = store.url {
                        try storeContainer.destroyPersistentStore(at: url, ofType: store.type)
                    }
                }

                // Re-create persistent container
                container = .Builder.build(name: kProtonPassContainerName, inMemory: false)
                logger.info("Nuked local data")
            } catch {
                logger.error(error)
            }
        }
    }

    private func alertRefreshTokenExpired() {
        let alert = UIAlertController(title: "Your session is expired",
                                      message: "Please log in again",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        rootViewController?.present(alert, animated: true)
    }

    // Create a new instance of SessionData with everything copied except credential
    private func updateSessionData(_ sessionData: SessionData,
                                   authCredential: AuthCredential) {
        let currentUserData = sessionData.userData
        let updatedUserData = UserData(credential: authCredential,
                                       user: currentUserData.user,
                                       salts: currentUserData.salts,
                                       passphrases: currentUserData.passphrases,
                                       addresses: currentUserData.addresses,
                                       scopes: currentUserData.scopes)
        self.sessionData = .init(userData: updatedUserData)
    }
}

// MARK: - WelcomeCoordinatorDelegate
extension AppCoordinator: WelcomeCoordinatorDelegate {
    func welcomeCoordinator(didFinishWith loginData: LoginData) {
        switch loginData {
        case .credential:
            fatalError("Impossible case. Make sure minimumAccountType is set as internal in LoginAndSignUp")
        case .userData(let userData):
            guard userData.scopes.contains("pass") else {
                alertNoPassScope()
                return
            }
            let sessionData = SessionData(userData: userData)
            appStateObserver.updateAppState(.loggedIn(data: sessionData, manualLogIn: true))
        }
    }

    private func alertNoPassScope() {
        // swiftlint:disable line_length
        let alert = UIAlertController(title: "Error occured",
                                      message: "You are not eligible for using this application. Please contact our customer service.",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        rootViewController?.present(alert, animated: true)
        // swiftlint:enable line_length
    }
}

// MARK: - HomeCoordinatorDelegate
extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidSignOut() {
        appStateObserver.updateAppState(.loggedOut(.userInitiated))
    }

    func homeCoordinatorRequestsBiometricAuthentication() {
        requestBiometricAuthenticationIfNecessary()
    }
}

// MARK: - AuthHelperDelegate
extension AppCoordinator: AuthHelperDelegate {
    func credentialsWereUpdated(authCredential: AuthCredential, credential: Credential, for sessionUID: String) {
        guard let sessionData else {
            logger.info("Refreshed expired access token but found no sessionData in keychain. Logging out...")
            appStateObserver.updateAppState(.loggedOut(.noSessionData))
            return
        }
        self.logger.info("Refreshed expired access token")
        self.updateSessionData(sessionData, authCredential: authCredential)
    }

    func sessionWasInvalidated(for sessionUID: String) {
        logger.info("Access token expired but found no sessionData in keychain. Logging out...")
        appStateObserver.updateAppState(.loggedOut(.noSessionData))
    }
}

// MARK: - APIServiceDelegate
extension AppCoordinator: APIServiceDelegate {
    var appVersion: String { "ios-pass@\(Bundle.main.fullAppVersionName())" }
    var userAgent: String? { UserAgent.default.ua }
    var locale: String { Locale.autoupdatingCurrent.identifier }
    var additionalHeaders: [String: String]? { nil }

    func onDohTroubleshot() {}

    func onUpdate(serverTime: Int64) {
        CryptoUpdateTime(serverTime)
    }

    func isReachable() -> Bool {
        // swiftlint:disable:next todo
        // TODO: Handle this
        return true
    }
}

// MARK: - Biometric authentication
private extension AppCoordinator {
    func makeAppLockedViewController() -> UIViewController {
        let view = AppLockedView(
            preferences: preferences,
            logManager: logManager,
            delayed: false,
            onSuccess: { [unowned self] in
                self.dismissAppLockedViewController()
            },
            onFailure: { [unowned self] in
                self.appStateObserver.updateAppState(.loggedOut(.failedBiometricAuthentication))
            })
        let viewController = UIHostingController(rootView: view)
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }

    func dismissAppLockedViewController() {
        self.appLockedViewController?.dismiss(animated: true)
        self.appLockedViewController = nil
    }

    func requestBiometricAuthenticationIfNecessary() {
        guard preferences.biometricAuthenticationEnabled else { return }
        self.appLockedViewController = self.makeAppLockedViewController()
        guard let appLockedViewController = self.appLockedViewController else { return }
        self.rootViewController?.present(appLockedViewController, animated: false)
    }

    func alertFailedBiometricAuthentication() {
        let alert = UIAlertController(title: "Failed to authenticate",
                                      message: "You have to log in again in order to continue using Proton Pass",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        rootViewController?.present(alert, animated: true)
    }
}
