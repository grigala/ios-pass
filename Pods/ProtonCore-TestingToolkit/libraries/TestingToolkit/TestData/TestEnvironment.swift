//
//  TestEnvironment.swift
//  ProtonCore-TestingToolkig - Created on 13.09.22.
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
import ProtonCore_Doh

public class TestDoH: DoH, ServerConfig {
    public var defaultHost: String = "https://test.xyz"
    public var captchaHost: String = "https://test.xyz"
    public var humanVerificationV3Host: String = "https://verify.test.xyz"
    public var accountHost: String = "https://account.test.xyz"
    public var apiHost: String = "abcabcabcabcabcabcabcabcabcabcabcabc.xyz"
    public var defaultPath: String = "/api"
    public var signupDomain: String = "test.xyz"
    public static let `default` = TestDoH()
}
