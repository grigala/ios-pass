//
//  MainRobot.swift
//  iOSUITests - Created on 12/23/22.
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

// swiftlint:disable prefixed_toplevel_constant
import fusion
import ProtonCore_TestingToolkit
import XCTest

private let telemetryLabelText = "Telemetry"
private let settingsLabelText = "Settings"

final class SettingsRobot: CoreElements {
    let verify = Verify()

    final class Verify: CoreElements {
        @discardableResult
        public func telemetryItemIsDisplayed() -> SettingsRobot {
            staticText(telemetryLabelText).wait().checkExists()
            return SettingsRobot()
        }
    }

    func tapSettingsButton() -> SettingsRobot {
        button(settingsLabelText).wait().tap()
        return self
    }
}
