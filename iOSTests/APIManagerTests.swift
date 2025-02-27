//
// APIManagerTests.swift
// Proton Pass - Created on 23/02/2023.
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
@testable import Proton_Pass
import ProtonCore_Keymaker
import ProtonCore_Login
import ProtonCore_Networking
import ProtonCore_TestingToolkit
import XCTest

final class APIManagerTests: XCTestCase {
    var keychain: KeychainMock!
    var mainKeyProvider: MainKeyProviderMock!
    var logManager: LogManager!

    let appVer: String = .empty

    let unauthSessionKey = KeychainStorage<String>.Key.unauthSessionCredentials.rawValue
    let userDataKey = KeychainStorage<String>.Key.userData.rawValue

    let unauthSessionCredentials = AuthCredential(sessionID: "test_session_id",
                                                  accessToken: "test_access_token",
                                                  refreshToken: "test_refresh_token",
                                                  userName: "",
                                                  userID: "",
                                                  privateKey: nil,
                                                  passwordKeySalt: nil)

    let userData = UserData(
        credential: .init(sessionID: "test_session_id",
                          accessToken: "test_access_token",
                          refreshToken: "test_refresh_token",
                          userName: "test_user_name",
                          userID: "test_user_id",
                          privateKey: nil,
                          passwordKeySalt: nil),
        user: .init(ID: "test_id",
                    name: nil,
                    usedSpace: .zero,
                    currency: .empty,
                    credit: .zero,
                    maxSpace: .zero,
                    maxUpload: .zero,
                    role: .zero,
                    private: .zero,
                    subscribed: [],
                    services: .zero,
                    delinquent: .zero,
                    orgPrivateKey: .empty,
                    email: .empty,
                    displayName: .empty,
                    keys: .empty),
        salts: .empty,
        passphrases: [:],
        addresses: .empty,
        scopes: ["test_scope"]
    )

    let mainKey: MainKey = Array(repeating: .zero, count: 32)

    override func setUp() {
        super.setUp()
        keychain = KeychainMock()
        mainKeyProvider = MainKeyProviderMock()
        logManager = LogManager(module: .hostApp)
    }

    override func tearDown() {
        logManager = nil
        mainKeyProvider = nil
        keychain = nil
        super.tearDown()
    }

    func givenAppData() -> AppData {
        .init(keychain: keychain, mainKeyProvider: mainKeyProvider, logManager: logManager)
    }

