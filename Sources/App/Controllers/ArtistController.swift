//
//  TattooArtistController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor

struct ClosedDateRange {
	let startDate: Date
	let endDate: Date
	
	func contains(_ dateRange: ClosedDateRange) -> Bool {
		return dateRange.startDate.isBetweenDates(beginDate: startDate, endDate: endDate) || dateRange.endDate.isBetweenDates(beginDate: startDate, endDate: endDate)
	}
}
extension ClosedDateRange: Content {}

class ArtistController: BaseModelController<Artist> {
	
	override func boot(router: Router) throws {
		try super.boot(router: router)
		let settings = route.grouped(Artist.parameter, "settings")
		settings.get(use: getSettingsHandler)
		let timeslots = route.grouped(Artist.parameter, "timeslots")
		timeslots.get(use: getTimeslotsHandler)
		let calender = route.grouped(Artist.parameter, "calender", Timeslot.parameter)
		calender.get(use: getAvailableEventsHandler)
		let tattooSizes = route.grouped(Artist.parameter, "tattoo-sizes")
		tattooSizes.get(use: getAvailableTattooSizesHandler)
		let bookings = route.grouped(Artist.parameter, "bookings")
		bookings.get(use: getBookingsHandler)
		
	}
	
	func getSettingsHandler(_ req: Request) throws -> Future<[ArtistSettings]> {
		return try req.parameters.next(Artist.self).flatMap(to: [ArtistSettings].self) { artist in
			try artist.settings.query(on: req).all()
		}
	}
	
	func getTimeslotsHandler(_ req: Request) throws -> Future<[Timeslot]> {
		return try req.parameters.next(Artist.self).flatMap(to: [Timeslot].self) { artist in
			try artist.timeslots.query(on: req).all()
		}
	}
	
	func getAvailableEventsHandler(_ req: Request) throws -> Future<[ClosedDateRange]> {
		return try req.parameters.next(Artist.self).flatMap(to: [ClosedDateRange].self) { artist in
			return try req.parameters.next(Timeslot.self).flatMap(to: [ClosedDateRange].self) { timeslot in
				let calenderService = try req.make(CalenderService.self)
				let calenderProvider = try req.make(CalenderProvider.self)
				let events: [ClosedDateRange] = calenderProvider.getEvents()
				return try calenderService.getAvailableSpots(using: timeslot, from: events, on: req)
			}
		}
	}
	
	func getAvailableTattooSizesHandler(_ req: Request) throws -> Future<[TattooSize]> {
		return try req.parameters.next(Artist.self).flatMap(to: [TattooSize].self) { artist in
			try artist.tattooSizes.query(on: req).all()
		}
	}
	
	func getBookingsHandler(_ req: Request) throws -> Future<[Booking]> {
		return try req.parameters.next(Artist.self).flatMap(to: [Booking].self) { artist in
			try artist.bookings.query(on: req).all()
		}
	}

}
