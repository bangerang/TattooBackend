//
//  TimeSlot.swift
//  App
//
//  Created by Johan Thorell on 2019-10-20.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Timeslot: Codable {

	var id: UUID?
	var artistID: Artist.ID
	var title: String
	var timeInMinutes: Int
	
}
extension Timeslot {
	var artist: Parent<Timeslot, Artist> {
		return parent(\.artistID)
	}
}

extension Timeslot: PostgreSQLUUIDModel {}
extension Timeslot: Content {}
extension Timeslot: Migration {}
extension Timeslot: Parameter {}
