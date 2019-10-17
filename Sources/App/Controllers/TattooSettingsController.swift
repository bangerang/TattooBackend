//
//  TattooSettingsController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

struct TattooSettingsController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "artists", "settings")
    usersRoute.post(TattooArtistSettings.self, use: createHandler)
    usersRoute.get(use: getAllHandler)
    usersRoute.get(TattooArtistSettings.parameter, use: getHandler)
  }

  func createHandler(_ req: Request, settings: TattooArtistSettings) throws -> Future<TattooArtistSettings> {
    return settings.save(on: req)
  }

  func getAllHandler(_ req: Request) throws -> Future<[TattooArtistSettings]> {
    return TattooArtistSettings.query(on: req).all()
  }

  func getHandler(_ req: Request) throws -> Future<TattooArtistSettings> {
	return try req.parameters.next(TattooArtistSettings.self)
  }
}
