//
// LocalAuthenticationViewModel.swift
// Proton Pass - Created on 22/06/2023.
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

import Combine
import Core

private let kMaxAttemptCount = 3

enum LocalAuthenticationState {
    case initializing
    case initialized(LocalAuthenticationInitializedState)
    case error(Error)
}

enum LocalAuthenticationInitializedState {
    case noAttempts
    case remainingAttempts(Int)
    case lastAttempt
}

final class LocalAuthenticationViewModel: ObservableObject, DeinitPrintable {
    deinit { print(deinitMessage) }

    let type: LocalAuthenticationType
    let preferences: Preferences

    private let delayed: Bool
    private let biometricAuthenticator: BiometricAuthenticator
    private let logger: Logger
    private let onAuth: () -> Void
    private let onSuccess: () -> Void
    private let onFailure: () -> Void
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var state: LocalAuthenticationState = .initializing

    var delayedTime: DispatchTimeInterval {
        delayed ? .milliseconds(200) : .milliseconds(0)
    }

    init(type: LocalAuthenticationType,
         delayed: Bool,
         preferences: Preferences,
         logManager: LogManager,
         onAuth: @escaping () -> Void,
         onSuccess: @escaping () -> Void,
         onFailure: @escaping () -> Void) {
        self.type = type
        self.delayed = delayed
        self.preferences = preferences
        biometricAuthenticator = .init(preferences: preferences, logManager: logManager)
        logger = .init(manager: logManager)
        self.onAuth = onAuth
        self.onSuccess = onSuccess
        self.onFailure = onFailure

        preferences.attach(to: self, storeIn: &cancellables)

        preferences.objectWillChange
            .sink { [weak self] _ in
                self?.updateStateBasedOnFailedAttemptCount()
            }
            .store(in: &cancellables)

        biometricAuthenticator.$biometryTypeState
            .sink { [weak self] biometryTypeState in
                guard let self else { return }
                switch biometryTypeState {
                case .idle, .initializing:
                    self.state = .initializing
                case .initialized:
                    self.updateStateBasedOnFailedAttemptCount()
                case let .error(error):
                    self.state = .error(error)
                }
            }
            .store(in: &cancellables)

        // When supporting pin authentication, check for authentication type
        biometricAuthenticator.initializeBiometryType()
    }

    func biometricallyAuthenticate() {
        switch biometricAuthenticator.biometryTypeState {
        case .initialized:
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    self.onAuth()
                    if try await biometricAuthenticator.authenticate(reason: "Please authenticate") {
                        self.recordSuccess()
                    } else {
                        self.recordFailure(nil)
                    }
                } catch {
                    self.recordFailure(error)
                }
            }
        default:
            assertionFailure("biometricAuthenticator not initialized")
            onFailure()
        }
    }
}

private extension LocalAuthenticationViewModel {
    func updateStateBasedOnFailedAttemptCount() {
        switch preferences.failedAttemptCount {
        case 0:
            state = .initialized(.noAttempts)
        case kMaxAttemptCount - 1:
            state = .initialized(.lastAttempt)
        default:
            let remainingAttempts = kMaxAttemptCount - preferences.failedAttemptCount
            if remainingAttempts >= 1 {
                state = .initialized(.remainingAttempts(remainingAttempts))
            } else {
                onFailure()
            }
        }
    }

    func recordFailure(_ error: Error?) {
        preferences.failedAttemptCount += 1

        let logMessage = "Biometric authentication failed. Increased failed attempt count."
        if let error {
            logger.error(logMessage + " Reason \(error)")
        } else {
            logger.error(logMessage)
        }
    }

    func recordSuccess() {
        preferences.failedAttemptCount = 0
        onSuccess()
    }
}
