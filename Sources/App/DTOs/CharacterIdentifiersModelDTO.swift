//
//  CharacterIdentifiersModelDTO.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/29/24.
//

import Vapor

public struct CharacterPublicDataResponse: Decodable {
    public let alliance_id: Int32?
    public let birthday: String // date-time
    public let bloodline_id: Int32
    public let corporation_id: Int32
    public let description: String?
    public let faction_id: Int32?
    public let gender: String
    public let name: String
    public let race_id: Int32
    public let security_status: Float?
    public let title: String?
}

public struct CharacterIdentifiersModelDTO: Content {
    public var characterID: Int64
    public var name: String
    public var corporationID: Int64
    public var allianceID: Int64?
    public var securityStatus: Float?
    
    public func toModel() -> CharacterIdentifiersModel {
        CharacterIdentifiersModel(
            characterID: characterID,
            name: name,
            corporationID: corporationID,
            allianceID: allianceID
        )
    }
}
