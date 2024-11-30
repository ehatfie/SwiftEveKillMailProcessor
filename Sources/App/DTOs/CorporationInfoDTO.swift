//
//  CorporationInfoDTO.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/29/24.
//
import Vapor

public struct CorporationInfoDTO: Content {
    public var corporationId: Int32
    public var allianceId: Int?
    public var ceoId: Int
    public var creatorId: Int
    public var dateFounded: String?
    public var description: String?
    public var factionId: Int?
    public var homeStationId: Int?
    public var memberCount: Int
    public var name: String
    public var shares: Int64?
    public var taxRate: Float
    public var ticker: String
    public var url: String?
    public var warEligible: Bool?
    
    func toModel() -> CorporationInfoModel {
        CorporationInfoModel(from: self)
    }
}
