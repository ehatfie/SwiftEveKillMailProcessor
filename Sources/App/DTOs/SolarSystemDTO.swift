//
//  SolarSystemDTO.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/29/24.
//

import Fluent
import Vapor

struct SolarSystemDTO: Content {
    public var constellationID: Int64
    public var name: String
    public var securityClass: String?
    public var securityStatus: Float
    public var starID: Int64?
    public var systemID: Int64
    
    func toModel() -> SolarSystemModel {
        return SolarSystemModel(
            constellationID: constellationID,
            name: name,
            securityClass: securityClass,
            securityStatus: securityStatus,
            starID: starID,
            systemID: systemID
        )
    }
}
