//
//  BookingController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-22.
//

import Vapor
import FluentPostgreSQL

class BookingController: BaseModelController<Booking> {
	override func createHandler(_ req: Request, model: Booking) throws -> Future<Booking> {
		if model.state == .requested || model.state == .booked {
			guard (model.startDate != nil) else {
				throw Abort(.badRequest, reason: "Date can not be nil if state is requested or booked")
			}
			let bookings = Booking.query(on: req)
				.filter(\.artistID == model.artistID)
				.filter(\.startDate != nil)
				.group(.or) {
					$0.filter(\.state == .booked).filter(\.state == .requested)
			}.all()

			let dateAndBookings = bookings.flatMap(to: [(Date, Booking)].self) { bookings in
				let dates = try bookings.map { booking in
					return try booking.getEndDate(on: req)
				}
				return dates.flatten(on: req).flatMap { dates in
					return req.eventLoop.newSucceededFuture(result: Array(zip(dates, bookings)))
				}
			}
			
			let endDate = try model.getEndDate(on: req)
			
			return dateAndBookings.and(endDate).flatMap { dateAndBookings, modelEndDate in
				try dateAndBookings.forEach { endDate, booking in
					// FIX THIS!!
					if (!model.startDate!.isEqualToByMinuteGranularity(endDate) &&
						(model.startDate!.isBetweenDates(beginDate: booking.startDate!, endDate: endDate) ||
							(modelEndDate.isBetweenDates(beginDate: booking.startDate!, endDate: endDate) && !modelEndDate.isEqualToByMinuteGranularity(booking.startDate!)) ||
						model.startDate!.isEqualToByMinuteGranularity(booking.startDate!))) {
						throw Abort(.conflict, reason: "Booking date conflicts with other date")
					}
				}
				return model.save(on: req)
			}
			
		}else {
			return model.save(on: req)
		}
	}
}
