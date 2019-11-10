//
//  TattooBooking.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Foundation
import Vapor
import FluentPostgreSQL

enum BookingStatus: String, PostgreSQLEnum, PostgreSQLMigration {
	
	case initial
	case requested
	case booked
	case done
	
	static func reflectDecoded() throws -> (BookingStatus, BookingStatus) {
		return (.initial, .requested)
	}
}

struct Booking: Codable {

	var id: UUID?
	var pickedSettings: [ArtistPropertySetting]
	var state: BookingStatus
	var timeSlotID: Timeslot.ID?
	var startDate: Date?
	private(set) var artistID: Artist.ID
	private(set) var customerID: Customer.ID
}
extension Booking {
	var artist: Parent<Booking, Artist> {
		return parent(\.artistID)
	}
	var timeslot: Parent<Booking, Timeslot>? {
		return parent(\.timeSlotID)
	}
	func getEndDate(on connection: DatabaseConnectable) throws -> Future<Date> {
		guard let timeslot = timeslot, let startDate = self.startDate else {
			throw Abort(.notFound)
		}
		return timeslot.get(on: connection).flatMap(to: Date.self) { timeslot in
			let newPromise = connection.eventLoop.newPromise(Date.self)
			newPromise.succeed(result:startDate.addingTimeInterval(TimeInterval(timeslot.timeInMinutes * 60)))
			return newPromise.futureResult
		}
	}
	var customer: Parent<Booking, Customer> {
		return parent(\.customerID)
	}
}

extension Booking: PostgreSQLUUIDModel {}
extension Booking: Content {}
extension Booking: Migration {}
extension Booking: Parameter {}
