//
//  SolarSystemModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/11/24.
//

import Fluent
import Vapor

final public class SolarSystemModel: Model {
    static public let schema = Schemas.Universe.solarSystems.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "constellation_id") public var constellationID: Int64
    @Field(key: "name") public var name: String
    @Field(key: "security_class") public var securityClass: String?
    @Field(key: "security_status") public var securityStatus: Float
    @Field(key: "star_id") public var starID: Int64?
    @Field(key: "system_id") public var systemID: Int64
    
    public init() { }
    
    public init(
        constellationID: Int64,
        name: String,
        securityClass: String?,
        securityStatus: Float,
        starID: Int64?,
        systemID: Int64
    ) {
        self.constellationID = constellationID
        self.name = name
        self.securityClass = securityClass
        self.securityStatus = securityStatus
        self.starID = starID
        self.systemID = systemID
    }
    
    public convenience init(from dto: GetUniverseSystemsDTO) {
        self.init(
            constellationID: Int64(dto.constellationId),
            name: dto.name,
            securityClass: dto.securityClass,
            securityStatus: dto.securityStatus,
            starID: Int64(dto.starId ?? -1),
            systemID: Int64(dto.systemId)
        )
    }
    
    func toDTO() -> SolarSystemDTO {
        SolarSystemDTO(
            constellationID: constellationID,
            name: name,
            securityClass: securityClass,
            securityStatus: securityStatus,
            starID: starID,
            systemID: systemID
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: Database) async throws {
            try await database.schema(SolarSystemModel.schema)
                .id()
                .field("constellation_id", .int64, .required)
                .field("name", .string, .required)
                .field("security_class", .string)
                .field("security_status", .float, .required)
                .field("star_id", .int64)
                .field("system_id", .int64, .required)
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(SolarSystemModel.schema)
                .delete()
        }
    }
}



/** 200 ok object */

public struct GetUniverseSystemsDTO: Content {

    /** The constellation this solar system is in */
    public var constellationId: Int
    /** name string */
    public var name: String
    /** planets array */
    public var planets: [GetUniverseSystemsSystemIdPlanet]?
    public var position: GetUniverseSystemsSystemIdPosition
    /** security_class string */
    public var securityClass: String?
    /** security_status number */
    public var securityStatus: Float
    /** star_id integer */
    public var starId: Int?
    /** stargates array */
    public var stargates: [Int]?
    /** stations array */
    public var stations: [Int]?
    /** system_id integer */
    public var systemId: Int

    public init(constellationId: Int, name: String, planets: [GetUniverseSystemsSystemIdPlanet]? = nil, position: GetUniverseSystemsSystemIdPosition, securityClass: String? = nil, securityStatus: Float, starId: Int? = nil, stargates: [Int]? = nil, stations: [Int]? = nil, systemId: Int) {
        self.constellationId = constellationId
        self.name = name
        self.planets = planets
        self.position = position
        self.securityClass = securityClass
        self.securityStatus = securityStatus
        self.starId = starId
        self.stargates = stargates
        self.stations = stations
        self.systemId = systemId
    }

    public enum CodingKeys: String, CodingKey {
        case constellationId = "constellation_id"
        case name
        case planets
        case position
        case securityClass = "security_class"
        case securityStatus = "security_status"
        case starId = "star_id"
        case stargates
        case stations
        case systemId = "system_id"
    }

}

public struct GetUniverseSystemsSystemIdPlanet: Codable {

    /** asteroid_belts array */
    public var asteroidBelts: [Int]?
    /** moons array */
    public var moons: [Int]?
    /** planet_id integer */
    public var planetId: Int

    public init(asteroidBelts: [Int]? = nil, moons: [Int]? = nil, planetId: Int) {
        self.asteroidBelts = asteroidBelts
        self.moons = moons
        self.planetId = planetId
    }

    public enum CodingKeys: String, CodingKey {
        case asteroidBelts = "asteroid_belts"
        case moons
        case planetId = "planet_id"
    }

}

public struct GetUniverseSystemsSystemIdPosition: Codable {
    /** x number */
    public var x: Double
    /** y number */
    public var y: Double
    /** z number */
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
