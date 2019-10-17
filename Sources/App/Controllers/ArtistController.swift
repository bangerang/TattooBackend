//
//  TattooArtistController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

struct ArtistController: RouteCollection {
	func boot(router: Router) throws {
		let usersRoute = router.grouped("api", "artists")
		usersRoute.post(Artist.self, use: createHandler)
		usersRoute.get(use: getAllHandler)
		usersRoute.get(Artist.parameter, use: getHandler)
		let settings = usersRoute.grouped(Artist.parameter, "settings")
		settings.get(use: getSettingsHandler)
	}
	
	func createHandler(_ req: Request, artist: Artist) throws -> Future<Artist> {
		return artist.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Artist]> {
		return Artist.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<Artist> {
		return try req.parameters.next(Artist.self)
	}
	
	func getSettingsHandler(_ req: Request) throws -> Future<[ArtistSettings]> {
		return try req.parameters.next(Artist.self).flatMap(to: [ArtistSettings].self) { artist in
			try artist.settings.query(on: req).all()
		}
	}
}
