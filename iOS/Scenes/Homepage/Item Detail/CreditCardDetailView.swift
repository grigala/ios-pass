//
// CreditCardDetailView.swift
// Proton Pass - Created on 15/06/2023.
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
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct CreditCardDetailView: View {
    @StateObject private var viewModel: CreditCardDetailViewModel
    @State private var isShowingCardNumber = false
    @State private var isShowingVerificationNumber = false
    @State private var isShowingPIN = false
    @State private var isMoreInfoSectionExpanded = false
    @Namespace private var bottomID

    private var tintColor: UIColor { viewModel.itemContent.type.normColor }

    init(viewModel: CreditCardDetailViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        if viewModel.isShownAsSheet {
            NavigationView {
                realBody
            }
            .navigationViewStyle(.stack)
        } else {
            realBody
        }
    }
}

private extension CreditCardDetailView {
    var realBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ItemDetailTitleView(itemContent: viewModel.itemContent,
                                        vault: viewModel.vault,
                                        favIconRepository: viewModel.favIconRepository)
                        .padding(.bottom, 40)

                    detailSection

                    if !viewModel.itemContent.note.isEmpty {
                        NoteDetailSection(itemContent: viewModel.itemContent,
                                          vault: viewModel.vault,
                                          theme: viewModel.theme,
                                          favIconRepository: viewModel.favIconRepository)
                            .padding(.top, 8)
                    }

                    ItemDetailMoreInfoSection(isExpanded: $isMoreInfoSectionExpanded,
                                              itemContent: viewModel.itemContent)
                        .padding(.top, 24)
                        .id(bottomID)
                }
                .padding()
                .onChange(of: isMoreInfoSectionExpanded) { _ in
                    withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
                }
            }
        }
        .animation(.default, value: isMoreInfoSectionExpanded)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .background(PassColor.backgroundNorm.toColor)
        .toolbar {
            ItemDetailToolbar(isShownAsSheet: viewModel.isShownAsSheet,
                              itemContent: viewModel.itemContent,
                              onGoBack: viewModel.goBack,
                              onEdit: viewModel.edit,
                              onMoveToAnotherVault: viewModel.moveToAnotherVault,
                              onMoveToTrash: viewModel.moveToTrash,
                              onRestore: viewModel.restore,
                              onPermanentlyDelete: viewModel.permanentlyDelete)
        }
    }
}

private extension CreditCardDetailView {
    var detailSection: some View {
        VStack(spacing: kItemDetailSectionPadding) {
            cardholderNameRow
            PassSectionDivider()
            cardNumberRow
            PassSectionDivider()
            verificationNumberRow
            if !viewModel.pin.isEmpty {
                PassSectionDivider()
                pinRow
            }
            PassSectionDivider()
            expirationDateRow
        }
        .padding(.vertical, kItemDetailSectionPadding)
        .roundedDetailSection()
    }

