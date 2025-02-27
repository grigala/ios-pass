//
// View+Theme.swift
// Proton Pass - Created on 07/03/2023.
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

import Core
import SwiftUI

private struct ThemeModifier: ViewModifier {
    let theme: Theme

    func body(content: Content) -> some View {
        if let colorScheme = theme.colorScheme {
            content.environment(\.colorScheme, colorScheme)
        } else {
            content
        }
    }
}

extension View {
    func theme(_ theme: Theme) -> some View {
        modifier(ThemeModifier(theme: theme))
            .animation(.default, value: theme)
    }
}

extension Theme {
    var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .matchSystem:
            return nil
        }
    }
}
