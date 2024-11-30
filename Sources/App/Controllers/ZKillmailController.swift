//
//  KillmailController.swift
//  SwiftEveKillMailProcessor
//
//  Created by Erik Hatfield on 11/26/24.
//
import Fluent
import Vapor

struct KillmailController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let killmails = routes.grouped("killmails")
        killmails.get(use: self.index)
        killmails.post(use: self.create)
        killmails.group(":killmailID") { killmail in
            killmail.delete(use: self.delete)
        }
    }
    
    @Sendable
    func index(req: Request) async throws -> [ESIKillmailDTO] {
        try await ESIKillmailModel.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> ESIKillmailDTO {
        let killmail = try req.content.decode(ESIKillmailDTO.self).toModel()

        try await killmail.save(on: req.db)
        return killmail.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let killmail = try await ZKillmailModel.find(req.parameters.get("zkillmailID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await killmail.delete(on: req.db)
        return .noContent
    }
}
