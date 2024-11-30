//
//  ESIKillmailDTO.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/27/24.
//

import Fluent
import Vapor

struct ESIKillmailDTO: Content {
    let id: UUID?
    let attackers: [ESIKmAttackerDTO]
    let killmailID: Int64
    let killmailTime: String
    let moonId: Int64?
    let solarSystemId: Int64
    let victim: ESIKmVictimDTO
    let warId: Int64?
    
    func toModel() -> ESIKillmailModel {
        let model = ESIKillmailModel(
            attackers: attackers.map { $0.toModel() },
            killmailId: killmailID,
            killmailTime: killmailTime,
            solarSystemId: solarSystemId,
            victim: victim.toModel()
        )
        return model
    }
}

struct ESIKmAttackerDTO: Content {
    public var allianceId: Int64?
    public var characterId: Int64?
    public var corporationId: Int64?
    public var damageDone: Int64
    public var factionId: Int64?
    public var finalBlow: Bool
    public var securityStatus: Float
    public var shipTypeId: Int64?
    public var weaponTypeId: Int64?
    
    func toModel() -> ESIKmAttacker {
        ESIKmAttacker(
            allianceId: allianceId,
            characterId: characterId,
            corporationId: corporationId,
            damageDone: damageDone,
            factionId: factionId,
            finalBlow: finalBlow,
            securityStatus: securityStatus,
            shipTypeId: shipTypeId,
            weaponTypeId: weaponTypeId
        )
    }
}

struct ESIKmVictimDTO: Content {
    public var allianceId: Int64
    public var characterId: Int64?
    public var corporationId: Int64?
    public var damageTaken: Int64
    public var factionId: Int64?
    public var items: [ESIKmVictimItemsDTO]
    public var shipTypeId: Int64?
    
    func toModel() -> ESIKmVictim {
        ESIKmVictim(
            allianceId: allianceId,
            characterId: characterId,
            corporationId: corporationId,
            damageTaken: damageTaken,
            factionId: factionId,
            items: items.map { $0.toModel() },
            shipTypeId: shipTypeId
        )
    }
}

struct ESIKmVictimItemsDTO: Content {
    public var itemFlag: Int64
    public var itemTypeId: Int64
    public var items: [ESIKmVictimItemsDTO]
    public var quantityDestroyed: Int64?
    public var quantityDropped: Int64?
    public var singleton: Int64
    
    func toModel() -> ESIKmVictimItems {
        ESIKmVictimItems(
            flag: itemFlag,
            itemTypeId: itemTypeId,
            items: items.map { $0.toModel() },
            quantityDestroyed: quantityDestroyed,
            quantityDropped: quantityDropped,
            singleton: singleton
        )
    }
}
