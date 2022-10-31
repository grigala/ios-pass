//
// GetShareEndpoint.swift
// Proton Pass - Created on 13/08/2022.
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

import ProtonCore_Networking

public struct GetShareResponse: Decodable {
    let code: Int
    let share: Share
}

public struct GetShareEndpoint: Endpoint {
    public typealias Body = EmptyRequest
    public typealias Response = GetShareResponse

    public var debugDescription: String
    public var authCredential: AuthCredential?
    public var path: String
    public var method: HTTPMethod

    public init(credential: AuthCredential, shareId: String) {
        self.debugDescription = "Get share data"
        self.authCredential = credential
        self.path = "/pass/v1/share/\(shareId)"
        self.method = .get
    }
}
