//
// ClipboardExpiration.swift
// Proton Pass - Created on 26/12/2022.
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

import Foundation

public enum ClipboardExpiration: Int, CustomStringConvertible, CaseIterable {
    case fifteenSeconds = 0
    case oneMinute = 1
    case twoMinutes = 2
    case never = 3

    public var description: String {
        switch self {
        case .fifteenSeconds:
            return "After 15 seconds"
        case .oneMinute:
            return "After 60 seconds"
        case .twoMinutes:
            return "After 120 seconds"
        case .never:
            return "Never"
        }
    }

    public var expirationDate: Date? {
        switch self {
        case .fifteenSeconds:
            return Date().addingTimeInterval(15)
        case .oneMinute:
            return Date().addingTimeInterval(60)
        case .twoMinutes:
            return Date().addingTimeInterval(120)
        case .never:
            return nil
        }
    }
}
