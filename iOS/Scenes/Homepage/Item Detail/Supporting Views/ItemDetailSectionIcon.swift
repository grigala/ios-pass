//
// ItemDetailSectionIcon.swift
// Proton Pass - Created on 03/02/2023.
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

import SwiftUI
import UIComponents

struct ItemDetailSectionIcon: View {
    let icon: UIImage
    var color: UIColor = PassColor.textWeak
    var width: CGFloat = 20

    var body: some View {
        Image(uiImage: icon)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundColor(Color(uiColor: color))
            .frame(width: width)
    }
}
