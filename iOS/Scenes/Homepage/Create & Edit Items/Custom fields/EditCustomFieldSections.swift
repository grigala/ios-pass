//
// EditCustomFieldSections.swift
// Proton Pass - Created on 10/05/2023.
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

struct EditCustomFieldSections: View {
    @FocusState private var focusState: String?
    let focusedFieldId: String?
    let contentType: ItemContentType
    @Binding var uiModels: [CustomFieldUiModel]
    let canAddMore: Bool
    let onAddMore: () -> Void
    let onEditTitle: (CustomFieldUiModel) -> Void
    let onUpgrade: () -> Void

    var body: some View {
        ForEach($uiModels) { $uiModel in
            EditCustomFieldView(focusedField: $focusState,
                                field: uiModel.id,
                                contentType: contentType,
                                uiModel: $uiModel,
                                onEditTitle: { onEditTitle(uiModel) },
                                onRemove: { uiModels.removeAll(where: { $0.id == uiModel.id }) })
        }
        .onChange(of: focusedFieldId) { newValue in
            focusState = newValue
        }

        if canAddMore {
            addMoreButton
        } else {
            upgradeButton
        }
    }

    private var addMoreButton: some View {
        Button(action: onAddMore) {
            Label(title: {
                Text("Add more")
                    .font(.callout)
                    .fontWeight(.medium)
            }, icon: {
                Image(systemName: "plus")
            })
            .foregroundColor(Color(uiColor: contentType.normMajor2Color))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, kItemDetailSectionPadding)
    }

    private var upgradeButton: some View {
        Button(action: onUpgrade) {
            Label(title: {
                Text("Upgrade to add custom fields")
                    .font(.callout)
                    .fontWeight(.medium)
            }, icon: {
                Image(uiImage: IconProvider.arrowOutSquare)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 16)
            })
            .foregroundColor(Color(uiColor: contentType.normMajor2Color))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, kItemDetailSectionPadding)
    }
}