    func testAPIServiceIsCreatedWithoutSessionIfNoSessionIsPersisted() {
        // GIVEN
        keychain.dataStub.bodyIs { _, _ in nil } // no session in keychain
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()

        // WHEN
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, .empty)
        XCTAssertNil(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID))
    }

    func testAPIServiceIsCreatedWithSessionIfUnauthSessionIsPersisted() throws {
        // GIVEN
        let unauthSessionCredentialsData = try JSONEncoder().encode(unauthSessionCredentials)
        let lockedSession = try Locked<Data>(clearValue: unauthSessionCredentialsData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.unauthSessionKey else { return nil }
            return lockedSession.encryptedValue // unauth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()

        // WHEN
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "test_session_id")
        XCTAssertEqual(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID),
                       Credential(unauthSessionCredentials))
    }

    func testAPIServiceIsCreatedWithSessionIfAuthSessionIsPersisted() throws {
        // GIVEN
        let userDataData = try JSONEncoder().encode(userData)
        let lockedSession = try Locked<Data>(clearValue: userDataData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.userDataKey else { return nil }
            return lockedSession.encryptedValue // UserData in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()

        // WHEN
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "test_session_id")
        XCTAssertEqual(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID),
                       Credential(userData.credential))
    }

    func testAPIServiceUpdateCredentialsUpdatesBothAPIServiceAndStorageForUnauthSession() throws {
        // GIVEN
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // WHEN
        apiService.sessionIsAvailable(authCredential: unauthSessionCredentials, scopes: .empty)

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "test_session_id")
        XCTAssertEqual(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID),
                       Credential(unauthSessionCredentials))
        XCTAssertTrue(keychain.setDataStub.wasCalledExactlyOnce)
        XCTAssertEqual(keychain.setDataStub.lastArguments?.second,
                       KeychainStorage<String>.Key.unauthSessionCredentials.rawValue)
    }

    func testAPIServiceUpdateCredentialsUpdatesBothAPIServiceAndStorageForAuthSession() throws {
        // GIVEN
        let userDataData = try JSONEncoder().encode(userData)
        let lockedSession = try Locked<Data>(clearValue: userDataData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.userDataKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // WHEN
        apiService.sessionIsAvailable(authCredential: userData.credential,
                                      scopes: userData.scopes)

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "test_session_id")
        XCTAssertEqual(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID),
                       Credential(userData.credential, scopes: userData.scopes))
        XCTAssertTrue(keychain.setDataStub.wasCalledExactlyOnce) // setting auth session
        XCTAssertEqual(keychain.setDataStub.lastArguments?.second,
                       KeychainStorage<String>.Key.userData.rawValue)
        XCTAssertTrue(keychain.removeStub.wasCalledExactlyOnce) // removing unauth session
        XCTAssertEqual(keychain.removeStub.lastArguments?.value,
                       KeychainStorage<String>.Key.unauthSessionCredentials.rawValue)
    }

    func testAPIServiceClearCredentialsClearsAPIServiceAndUnauthSessionStorage() throws {
        // GIVEN
        let unauthSessionData = try JSONEncoder().encode(unauthSessionCredentials)
        let lockedSession = try Locked<Data>(clearValue: unauthSessionData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.unauthSessionKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        // WHEN
        apiService.clearCredentials()

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "")
        XCTAssertNil(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID))
        XCTAssertTrue(keychain.removeStub.wasCalledExactlyOnce) // removing unauth session
        XCTAssertEqual(keychain.removeStub.lastArguments?.value,
                       KeychainStorage<String>.Key.unauthSessionCredentials.rawValue)
    }

    func testAPIServiceUnauthSessionInvalidationClearsCredentials() throws {
        // GIVEN
        let unauthSessionData = try JSONEncoder().encode(unauthSessionCredentials)
        let lockedSession = try Locked<Data>(clearValue: unauthSessionData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.unauthSessionKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        final class TestAPIManagerDelegate: APIManagerDelegate {
            @FuncStub(TestAPIManagerDelegate.appLoggedOutBecauseSessionWasInvalidated) var appLoggedOutStub

            func appLoggedOutBecauseSessionWasInvalidated() { appLoggedOutStub() }
        }
        let delegate = TestAPIManagerDelegate()
        apiService.delegate = delegate

        // WHEN
        apiService.sessionWasInvalidated(for: "test_session_id", isAuthenticatedSession: false)

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "")
        XCTAssertNil(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID))
        XCTAssertTrue(delegate.appLoggedOutStub.wasNotCalled)
    }

    func testAPIServiceAuthSessionInvalidationClearsCredentialsAndLogsOut() throws {
        // GIVEN
        let userDataData = try JSONEncoder().encode(userData)
        let lockedSession = try Locked<Data>(clearValue: userDataData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.userDataKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        final class TestAPIManagerDelegate: APIManagerDelegate {
            @FuncStub(TestAPIManagerDelegate.appLoggedOutBecauseSessionWasInvalidated) var appLoggedOutStub

            func appLoggedOutBecauseSessionWasInvalidated() { appLoggedOutStub() }
        }
        let delegate = TestAPIManagerDelegate()
        apiService.delegate = delegate

        // WHEN
        apiService.sessionWasInvalidated(for: "test_session_id", isAuthenticatedSession: true)

        // THEN
        XCTAssertEqual(apiService.apiService.sessionUID, "")
        XCTAssertNil(apiService.authHelper.credential(sessionUID: apiService.apiService.sessionUID))
        XCTAssertTrue(delegate.appLoggedOutStub.wasCalledExactlyOnce)
    }

    func testAPIServiceAuthCredentialsUpdateSetsNewUnauthCredentials() throws {
        // GIVEN
        let unauthSessionData = try JSONEncoder().encode(unauthSessionCredentials)
        let lockedSession = try Locked<Data>(clearValue: unauthSessionData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.unauthSessionKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        let newUnauthCredentials = AuthCredential(sessionID: "new_test_session_id",
                                                  accessToken: "new_test_access_token",
                                                  refreshToken: "new_test_refresh_token",
                                                  userName: "",
                                                  userID: "",
                                                  privateKey: nil,
                                                  passwordKeySalt: nil)
        let newUnauthSessionData = try JSONEncoder().encode(newUnauthCredentials)

        // WHEN
        apiService.credentialsWereUpdated(authCredential: newUnauthCredentials,
                                          credential: Credential(newUnauthCredentials),
                                          for: unauthSessionCredentials.sessionID
        )

        // THEN
        XCTAssertTrue(keychain.setDataStub.wasCalledExactlyOnce)
        XCTAssertEqual(keychain.setDataStub.lastArguments?.second, unauthSessionKey)
        let encryptedValue = try XCTUnwrap(keychain.setDataStub.lastArguments?.first)
        let unlockedSessionData = try Locked<Data>(encryptedValue: encryptedValue)
            .unlock(with: mainKey)
        XCTAssertEqual(unlockedSessionData, newUnauthSessionData)
    }

    func testAPIServiceAuthCredentialsUpdateUpdatesAuthSesson() throws {
        // GIVEN
        let userDataData = try JSONEncoder().encode(userData)
        let lockedSession = try Locked<Data>(clearValue: userDataData, with: mainKey)
        keychain.dataStub.bodyIs { _, key in
            guard key == self.userDataKey else { return nil }
            return lockedSession.encryptedValue // auth session in keychain
        }
        mainKeyProvider.mainKeyStub.fixture = mainKey
        let appData = givenAppData()
        let apiService = APIManager(logManager: logManager, appVer: appVer, appData: appData, preferences: Preferences())

        let newUnauthCredentials = AuthCredential(sessionID: "new_test_session_id",
                                                  accessToken: "new_test_access_token",
                                                  refreshToken: "new_test_refresh_token",
                                                  userName: "",
                                                  userID: "",
                                                  privateKey: nil,
                                                  passwordKeySalt: nil)

        // WHEN
        apiService.credentialsWereUpdated(authCredential: newUnauthCredentials,
                                          credential: Credential(newUnauthCredentials),
                                          for: unauthSessionCredentials.sessionID
        )

        // THEN
        XCTAssertTrue(keychain.setDataStub.wasCalledExactlyOnce)
        XCTAssertEqual(keychain.setDataStub.lastArguments?.second, userDataKey)
        let encryptedValue = try XCTUnwrap(keychain.setDataStub.lastArguments?.first)
        let unlockedUserData = try Locked<Data>(encryptedValue: encryptedValue)
            .unlock(with: mainKey)
        let newUserData = try JSONDecoder().decode(UserData.self, from: unlockedUserData)
        XCTAssertEqual(Credential(newUserData.credential), Credential(newUnauthCredentials))
        XCTAssertEqual(newUserData.user, userData.user)
    }
}
