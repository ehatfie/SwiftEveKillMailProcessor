//
//  ZKillmailDTO.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/26/24.
//

import Fluent
import Vapor

struct ZKillmailDTO: Content {
    
    func toModel() -> ZKillmailModel {
        let model = ZKillmailModel()
        return model
    }
}
