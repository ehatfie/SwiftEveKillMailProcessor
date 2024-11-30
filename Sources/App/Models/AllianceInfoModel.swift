//
//  AllianceInfoModel.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/29/24.
//
import Foundation
import Fluent
import Vapor

public struct GetAllianceInfoResponse: Content {
    /** ID of the corporation that created the alliance */
    public var creatorCorporationId: Int
    /** ID of the character that created the alliance */
    public var creatorId: Int
    /** date_founded string */
    public var dateFounded: Date
    /** the executor corporation ID, if this alliance is not closed */
    public var executorCorporationId: Int?
    /** Faction ID this alliance is fighting for, if this alliance is enlisted in factional warfare */
    public var factionId: Int?
    /** the full name of the alliance */
    public var name: String
    /** the short name of the alliance */
    public var ticker: String
    
    public init(creatorCorporationId: Int, creatorId: Int, dateFounded: Date, executorCorporationId: Int? = nil, factionId: Int? = nil, name: String, ticker: String) {
        self.creatorCorporationId = creatorCorporationId
        self.creatorId = creatorId
        self.dateFounded = dateFounded
        self.executorCorporationId = executorCorporationId
        self.factionId = factionId
        self.name = name
        self.ticker = ticker
    }
}

public struct AllianceInfoDTO: Codable {
    public let creatorCorporationId: Int
    public let creatorId: Int
    public let dateFounded: Date
    public let executorCorporationId: Int?
    public let factionId: Int?
    public let name: String
    public let ticker: String
    
    public func toModel() -> AllianceInfoModel {
        AllianceInfoModel(from: self)
    }
}


final public class AllianceInfoModel: Model {
    static public let schema = Schemas.allianceInfoModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    @Field(key: "creator_corporation_id") public var creatorCorporationId: Int
    @Field(key: "creator_id") public var creatorId: Int
    @Field(key: "date_founded") public var dateFounded: Date
    @Field(key: "executor_corporation_id") public var executorCorporationId: Int?
    @Field(key: "faction_id") public var factionId: Int?
    @Field(key: "name") public var name: String
    @Field(key: "ticker") public var ticker: String
    
    public init() { }
    
    public init(from dto: AllianceInfoDTO) {
        self.id = UUID()
        
        self.creatorCorporationId = dto.creatorCorporationId
        self.creatorId = dto.creatorId
        self.dateFounded = dto.dateFounded
        self.executorCorporationId = dto.executorCorporationId
        self.factionId = dto.factionId
        self.name = dto.name
        self.ticker = dto.ticker
    }
    
    public struct ModelMigration: AsyncMigration {
        public func prepare(on database: Database) async throws {
            try await database.schema(AllianceInfoModel.schema)
                .id()
                .field("creator_corporation_id", .int, .required)
                .field("creator_id", .int, .required)
                .field("date_founded", .date, .required)
                .field("executor_corporation_id", .int)
                .field("faction_id", .int)
                .field("name", .string, .required)
                .field("ticker", .string, .required)
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(AllianceInfoModel.schema)
                .delete()
        }
    }
}
