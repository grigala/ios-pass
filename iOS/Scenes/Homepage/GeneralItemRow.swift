//
// GeneralItemRow.swift
// Proton Pass - Created on 06/03/2023.
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

struct GeneralItemRow<ThumbnailView: View, TrailingView: View>: View {
    let thumbnailView: ThumbnailView
    let title: String
    let description: String?
    let trailingView: TrailingView
    let action: () -> Void

    init(@ViewBuilder thumbnailView: () -> ThumbnailView,
         title: String,
         description: String?,
         @ViewBuilder trailingView: () -> TrailingView = { EmptyView() },
         action: @escaping () -> Void) {
        self.thumbnailView = thumbnailView()
        self.title = title
        self.description = description
        self.trailingView = trailingView()
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: action) {
                HStack(spacing: kItemDetailSectionPadding) {
                    thumbnailView
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                        if let description {
                            Text(description)
                                .font(.callout)
                                .foregroundColor(.textWeak)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            trailingView
        }
        .frame(height: 40)
    }
}
