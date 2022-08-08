//
// GenericItemView.swift
// Proton Pass - Created on 07/07/2022.
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

import ProtonCore_UIFoundations
import SwiftUI

public protocol GenericItemProvider {
    var icon: UIImage { get }
    var title: String { get }
    var detail: String { get }
}

public struct GenericItemView: View {
    private let item: GenericItemProvider
    private let action: () -> Void
    private let showDivider: Bool

    public init(item: GenericItemProvider,
                showDivider: Bool = true,
                action: @escaping () -> Void) {
        self.item = item
        self.showDivider = showDivider
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    VStack {
                        Image(uiImage: item.icon)
                            .foregroundColor(Color(.label))
                            .padding(.top, -20)
                        EmptyView()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                        if let detail = item.detail {
                            Text(detail)
                                .font(.callout)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()

                if showDivider {
                    Divider()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct GenericItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = PreviewGenericItem(icon: IconProvider.note,
                                      title: "Note",
                                      detail: "Keep important information secure")
        GenericItemView(item: item) {}
    }
}

struct PreviewGenericItem: GenericItemProvider {
    let icon: UIImage
    let title: String
    var detail: String
}
