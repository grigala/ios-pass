//
// RemoteUserSettingsDatasource.swift
// Proton Pass - Created on 28/05/2023.
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

public protocol RemoteUserSettingsDatasourceProtocol: RemoteDatasourceProtocol {
    func getUserSettings() async throws -> UserSettings
}

public extension RemoteUserSettingsDatasourceProtocol {
    func getUserSettings() async throws -> UserSettings {
        let endpoint = GetUserSettingsEndpoint()
        let response = try await apiService.exec(endpoint: endpoint)
        return response.userSettings
    }
}

public final class RemoteUserSettingsDatasource: RemoteDatasource, RemoteUserSettingsDatasourceProtocol {}
