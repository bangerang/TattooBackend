//
//  TattooArtistController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

struct TattooArtistController: RouteCollection {
	func boot(router: Router) throws {
		let usersRoute = router.grouped("api", "artists")
		usersRoute.post(TattooArtist.self, use: createHandler)
		usersRoute.get(use: getAllHandler)
		usersRoute.get(TattooArtist.parameter, use: getHandler)
		let settings = usersRoute.grouped(TattooArtist.parameter, "settings")
		settings.get(use: getSettingsHandler)
	}
	
	func createHandler(_ req: Request, artist: TattooArtist) throws -> Future<TattooArtist> {
		return artist.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[TattooArtist]> {
		return TattooArtist.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<TattooArtist> {
		return try req.parameters.next(TattooArtist.self)
	}
	
	func getSettingsHandler(_ req: Request) throws -> Future<[TattooArtistSettings]> {
		return try req.parameters.next(TattooArtist.self).flatMap(to: [TattooArtistSettings].self) { artist in
			try artist.settings.query(on: req).all()
		}
	}
}
