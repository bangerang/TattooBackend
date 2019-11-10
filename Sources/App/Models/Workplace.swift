//
//  Workplace.swift
//  App
//
//  Created by Johan Thorell on 2019-10-20.
//

import Foundation
import Vapor
import FluentPostgreSQL

func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
    return (minutes / 60, (minutes % 60))
}

struct Location: Codable {
	let longitude: Double
	let latitude: Double
}

struct Time: Codable, Equatable {
	let hour: Int
	let minute: Int
	
	init(hour: Int, minute: Int) throws {
		if hour < 0 || hour > 23 || minute < 0 || minute > 59 {
			throw "Bad format"
		}
		self.hour = hour
		self.minute = minute
	}
}
extension Time {
	var totalInMinutes: Int {
		return (hour * 60) + minute
	}
	func time(byAddingMinutes minutes: Int) throws -> Time {
		let tuple = minutesToHoursMinutes(minutes: minutes)
		return try Time(hour: hour + tuple.hours, minute: minute + tuple.leftMinutes)
	}
	func and(_ otherTime: Time) -> [Time] {
		return [self, otherTime]
	}
}
extension Array where Element == Time {
	func containsTime(_ time: Time) -> Bool {
		guard let first = first, let last = last else {
			return false
		}
		return first.totalInMinutes-1..<last.totalInMinutes ~= time.totalInMinutes
	}
	func containsTime(_ times: [Time]) -> Bool {
		guard let first = first, let last = last else {
			return false
		}
		for time in times {
			if first.totalInMinutes-1..<last.totalInMinutes ~= time.totalInMinutes {
				return true
			}
		}
		
		return false
	}
}
enum Day: String, PostgreSQLEnum, PostgreSQLMigration {
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
	case sunday
}
struct ClosedTimeRange: Codable {
	let start: Time
	let end: Time
	func contains(_ otherTime: Time) -> Bool {
		return start.totalInMinutes...end.totalInMinutes ~= otherTime.totalInMinutes
	}
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
		return dateFormatter.string(from: self).lowercased()
    }
	func isBetweenDates(beginDate: Date, endDate: Date) -> Bool {
		if self.compare(beginDate) == .orderedAscending {
			return false
		}
		if self.compare(endDate) == .orderedDescending {
			return false
		}

		return true
	}
	func isEqualToByMinuteGranularity(_ otherDate: Date) -> Bool {
		return Calendar.current.isDate(otherDate, equalTo: self, toGranularity: .minute)
	}
	static func nextOccurrenceOfDay(_ day: Day) -> Date {
		var date = Date()
		let gregorian = Calendar(identifier: .gregorian)
		while (date.dayOfWeek() != day.rawValue) {
			var dateComponents = DateComponents()
			dateComponents.day = 1
			date = gregorian.date(byAdding: dateComponents, to: date)!
		}
		return date
	}
	func getTime() throws -> Time {
		let components = Calendar.current.dateComponents([.hour, .minute], from: self)
		return try Time(hour: components.hour!, minute: components.minute!)
	}
}
struct Workplace: Codable {
	var id: UUID?
	var name: String = ""
	var artistID: Artist.ID
	var location: Location?
	var numberOfDaysAllowedForBooking: Int
}
extension Workplace {
	var workDays: Children<Workplace, WorkDay> {
		return children(\.workPlaceID)
	}
}

extension Workplace: PostgreSQLUUIDModel {}
extension Workplace: Content {}
extension Workplace: Migration {}
extension Workplace: Parameter {}

struct WorkDay: Codable {
	var id: UUID?
	let day: String
	let workhours: ClosedTimeRange
	let breaks: [ClosedTimeRange]
	let workPlaceID: Workplace.ID
	var start: Time {
		workhours.start
	}
	var end: Time {
		workhours.end
	}
}
extension WorkDay {

	init(id: UUID?, day: Day, workhours: ClosedTimeRange, breaks: [ClosedTimeRange], workPlaceID: Workplace.ID) {
		self.init(id: id, day: day.rawValue, workhours: workhours, breaks: breaks, workPlaceID: workPlaceID)
	}
}

extension WorkDay: PostgreSQLUUIDModel {}
extension WorkDay: Content {}
extension WorkDay: Migration {}
extension WorkDay: Parameter {}
