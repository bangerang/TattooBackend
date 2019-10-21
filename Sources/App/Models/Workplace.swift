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
struct Time: Codable {
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
}
enum Day: String, Codable, ReflectionDecodable {
	static func reflectDecoded() throws -> (Day, Day) {
		return (.monday, .tuesday)
	}
	
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
	case sunday
}
struct WorkHour: Codable {
	let day: Day
	let start: Time
	let end: Time
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
}
struct Workplace: Codable {
	var id: UUID?
	var artistID: Artist.ID
	var location: Location?
	var workHours: [WorkHour]
	var numberOfDaysAllowedForBooking: Int
}

extension Workplace: PostgreSQLUUIDModel {}
extension Workplace: Content {}
extension Workplace: Migration {}
extension Workplace: Parameter {}
