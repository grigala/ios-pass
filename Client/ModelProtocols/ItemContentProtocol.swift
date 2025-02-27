//
// ItemContentProtocol.swift
// Proton Pass - Created on 09/08/2022.
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
import CryptoKit

// RawValue is used for telemetry, we need to know the item type of the actions
public enum ItemContentType: Int, CaseIterable {
    case login = 0
    case alias = 1
    case note = 2
    case creditCard = 3
}

extension ItemContentType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .login: return "login"
        case .alias: return "alias"
        case .note: return "note"
        case .creditCard: return "creditCard"
        }
    }
}

public enum ItemContentData {
    case alias
    case login(LogInItemData)
    case note
    case creditCard(CreditCardData)

    public var type: ItemContentType {
        switch self {
        case .alias:
            return .alias
        case .login:
            return .login
        case .note:
            return .note
        case .creditCard:
            return .creditCard
        }
    }
}

public struct LogInItemData {
    public let username: String
    public let password: String
    public let totpUri: String
    public let urls: [String]

    public init(username: String, password: String, totpUri: String, urls: [String]) {
        self.username = username
        self.password = password
        self.totpUri = totpUri
        self.urls = urls
    }
}

public struct CreditCardData {
    public let cardholderName: String
    public let type: ProtonPassItemV1_CardType
    public let number: String
    public let verificationNumber: String
    public let expirationDate: String // YYYY-MM
    public let pin: String

    public init(cardholderName: String,
                type: ProtonPassItemV1_CardType,
                number: String,
                verificationNumber: String,
                expirationDate: String,
                pin: String) {
        let monthYear = expirationDate.components(separatedBy: "-")
        let month = Int(monthYear.last ?? "")
        let year = Int(monthYear.first ?? "")
        assert(month != nil && year != nil, "Bad expirationDate format")

        self.cardholderName = cardholderName
        self.type = type
        self.number = number
        self.verificationNumber = verificationNumber
        self.expirationDate = expirationDate
        self.pin = pin
    }
}

public enum CustomFieldType: CaseIterable {
    case text, totp, hidden
}

public struct CustomField {
    public let title: String
    public let type: CustomFieldType
    public var content: String

    public init(title: String, type: CustomFieldType, content: String) {
        self.title = title
        self.type = type
        self.content = content
    }

    init(from extraField: ProtonPassItemV1_ExtraField) {
        title = extraField.fieldName
        switch extraField.content {
        case let .text(extraText):
            type = .text
            content = extraText.content

        case let .totp(extraTotp):
            type = .totp
            content = extraTotp.totpUri

        case let .hidden(extraHidden):
            type = .hidden
            content = extraHidden.content

        default:
            type = .text
            content = ""
        }
    }
}

public protocol ItemContentProtocol {
    var name: String { get }
    var note: String { get }
    var contentData: ItemContentData { get }
    var customFields: [CustomField] { get }
}

public typealias ItemContentProtobuf = ProtonPassItemV1_Item
public typealias ProtobufableItemContentProtocol = ItemContentProtocol & Protobufable

extension ItemContentProtobuf: ProtobufableItemContentProtocol {
    public var name: String { metadata.name }
    public var note: String { metadata.note }
    public var uuid: String { metadata.itemUuid }

    public var contentData: ItemContentData {
        switch content.content {
        case .alias:
            return .alias

        case .note:
            return .note

        case let .creditCard(data):
            return .creditCard(.init(cardholderName: data.cardholderName,
                                     type: data.cardType,
                                     number: data.number,
                                     verificationNumber: data.verificationNumber,
                                     expirationDate: data.expirationDate,
                                     pin: data.pin))

        case let .login(data):
            return .login(.init(username: data.username,
                                password: data.password,
                                totpUri: data.totpUri,
                                urls: data.urls))
        case .none:
            return .note
        }
    }

    public var customFields: [CustomField] { extraFields.map { .init(from: $0) } }

    public func data() throws -> Data {
        try serializedData()
    }

    public init(data: Data) throws {
        self = try ItemContentProtobuf(serializedData: data)
    }

    public init(name: String,
                note: String,
                itemUuid: String,
                data: ItemContentData,
                customFields: [CustomField]) {
        metadata = .init()
        metadata.itemUuid = itemUuid
        metadata.name = name
        metadata.note = note

        switch data {
        case .alias:
            content.alias = .init()

        case let .login(logInData):
            content.login = .init()
            content.login.username = logInData.username
            content.login.password = logInData.password
            content.login.totpUri = logInData.totpUri
            content.login.urls = logInData.urls

        case let .creditCard(data):
            content.creditCard = .init()
            content.creditCard.cardholderName = data.cardholderName
            content.creditCard.cardType = data.type
            content.creditCard.number = data.number
            content.creditCard.verificationNumber = data.verificationNumber
            content.creditCard.expirationDate = data.expirationDate
            content.creditCard.pin = data.pin

        case .note:
            content.note = .init()
        }

        extraFields = customFields.map { customField in
            var extraField = ProtonPassItemV1_ExtraField()
            extraField.fieldName = customField.title

            switch customField.type {
            case .text:
                extraField.text = .init()
                extraField.text.content = customField.content

            case .totp:
                extraField.totp = .init()
                extraField.totp.totpUri = customField.content

            case .hidden:
                extraField.hidden = .init()
                extraField.hidden.content = customField.content
            }

            return extraField
        }
    }
}

public struct ItemContent: ItemContentProtocol {
    public let shareId: String
    public let itemUuid: String
    public let item: ItemRevision
    public let name: String
    public let note: String
    public let contentData: ItemContentData
    public let customFields: [CustomField]

    public init(shareId: String,
                item: ItemRevision,
                contentProtobuf: ItemContentProtobuf) {
        self.shareId = shareId
        self.item = item
        itemUuid = contentProtobuf.uuid
        name = contentProtobuf.name
        note = contentProtobuf.note
        contentData = contentProtobuf.contentData
        customFields = contentProtobuf.customFields
    }

    public var protobuf: ItemContentProtobuf {
        .init(name: name,
              note: note,
              itemUuid: itemUuid,
              data: contentData,
              customFields: customFields)
    }
}

extension ItemContent: ItemIdentifiable {
    public var itemId: String { item.itemID }
}

extension ItemContent: ItemTypeIdentifiable {
    public var type: ItemContentType { contentData.type }
    public var aliasEmail: String? { item.aliasEmail }
}

extension ItemContent: ItemThumbnailable {
    public var title: String { name }

    public var url: String? {
        switch contentData {
        case let .login(data):
            return data.urls.first
        default:
            return nil
        }
    }
}

public extension ItemContent {
    /// Get `TOTPData` of the current moment
    func totpData() throws -> TOTPData? {
        if case let .login(logInData) = contentData,
           !logInData.totpUri.isEmpty {
            return try .init(uri: logInData.totpUri)
        } else {
            return nil
        }
    }
}

// MARK: - Symmetric encryption/decryption

public extension ItemContentProtobuf {
    /// Symmetrically encrypt and base 64 the binary data
    func encrypt(symmetricKey: SymmetricKey) throws -> String {
        let clearData = try data()
        let cypherData = try symmetricKey.encrypt(clearData)
        return cypherData.base64EncodedString()
    }

    init(base64: String, symmetricKey: SymmetricKey) throws {
        guard let cypherData = try base64.base64Decode() else {
            throw PPClientError.crypto(.failedToBase64Decode)
        }
        let clearData = try symmetricKey.decrypt(cypherData)
        try self.init(data: clearData)
    }
}
