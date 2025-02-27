//
// SceneDelegate.swift
// Proton Pass - Created on 01/07/2022.
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

import Core
import SwiftUI
import UIComponents

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appCoverView: UIView?
    private lazy var appCoordinator = AppCoordinator(window: window ?? .init())

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            window.makeKeyAndVisible()
        }
        AppearanceSettings.apply()
        appCoordinator.start()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        let appCoverView = makeAppCoverView(windowSize: window?.frame.size ?? .zero)
        appCoverView.frame = window?.frame ?? .zero
        appCoverView.alpha = 0
        window?.addSubview(appCoverView)
        UIView.animate(withDuration: 0.35) {
            appCoverView.alpha = 1
        }
        self.appCoverView = appCoverView
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIView.animate(withDuration: 0.35,
                       animations: {
                           self.appCoverView?.alpha = 0
                       },
                       completion: { [unowned self] _ in
                           appCoverView?.removeFromSuperview()
                           appCoverView = nil
                       })
    }
}

private extension SceneDelegate {
    struct AppCoverView: View {
        let windowSize: CGSize

        var body: some View {
            ZStack {
                Image(uiImage: PassIcon.coverScreenBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Image(uiImage: PassIcon.coverScreenLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(windowSize.width, windowSize.height) * 2 / 3)
                    .frame(maxWidth: 245)
            }
            .theme(Preferences().theme)
        }
    }

    func makeAppCoverView(windowSize: CGSize) -> UIView {
        UIHostingController(rootView: AppCoverView(windowSize: windowSize)).view
    }
}
