//
//  AuthEndpoint.swift
//  ProtonCore-Authentication - Created on 20/02/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ProtonCore_APIClient
import ProtonCore_DataModel
import ProtonCore_FeatureSwitch
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Utilities

extension Feature {
    public static var externalSignupHeader = Feature.init(name: "externalSignupHeader", isEnable: false, flags: [.availableCoreInternal])
}

extension AuthService {
    
    struct AuthRouteResponse: APIDecodableResponse, CredentialConvertible, Encodable {
        var accessToken: String
        var tokenType: String
        var refreshToken: String
        var scopes: Scopes
        var UID: String
        var userID: String
        var eventID: String
        var serverProof: String
        var passwordMode: PasswordMode
        
        var _2FA: TwoFA
    }
    
    struct AuthEndpoint: Request {
        struct AuthEndpointData {
            let username: String
            let ephemeral: Data
            let proof: Data
            let session: String
            let challenge: ChallengeProperties?
        }
        
        struct SSOEndpointData {
            let ssoResponseToken: String
        }
        
        let data: Either<AuthEndpointData, SSOEndpointData>
        
        init(data: Either<AuthEndpointData, SSOEndpointData>) {
            self.data = data
        }
        
        var path: String {
            "/auth/v4"
        }
        
        var method: HTTPMethod {
            .post
        }
        
        var header: [String: Any] {
            guard FeatureFactory.shared.isEnabled(.externalSignupHeader) else {
                return [:]
            }
            
            return ["X-Accept-ExtAcc": true]
        }
        
        var challengeProperties: ChallengeProperties? {
            if case let .left(authEndpointData) = data {
                return authEndpointData.challenge
            }
            
            return nil
        }
        
        var parameters: [String: Any]? {
            switch data {
            case .left(let authEndpointData):
                return [
                    "Username": authEndpointData.username,
                    "ClientEphemeral": authEndpointData.ephemeral.base64EncodedString(),
                    "ClientProof": authEndpointData.proof.base64EncodedString(),
                    "SRPSession": authEndpointData.session
                ]
            case .right(let ssoEndpointData):
                return [
                    "SSOResponseToken": ssoEndpointData.ssoResponseToken
                ]
            }
        }
        
        var isAuth: Bool {
            false
        }
    }
}
