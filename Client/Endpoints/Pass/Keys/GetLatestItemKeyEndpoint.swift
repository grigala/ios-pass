//
// GetLatestItemKeyEndpoint.swift
// Proton Pass - Created on 24/02/2023.
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

import ProtonCore_Networking

public struct GetLatestItemKeyResponse: Decodable {
    public let code: Int
    public let key: ItemKey
}

public struct GetLatestItemKeyEndpoint: Endpoint {
    public typealias Body = EmptyRequest
    public typealias Response = GetLatestItemKeyResponse

    public var debugDescription: String
    public var path: String
    public var method: HTTPMethod

    public init(shareId: String, itemId: String) {
        debugDescription = "Get latest key for item"
        path = "/pass/v1/share/\(shareId)/item/\(itemId)/key/latest"
        method = .get
    }
}
