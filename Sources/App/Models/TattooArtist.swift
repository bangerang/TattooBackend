//
//  TattooArtist.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct TattooArtist: Codable {
	var id: UUID?
	var name: String
	var username: String
	var email: String
	var password: String

}

extension TattooArtist: PostgreSQLUUIDModel {}
extension TattooArtist: Content {}
extension TattooArtist: Migration {}
extension TattooArtist: Parameter {}

extension TattooArtist {
	var settings: Children<TattooArtist, TattooArtistSettings> {
		return children(\.tattooArtistID)
	}
}
