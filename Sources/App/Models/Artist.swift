//
//  TattooArtist.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Artist: Codable {
	var id: UUID?
	var name: String
	var username: String
	var email: String
	var password: String
}

extension Artist: PostgreSQLUUIDModel {}
extension Artist: Content {}
extension Artist: Migration {}
extension Artist: Parameter {}

extension Artist {
	var settings: Children<Artist, ArtistSettings> {
		return children(\.artistID)
	}
	var timeslots: Children<Artist, Timeslot> {
		return children(\.artistID)
	}
	var workplace: Children<Artist, Workplace> {
		return children(\.artistID)
	}
	var tattooSizes: Children<Artist, TattooSize> {
		return children(\.artistID)
	}
	var bookings: Children<Artist, Booking> {
		return children(\.artistID)
	}
}
