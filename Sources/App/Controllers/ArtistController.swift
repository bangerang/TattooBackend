//
//  TattooArtistController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

class ArtistController: BaseController<Artist> {
	
	override func boot(router: Router) throws {
		try super.boot(router: router)
		let settings = route.grouped(Artist.parameter, "settings")
		settings.get(use: getSettingsHandler)
	}
	
	func getSettingsHandler(_ req: Request) throws -> Future<[ArtistSettings]> {
		return try req.parameters.next(Artist.self).flatMap(to: [ArtistSettings].self) { artist in
			try artist.settings.query(on: req).all()
		}
	}
}
