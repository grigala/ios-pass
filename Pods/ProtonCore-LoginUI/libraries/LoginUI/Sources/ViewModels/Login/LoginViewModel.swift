//
//  LoginViewModel.swift
//  ProtonCore-Login - Created on 04/11/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCore_Challenge
import ProtonCore_CoreTranslation
import ProtonCore_Login
import ProtonCore_DataModel

final class LoginViewModel {
    enum LoginResult {
        case done(LoginData)
        case twoFactorCodeNeeded
        case mailboxPasswordNeeded
        case createAddressNeeded(CreateAddressData, String?)
    }

    // MARK: - Properties

    let finished = Publisher<LoginResult>()
    let error = Publisher<LoginError>()
    let isLoading = Observable<Bool>(false)

    var isSSOEnabled = false
    let subtitleLabel = CoreString._ls_screen_subtitle
    var loginTextFieldTitle: String {
        isSSOEnabled ? CoreString._su_email_field_title : CoreString._ls_username_title
    }
    var titleLabel: String {
        isSSOEnabled ? CoreString._ls_sign_in_with_sso_title : CoreString._ls_screen_title
    }
    let signInWithSSOButtonTitle = CoreString._ls_sign_in_with_sso_button
    let passwordTextFieldTitle = CoreString._ls_password_title
    let signInButtonTitle = CoreString._ls_sign_in_button
    var signUpButtonTitle: String {
        isSSOEnabled ? CoreString._ls_sign_in_button_with_password : CoreString._ls_create_account_button
    }
    
    private let login: Login
    let challenge: PMChallenge
    let clientApp: ClientApp

    init(login: Login, challenge: PMChallenge, clientApp: ClientApp) {
        self.login = login
        self.challenge = challenge
        self.clientApp = clientApp
    }

    // MARK: - Actions

    func login(username: String, password: String) {
        self.challenge.appendCheckedUsername(username)
        isLoading.value = true

        let userFrame = ["name": "username"]
        let challengeData = self.challenge.export()
            .allFingerprintDict()
            .first(where: { $0["frame"] as? [String: String] == userFrame })

        login.login(username: username, password: password, challenge: challengeData) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.error.publish(error)
                self?.isLoading.value = false
            case let .success(status):
                switch status {
                case let .finished(data):
                    self?.finished.publish(.done(data))
                case .ask2FA:
                    self?.finished.publish(.twoFactorCodeNeeded)
                    self?.isLoading.value = false
                case .askSecondPassword:
                    self?.finished.publish(.mailboxPasswordNeeded)
                    self?.isLoading.value = false
                case let .chooseInternalUsernameAndCreateInternalAddress(data):
                    self?.login.checkUsernameFromEmail(email: data.email) { [weak self] result in
                        switch result {
                        case .failure(let error):
                            self?.error.publish(.generic(message: error.messageForTheUser, code: error.bestShotAtReasonableErrorCode, originalError: error))
                        case .success(let defaultUsername):
                            self?.finished.publish(.createAddressNeeded(data, defaultUsername))
                        }
                        self?.isLoading.value = false
                    }
                }
            }
        }
    }

    // MARK: - Validation

    func validate(username: String) -> Result<(), LoginValidationError> {
        return !username.isEmpty ? .success : .failure(.emptyUsername)
    }

    func validate(password: String) -> Result<(), LoginValidationError> {
        return !password.isEmpty ? .success : .failure(.emptyPassword)
    }

    func updateAvailableDomain(result: (([String]?) -> Void)? = nil) {
        login.updateAllAvailableDomains(type: .login) { res in result?(res) }
    }
}
