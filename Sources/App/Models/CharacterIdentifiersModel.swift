//
//  CharacterIdentifiersModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/11/24.
//

import Foundation
import Fluent

final public class CharacterIdentifiersModel: Model {
    static public let schema = Schemas.characterIdentifiersModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "character_id") public var characterID: Int64
    @Field(key: "name") public var name: String
    @Field(key: "corporation_id") public var corporationID: Int64
    @Field(key: "alliance_id") public var allianceID: Int64?
    @Field(key: "security_status") public var securityStatus: Float?
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        characterID: Int64,
        name: String,
        corporationID: Int64,
        allianceID: Int64? = nil,
        securityStatus: Float? = nil
    ) {
        self.id = id
        self.characterID = characterID
        self.name = name
        self.corporationID = corporationID
        self.allianceID = allianceID
        self.securityStatus = securityStatus
    }
    
    public convenience init(
        characterId: Int64,
        data: CharacterPublicDataResponse
    ) {
        self.init(
            characterID: characterId,
            name: data.name,
            corporationID: Int64(data.corporation_id),
            allianceID: Int64(data.alliance_id ?? -1),
            securityStatus: data.security_status
        )
    }
    
    public func toDTO() -> CharacterIdentifiersModelDTO {
        CharacterIdentifiersModelDTO(
            characterID: characterID,
            name: name,
            corporationID: corporationID,
            allianceID: allianceID,
            securityStatus: securityStatus
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterIdentifiersModel.schema)
                .id()
                .field("character_id", .int64, .required)
                .field("name", .string, .required)
                .field("corporation_id", .int64, .required)
                .field("alliance_id", .int64)
                .field("security_status", .float)
                .unique(on: "character_id")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIdentifiersModel.schema)
                .delete()
        }
    }
}
