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
		
		let monday = Date.nextOccurrenceOfDay(.monday)
//		let firstStart = Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: monday)!
//		let firstEnd = Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: monday)!
		
//		let secondStart = Calendar.current.date(bySettingHour: 11, minute: 00, second: 0, of: monday)!
//		let secondEnd = Calendar.current.date(bySettingHour: 13, minute: 00, second: 0, of: monday)!
		
		let thursday = Date.nextOccurrenceOfDay(.thursday)
		
		let thirdStart = Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: thursday)!
		let thirdEnd = Calendar.current.date(bySettingHour: 11, minute: 46, second: 0, of: thursday)!
//		ClosedDateRange(startDate: firstStart, endDate: firstEnd),
//		ClosedDateRange(startDate: secondStart, endDate: secondEnd),
		return [
				
				ClosedDateRange(startDate: thirdStart, endDate: thirdEnd)]
		
	}
	

	
}
