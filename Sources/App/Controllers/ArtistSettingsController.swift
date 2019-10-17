//
//  TattooSettingsController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

struct ArtistSettingsController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "artists", "settings")
    usersRoute.post(ArtistSettings.self, use: createHandler)
    usersRoute.get(use: getAllHandler)
    usersRoute.get(ArtistSettings.parameter, use: getHandler)
  }

  func createHandler(_ req: Request, settings: ArtistSettings) throws -> Future<ArtistSettings> {
    return settings.save(on: req)
  }

  func getAllHandler(_ req: Request) throws -> Future<[ArtistSettings]> {
    return ArtistSettings.query(on: req).all()
  }

  func getHandler(_ req: Request) throws -> Future<ArtistSettings> {
	return try req.parameters.next(ArtistSettings.self)
  }
}
