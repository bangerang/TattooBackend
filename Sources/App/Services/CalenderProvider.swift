//
//  CalenderProvider.swift
//  App
//
//  Created by Johan Thorell on 2019-10-21.
//

import Foundation
import Vapor

protocol CalenderProvider {
	func getEvents() -> [ClosedDateRange]
}

struct CalenderProviderMock: CalenderProvider, Service {
	func getEvents() -> [ClosedDateRange] {
		var monday = Date()
		
		let gregorian:NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
		while (monday.dayOfWeek() != Day.monday.rawValue) {
			var dateComponents = DateComponents()
			dateComponents.day = 1
			monday = gregorian.date(byAdding: dateComponents, to: monday)!
		}
		let firstStart = Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: monday)!
		let firstEnd = Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: monday)!
		
		let secondStart = Calendar.current.date(bySettingHour: 11, minute: 00, second: 0, of: monday)!
		let secondEnd = Calendar.current.date(bySettingHour: 13, minute: 00, second: 0, of: monday)!
		
		var thursday = Date()
		while (thursday.dayOfWeek() != Day.thursday.rawValue) {
			var dateComponents = DateComponents()
			dateComponents.day = 1
			thursday = gregorian.date(byAdding: dateComponents, to: thursday)!
		}
		
		let thirdStart = Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: thursday)!
		let thirdEnd = Calendar.current.date(bySettingHour: 11, minute: 46, second: 0, of: thursday)!
		
		return [ClosedDateRange(startDate: firstStart, endDate: firstEnd),
				ClosedDateRange(startDate: secondStart, endDate: secondEnd),
				ClosedDateRange(startDate: thirdStart, endDate: thirdEnd)]
		
	}
	

	
}
