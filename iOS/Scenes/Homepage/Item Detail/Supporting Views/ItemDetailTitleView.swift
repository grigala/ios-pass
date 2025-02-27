//
// ItemDetailTitleView.swift
// Proton Pass - Created on 02/02/2023.
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

import Client
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct ItemDetailTitleView: View {
    let itemContent: ItemContent
    let vault: Vault?
    let favIconRepository: FavIconRepositoryProtocol

    var body: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemSquircleThumbnail(data: itemContent.thumbnailData(),
                                  repository: favIconRepository,
                                  size: .large)

            VStack(alignment: .leading, spacing: 4) {
                Text(itemContent.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .foregroundColor(Color(uiColor: PassColor.textNorm))

                if let vault {
                    VaultLabel(vault: vault)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
    }
}
