//
//  BookingController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Vapor

struct BookingController: RouteCollection {
	func boot(router: Router) throws {
		let bookingRoute = router.grouped("api", "artists", "bookings")
		bookingRoute.post(Booking.self, use: createHandler)
		bookingRoute.get(use: getAllHandler)
		bookingRoute.get(Booking.parameter, use: getHandler)
		bookingRoute.put(Booking.parameter, use: putHandler)
		bookingRoute.delete(Booking.parameter, use: deleteHandler)
	}
	
	func createHandler(_ req: Request, booking: Booking) throws -> Future<Booking> {
		return booking.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Booking]> {
		return Booking.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<Booking> {
		return try req.parameters.next(Booking.self)
	}
	
	func putHandler(_ req: Request) throws -> Future<Booking> {
		return try req.parameters.next(Booking.self).update(on: req)
	}
	
	func deleteHandler(_ req: Request) throws -> Future<Booking> {
		return try req.parameters.next(Booking.self).delete(on: req)
	}
	
}