    var cardholderNameRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.user, color: tintColor)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Cardholder name")
                    .sectionTitleText()

                UpsellableDetailText(text: viewModel.cardholderName,
                                     placeholder: "Empty cardholder name",
                                     shouldUpgrade: false,
                                     upgradeTextColor: tintColor,
                                     onUpgrade: viewModel.upgrade)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.copyCardholderName)
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .contextMenu {
            if !viewModel.isFreeUser, !viewModel.cardholderName.isEmpty {
                Button(action: viewModel.copyCardholderName) {
                    Text("Copy")
                }

                Button(action: {
                    viewModel.showLarge(viewModel.cardholderName)
                }, label: {
                    Text("Show large")
                })
            }
        }
    }

    @ViewBuilder
    var cardNumberRow: some View {
        let shouldShowOptions = !viewModel.isFreeUser && !viewModel.cardNumber.isEmpty
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.creditCard, color: tintColor)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Card number")
                    .sectionTitleText()

                UpsellableDetailText(text: isShowingCardNumber ?
                    viewModel.cardNumber.toCreditCardNumber() : viewModel.cardNumber
                    .toMaskedCreditCardNumber(),
                    placeholder: "Empty credit card number",
                    shouldUpgrade: viewModel.isFreeUser,
                    upgradeTextColor: tintColor,
                    onUpgrade: viewModel.upgrade)
                    .animation(.default, value: isShowingCardNumber)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.copyCardNumber)

            Spacer()

            if shouldShowOptions {
                CircleButton(icon: isShowingCardNumber ? IconProvider.eyeSlash : IconProvider.eye,
                             iconColor: viewModel.itemContent.type.normMajor2Color,
                             backgroundColor: viewModel.itemContent.type.normMinor2Color,
                             action: { isShowingCardNumber.toggle() })
                    .fixedSize(horizontal: true, vertical: true)
                    .animationsDisabled()
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .contextMenu {
            if shouldShowOptions {
                Button(action: {
                    withAnimation {
                        isShowingCardNumber.toggle()
                    }
                }, label: {
                    Text(isShowingCardNumber ? "Conceal" : "Reveal")
                })

                Button(action: viewModel.copyCardNumber) {
                    Text("Copy")
                }
            }
        }
    }

    @ViewBuilder
    var verificationNumberRow: some View {
        let shouldShowOptions = !viewModel.isFreeUser && !viewModel.verificationNumber.isEmpty
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: PassIcon.shieldCheck, color: tintColor)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Verification number")
                    .sectionTitleText()

                UpsellableDetailText(text: isShowingVerificationNumber ?
                    viewModel.verificationNumber :
                    String(repeating: "•", count: viewModel.verificationNumber.count),
                    placeholder: "Empty verification number",
                    shouldUpgrade: false,
                    upgradeTextColor: tintColor,
                    onUpgrade: viewModel.upgrade)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.copyVerificationNumber)
            .animation(.default, value: isShowingVerificationNumber)

            Spacer()

            if shouldShowOptions {
                CircleButton(icon: isShowingVerificationNumber ? IconProvider.eyeSlash : IconProvider.eye,
                             iconColor: viewModel.itemContent.type.normMajor2Color,
                             backgroundColor: viewModel.itemContent.type.normMinor2Color,
                             action: { isShowingVerificationNumber.toggle() })
                    .fixedSize(horizontal: true, vertical: true)
                    .animationsDisabled()
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .contextMenu {
            if shouldShowOptions {
                Button(action: {
                    withAnimation {
                        isShowingVerificationNumber.toggle()
                    }
                }, label: {
                    Text(isShowingVerificationNumber ? "Conceal" : "Reveal")
                })

                Button(action: viewModel.copyVerificationNumber) {
                    Text("Copy")
                }
            }
        }
    }

    @ViewBuilder
    var pinRow: some View {
        let shouldShowOptions = !viewModel.isFreeUser && !viewModel.pin.isEmpty
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.grid3, color: tintColor)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("PIN")
                    .sectionTitleText()

                UpsellableDetailText(text: isShowingPIN ?
                    viewModel.pin : String(repeating: "•", count: viewModel.pin.count),
                    placeholder: nil,
                    shouldUpgrade: false,
                    upgradeTextColor: tintColor,
                    onUpgrade: viewModel.upgrade)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .animation(.default, value: isShowingPIN)

            Spacer()

            if shouldShowOptions {
                CircleButton(icon: isShowingPIN ? IconProvider.eyeSlash : IconProvider.eye,
                             iconColor: viewModel.itemContent.type.normMajor2Color,
                             backgroundColor: viewModel.itemContent.type.normMinor2Color,
                             action: { isShowingPIN.toggle() })
                    .fixedSize(horizontal: true, vertical: true)
                    .animationsDisabled()
            }
        }
        .padding(.horizontal, kItemDetailSectionPadding)
        .contextMenu {
            if shouldShowOptions {
                Button(action: {
                    withAnimation {
                        isShowingPIN.toggle()
                    }
                }, label: {
                    Text(isShowingPIN ? "Conceal" : "Reveal")
                })
            }
        }
    }

    var expirationDateRow: some View {
        HStack(spacing: kItemDetailSectionPadding) {
            ItemDetailSectionIcon(icon: IconProvider.calendarDay, color: tintColor)

            VStack(alignment: .leading, spacing: kItemDetailSectionPadding / 4) {
                Text("Expires on")
                    .sectionTitleText()

                UpsellableDetailText(text: viewModel.expirationDate,
                                     placeholder: nil,
                                     shouldUpgrade: false,
                                     upgradeTextColor: tintColor,
                                     onUpgrade: viewModel.upgrade)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, kItemDetailSectionPadding)
    }
}
