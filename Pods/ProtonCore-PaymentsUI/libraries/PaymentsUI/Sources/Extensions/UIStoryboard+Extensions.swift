//
//  UIStoryboard+Extensions.swift
//  ProtonCore_PaymentsUI - Created on 01/06/2021.
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
import UIKit
import ProtonCore_UIFoundations

extension UIStoryboard {
    static func instantiate<T: UIViewController>(
        storyboardName: String, controllerType: T.Type, inAppTheme: () -> InAppTheme
    ) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: PaymentsUI.bundle)
        let name = "\(controllerType)".replacingOccurrences(of: "ViewController", with: "")
        let viewController = storyboard.instantiateViewController(withIdentifier: name) as! T
        viewController.overrideUserInterfaceStyle = inAppTheme().userInterfaceStyle
        return viewController
    }
}
