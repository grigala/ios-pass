//
// Constants.swift
// Proton Pass - Created on 03/07/2022.
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

import Foundation

public enum Constants {
    public static let teamId = "2SB5Z68H26"
    public static let appGroup = "group.me.proton.pass"
    public static let keychainGroup = "\(teamId).\(appGroup)"
    public static let sortTypeKey = "sortType"
    public static let appStoreUrl = "itms-apps://itunes.apple.com/app/id6443490629"

    enum TotpBase {
        public static let timer: Double = 30.0
        public static let digit: Int = 6
        public static let algo: OTPComponents.Algorithm = .sha1
    }
}

/// Links to KB articles or useful pages
public enum ProtonLink {
    public static let trialPeriod = "https://proton.me/support/pass-trial"
    public static let howToImport = "https://proton.me/support/pass-import"
    public static let privacyPolicy = "https://proton.me/legal/privacy"
    public static let termsOfService = "https://proton.me/legal/terms"
}

/// The following enum contains all the keys liked to the data contained in the custom plists `Pass-Constant-Black`
/// and `Pass-Constant-Prod`
public enum ConstantPlistKey {
    public enum PlistFiles: String {
        case black = "Pass-Constant-Black"
        case prod = "Pass-Constant-Prod"
    }

    public enum Keys: String {
        case signupDomain = "SIGNUP_DOMAIN"
        case captchaHost = "CAPTCHA_HOST"
        case humanVerificationHost = "HUMAN_VERIFICATION_HOST"
        case accountHost = "ACCOUNT_HOST"
        case defaultHost = "DEFAULT_HOST"
        case apiHost = "API_HOST"
        case defaultPath = "DEFAULT_PATH"
        case sentryDSN = "SENTRY_DSN"
    }
}
