//
// CreateEditCreditCardView.swift
// Proton Pass - Created on 13/06/2023.
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
import SwiftUI
import UIComponents

struct CreateEditCreditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateEditCreditCardViewModel
    @FocusState private var focusedField: Field?
    @State private var selectedNumber = 0
    @State private var isShowingDiscardAlert = false

    private var tintColor: UIColor { viewModel.itemContentType().normMajor1Color }

    enum Field {
        case title, cardholderName, cardNumber, verificationNumber, pin, note
    }

    init(viewModel: CreateEditCreditCardViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
        .obsoleteItemAlert(isPresented: $viewModel.isObsolete, onAction: dismiss.callAsFunction)
        .discardChangesAlert(isPresented: $isShowingDiscardAlert, onDiscard: dismiss.callAsFunction)
    }
}

private extension CreateEditCreditCardView {
    var content: some View {
        ScrollViewReader { _ in
            ScrollView {
                VStack {
                    if viewModel.shouldUpgrade {
                        upsellBanner
                    }

                    CreateEditItemTitleSection(title: $viewModel.title,
                                               focusedField: $focusedField,
                                               field: .title,
                                               selectedVault: viewModel.selectedVault,
                                               itemContentType: viewModel.itemContentType(),
                                               isEditMode: viewModel.mode.isEditMode,
                                               onChangeVault: viewModel.changeVault,
                                               onSubmit: { focusedField = .cardholderName })

                    cardDetailSection

                    NoteEditSection(note: $viewModel.note,
                                    focusedField: $focusedField,
                                    field: .note)
                }
                .padding()
            }
        }
        .background(PassColor.backgroundNorm.toColor)
        .accentColor(tintColor.toColor) // Remove when dropping iOS 15
        .tint(tintColor.toColor)
        .onFirstAppear {
            if case .create = viewModel.mode {
                if #available(iOS 16, *) {
                    focusedField = .title
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        focusedField = .title
                    }
                }
            }
        }
        .toolbar {
            CreateEditItemToolbar(saveButtonTitle: viewModel.saveButtonTitle(),
                                  isSaveable: viewModel.isSaveable,
                                  isSaving: viewModel.isSaving,
                                  itemContentType: viewModel.itemContentType(),
                                  shouldUpgrade: viewModel.shouldUpgrade,
                                  onGoBack: {
                                      if viewModel.didEditSomething {
                                          isShowingDiscardAlert.toggle()
                                      } else {
                                          dismiss()
                                      }
                                  },
                                  onUpgrade: viewModel.upgrade,
                                  onSave: viewModel.save)
        }
    }

    var upsellBanner: some View {
        Text("Upgrade to create credit cards")
            .padding()
            .foregroundColor(Color(uiColor: PassColor.textNorm))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PassColor.cardInteractionNormMinor1.toColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private extension CreateEditCreditCardView {
    var cardDetailSection: some View {
        VStack(spacing: kItemDetailSectionPadding) {
            cardholderNameRow
            PassSectionDivider()
            cardNumberRow
            PassSectionDivider()
            verificationNumberRow
            PassSectionDivider()
            pinRow
            PassSectionDivider()
            expirationDateRow
        }
        .padding(.vertical, kItemDetailSectionPadding)
        .roundedEditableSection()
    }

    var cardholderNameRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.user)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Cardholder name")
                    .sectionTitleText()
                TextField("Full name", text: $viewModel.cardholderName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .cardholderName)
                    .foregroundColor(PassColor.textNorm.toColor)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .cardNumber }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.cardholderName.isEmpty {
                Button(action: {
                    viewModel.cardholderName = ""
                }, label: {
                    ItemDetailSectionIcon(icon: IconProvider.cross)
                })
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .animation(.default, value: viewModel.cardholderName.isEmpty)
    }

    var cardNumberRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.creditCard)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Card number")
                    .sectionTitleText()
                WrappedUITextField(text: $viewModel.cardNumber,
                                   placeHolder: "1234 1234 1234 1234") { isEditing in
                    guard !isEditing else {
                        return
                    }
                    focusedField = .verificationNumber
                }.focused($focusedField, equals: .cardNumber)
                    .foregroundColor(PassColor.textNorm.toColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.cardNumber.isEmpty {
                Button(action: {
                    viewModel.cardNumber = ""
                }, label: {
                    ItemDetailSectionIcon(icon: IconProvider.cross)
                })
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .animation(.default, value: viewModel.cardNumber.isEmpty)
    }

    var verificationNumberRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: PassIcon.shieldCheck)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Verification number")
                    .sectionTitleText()

                SensitiveTextField(text: $viewModel.verificationNumber,
                                   placeholder: "123",
                                   focusedField: $focusedField,
                                   field: .verificationNumber)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .foregroundColor(PassColor.textNorm.toColor)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .pin }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.verificationNumber.isEmpty {
                Button(action: {
                    viewModel.verificationNumber = ""
                }, label: {
                    ItemDetailSectionIcon(icon: IconProvider.cross)
                })
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .animation(.default, value: viewModel.verificationNumber.isEmpty)
    }

    var pinRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.grid3)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("PIN")
                    .sectionTitleText()

                SensitiveTextField(text: $viewModel.pin,
                                   placeholder: "123456",
                                   focusedField: $focusedField,
                                   field: .pin)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .foregroundColor(PassColor.textNorm.toColor)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .note }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.pin.isEmpty {
                Button(action: {
                    viewModel.pin = ""
                }, label: {
                    ItemDetailSectionIcon(icon: IconProvider.cross)
                })
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .animation(.default, value: viewModel.verificationNumber.isEmpty)
    }

    var expirationDateRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.calendarDay)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Expires on")
                    .sectionTitleText()
                MonthYearTextField(placeholder: "MM / YYYY",
                                   tintColor: tintColor,
                                   month: $viewModel.month,
                                   year: $viewModel.year)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, kItemDetailSectionPadding)
    }
}
