//
//  CalenderService.swift
//  App
//
//  Created by Johan Thorell on 2019-10-21.
//

import Foundation
import Vapor
import FluentPostgreSQL

func yearlyDatesFromCurrentDate() -> [Date] {
	
	// Set "date" to equal the current day
	var date = Date()
	
	// Increment "date" by one year to calculate the ending
	// date for the loop
	let gregorian:NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
	var dateComponents = DateComponents()
	dateComponents.month = 2
	
	let endingDate = gregorian.date(byAdding: dateComponents, to: date)!
	
	// Create an array to hold *all* the returned
	// results for the year
	var datesArray: [Date] = []
	
	// Loop through each date until the ending date is
	// reached
	while date.compare(endingDate) != .orderedDescending {
		// Call your prayerTimesDate: method on the current
		// date to get that date's prayer times and add the
		// times from the returned array to the datesArray
		
		// increment the date by 1 day
		var dateComponents = DateComponents()
		dateComponents.day = 1
		date = gregorian.date(byAdding: dateComponents, to: date)!
		datesArray.append(date)
	}
	
	return datesArray
}
func binarySearch<T: Comparable>(array: Array<T>, value: T) -> T? {
	var lowerBounds = 0
	var upperBound = array.count - 1
	var middle = 0
	var foundValue: T?
	while (lowerBounds <= upperBound) {
		// Find the middle of the array
		middle = (lowerBounds + upperBound) / 2
		if (array[middle] == value) {
			foundValue = value
			break
		}else if (array[middle] < value) {
			lowerBounds = middle + 1
		}else {
			upperBound = middle - 1
		}
	}
	
	return foundValue
}
private func getClosedDateRange(fromStart start: Time, andEnd end: Time, using date: Date) -> ClosedDateRange? {
	let calender = Calendar.current
	guard
		let startDate = calender.date(bySettingHour: start.hour, minute: start.minute, second: 0, of: date),
		let endDate = calender.date(bySettingHour: end.hour, minute: end.minute, second: 0, of: date)
		else {
			return nil
	}
	return ClosedDateRange(startDate: startDate, endDate: endDate)
}
struct CalenderService: Service {
	
	func getAvailableSpots(using timeslot: Timeslot, from events: [ClosedDateRange], on connection: DatabaseConnectable) throws -> Future<[ClosedDateRange]> {
		return timeslot.artist.get(on: connection).flatMap { artist in
			return try artist.workplace.query(on: connection).all().flatMap { workplaces in
				// For now assume one workplace
				let workplace = workplaces[0]
				
				let dates = yearlyDatesFromCurrentDate()
				
				var availableDates = [ClosedDateRange]()
				let bookings = Booking.query(on: connection)
					.filter(\.artistID == artist.id!)
					.group(.or) {
						$0.filter(\.state == .booked).filter(\.state == .requested)
				}
				.all()
				
				let addCandidate: (Time, Time, Date, [Time]) -> Bool = { start, end, date, breaks in
					
					let containsBreaks = start.and(end).containsTime(breaks)
					
					if !containsBreaks, let dateRange = getClosedDateRange(fromStart: start, andEnd: end, using: date) {
						availableDates.append(dateRange)
						return true
					}
					
					return false
				}
				
				let endDates = bookings.flatMap { bookings -> Future<[Date]> in
					return try bookings.compactMap { booking in
						try booking.getEndDate(on: connection)
					}.flatten(on: connection)
				}
				
				let workDays = try workplace.workDays.query(on: connection).all()
				
				
				return bookings.and(endDates).and(workDays).flatMap { weirdTuple in
					let bookings = weirdTuple.0.0
					let endDates = weirdTuple.0.1
					let workDays = weirdTuple.1

					let bookingIDWithEndDates = zip(bookings, endDates).reduce(into: [UUID: Date]()) { (dict, arg1) in
						let (booking, date) = arg1
						return dict[booking.id!] = date
					}
					let calender = Calendar.current
					for day in dates {
						if let workDay = workDays.first(where: { $0.day == day.dayOfWeek() }) {
							let breaks = workDay.breaks.map{$0.start}
							
							let bookingsSameDay = bookings.filter{ Calendar.current.isDate(day, equalTo: $0.startDate!, toGranularity: .day) }
							if !bookingsSameDay.isEmpty {
								let morningIsBooked = bookingsSameDay.contains(where: {
									let hourComponent = Calendar.current.component(.hour, from: $0.startDate!)
									return hourComponent == workDay.workhours.start.hour
								})
								let startTimefromBookedSameDay = try bookingsSameDay.map{ try $0.startDate!.getTime() }
								
								for bookingSameDay in bookingsSameDay {
									if morningIsBooked {
										
										let endDate = bookingIDWithEndDates[bookingSameDay.id!]!
										let endComponents = calender.dateComponents([.hour, .minute], from: endDate)
										var startTime = try Time(hour: endComponents.hour!, minute: endComponents.minute!)
										var endTime = try startTime.time(byAddingMinutes: timeslot.timeInMinutes)
										while (endTime.hour <= workDay.end.hour && !addCandidate(startTime, endTime, day, breaks + startTimefromBookedSameDay)) {
											startTime = try startTime.time(byAddingMinutes: timeslot.timeInMinutes)
											endTime = try endTime.time(byAddingMinutes: timeslot.timeInMinutes)
										}
									}else {
										
										let startComponents = calender.dateComponents([.hour, .minute], from: bookingSameDay.startDate!)
										var endTime = try Time(hour: startComponents.hour!, minute: startComponents.minute!)
										var startTime = try endTime.time(byAddingMinutes: -timeslot.timeInMinutes)
										while (startTime.hour >= workDay.start.hour && addCandidate(startTime, endTime, day, breaks + startTimefromBookedSameDay)) {
											endTime = try endTime.time(byAddingMinutes: -timeslot.timeInMinutes)
											startTime = try startTime.time(byAddingMinutes: -timeslot.timeInMinutes)
										}
									}
								}
							}else {
								
								let workdayStart = workDay.workhours.start
								let workdayStartEnd = try workdayStart.time(byAddingMinutes: timeslot.timeInMinutes)
								
								_ = addCandidate(workdayStart, workdayStartEnd, day, breaks)
								
								let workdayEndStart = try workDay.workhours.end.time(byAddingMinutes: -timeslot.timeInMinutes)
								let workdayEndEnd = workDay.workhours.end
								
								_ = addCandidate(workdayEndStart, workdayEndEnd, day, breaks)
								
							}
						}
					}
					
					// Performance????
					for (index, availableDate) in availableDates.enumerated().reversed() {
						for event in events {
							if availableDate.contains(event) {
								availableDates.remove(at: index)
							}
						}
					}
					
					
					let promise = connection.eventLoop.newPromise([ClosedDateRange].self)
					promise.succeed(result: availableDates)
					return promise.futureResult
				}
				
			}
		}
		
	}
}
