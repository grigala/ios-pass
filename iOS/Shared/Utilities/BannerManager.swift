//
// BannerManager.swift
// Proton Pass - Created on 13/03/2023.
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

import ProtonCore_UIFoundations

final class BannerManager {
    weak var container: UIViewController!

    init(container: UIViewController) {
        self.container = container
    }

    func display(message: String, at position: PMBannerPosition, style: PMBannerNewStyle) {
        let banner = PMBanner(message: message, style: style)
        banner.show(at: position, on: container.topMostViewController)
    }

    func displayBottomSuccessMessage(_ message: String) {
        display(message: message, at: .bottom, style: .success)
    }

    func displayBottomInfoMessage(_ message: String,
                                  dismissButtonTitle: String,
                                  onDismiss: @escaping ((PMBanner) -> Void)) {
        let banner = PMBanner(message: message, style: PMBannerNewStyle.info)
        banner.addButton(text: dismissButtonTitle, handler: onDismiss)
        banner.show(at: .bottom, on: container.topMostViewController)
    }

    func displayBottomInfoMessage(_ message: String) {
        display(message: message, at: .bottom, style: .info)
    }

    func displayTopErrorMessage(_ message: String,
                                dismissButtonTitle: String = "OK",
                                onDismiss: ((PMBanner) -> Void)? = nil) {
        let dismissClosure = onDismiss ?? { banner in banner.dismiss() }
        let banner = PMBanner(message: message, style: PMBannerNewStyle.error)
        banner.addButton(text: dismissButtonTitle, handler: dismissClosure)
        banner.show(at: .top, on: container.topMostViewController)
    }

    func displayTopErrorMessage(_ error: Error) {
        displayTopErrorMessage(error.localizedDescription)
    }
}
