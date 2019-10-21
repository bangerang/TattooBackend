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
    dateComponents.year = 1

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
struct CalenderService: Service {
	func getAvailableSpots(using timeslot: Timeslot, from events: [ClosedDateRange], on connection: DatabaseConnectable) throws -> Future<[ClosedDateRange]> {
		return timeslot.artist.get(on: connection).flatMap { artist in
			return try artist.workplace.query(on: connection).all().flatMap { workplaces in
				// For now assume one workplace
				let workplace = workplaces[0]
				
				let dates = yearlyDatesFromCurrentDate()
				
				var availableDates = [ClosedDateRange]()
				
				for day in dates {
					if let workDay = workplace.workHours.first(where: { $0.day.rawValue == day.dayOfWeek() }) {
						var start = workDay.start
						var end = try start.time(byAddingMinutes: timeslot.timeInMinutes)
						while (end.totalInMinutes <= workDay.end.totalInMinutes) {
							if let startDate = Calendar.current.date(bySettingHour: start.hour, minute: start.minute, second: 0, of: day),
								let endDate = Calendar.current.date(bySettingHour: end.hour, minute: end.minute, second: 0, of: day) {
								availableDates.append(ClosedDateRange(startDate: startDate, endDate: endDate))
							}
							
							try? start = start.time(byAddingMinutes: timeslot.timeInMinutes)
							try? end = start.time(byAddingMinutes: timeslot.timeInMinutes)
						}
					}
				}
				
				// Performance????
				for (index, availableDate) in availableDates.enumerated().reversed() {
					for event in events {
						if event.startDate.isBetweenDates(beginDate: availableDate.startDate, endDate: availableDate.endDate) || event.endDate.isBetweenDates(beginDate: availableDate.startDate, endDate: availableDate.endDate) {
							
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
