//
//  Models+Testable.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-15.
//

@testable import App
import FluentPostgreSQL

extension ArtistSettings {
	static func create(tattooArtistID: Artist.ID, settings: [ArtistPropertySetting] = [.position(["Elbow", "Hand", "Leg"])], on connection: PostgreSQLConnection) throws -> ArtistSettings {
		let setting = ArtistSettings(artistID: tattooArtistID, settings: settings)
		return try setting.save(on: connection).wait()
	}
}
extension PostgreSQLUUIDModel {
	static func create(model: Self, on connection: PostgreSQLConnection) throws -> Self {
		return try model.save(on: connection).wait()
	}
}
