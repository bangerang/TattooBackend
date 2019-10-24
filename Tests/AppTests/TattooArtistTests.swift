//
//  TattooArtistTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-16.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

let artistStub = Artist(name: "Onur", username: "Onur2001", email: "onur@hotmail.com", password: "password")
let settingsStub: [ArtistPropertySetting] = [.position(["Elbow", "Arm", "Leg"]),
											 .color(hasColor: true),
											 .image(data: File(data: FileMock(),
															   filename: "Foo"))]

let workHours = [WorkDay(day: .monday, workhours: ClosedTimeRange(start: try! Time(hour: 8, minute: 00),
																  end: try! Time(hour: 17, minute: 00)), breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00),
																																  end: try! Time(hour: 13, minute: 00))]),
				 WorkDay(day: .tuesday, workhours: ClosedTimeRange(start: try! Time(hour: 9, minute: 00),
																   end: try! Time(hour: 18, minute: 00)), breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00),
																																   end: try! Time(hour: 13, minute: 00))]),
				 WorkDay(day: .thursday, workhours: ClosedTimeRange(start: try! Time(hour: 7, minute: 00),
																	end: try! Time(hour: 16, minute: 00)), breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00),
																																	end: try! Time(hour: 13, minute: 00))])
]



class TattooArtistTests: ModelTests<Artist> {
	
	override func getURI() -> String {
		return "/api/artists/"
	}
	override func getModel() -> Artist {
		return artistStub
	}
	
	override func didRecieveModel(_ model: Artist, testCase: TestCase) {
		switch testCase {
		case .saved:
			XCTAssertEqual(model.email, artistStub.email)
			XCTAssertEqual(model.username, artistStub.username)
			XCTAssertNotNil(model.id)
		case .retrieveOne:
			XCTAssertEqual(model.email, artistStub.email)
			XCTAssertEqual(model.username, artistStub.username)
			XCTAssertNotNil(model.id)
		case .updated:
			XCTAssertEqual(model.name, "Axel")
		default:
			XCTFail()
		}
	}
	
	override func didRecieveModel(_ models: [Artist], testCase: TestCase) {
		switch testCase {
		case .retrieveAll:
			XCTAssert(models.count == 1)
			XCTAssert(models[0].email == artistStub.email)
			XCTAssert(models[0].username == artistStub.username)
			XCTAssert(models[0].name == artistStub.name)
		default:
			XCTFail()
		}
	}
	
	override func willPerformUpdatenOn(_ model: Artist) -> Artist {
		var artistToChange = model
		artistToChange.name = "Axel"
		return artistToChange
	}
	
	func testGetSettingsFromArtist() throws {
		
		let artist = try Artist.create(model: artistStub, on: conn)
		let settingsWithoutID = ArtistSettings(artistID: artist.id!, settings: settingsStub)
		let settings = try ArtistSettings.create(model: settingsWithoutID, on: conn)
		
		let receivedSettings = try app.getResponse(to: "\(getURI())\(artist.id!)/settings", decodeTo: [ArtistSettings].self)

		XCTAssertEqual(receivedSettings[0].settings, settings.settings)
		XCTAssertEqual(receivedSettings[0].artistID, settings.artistID)
		XCTAssertNotNil(receivedSettings[0].id)
	}
	
	func testGetTimeslotsFromArtist() throws {
		let artist = try Artist.create(model: artistStub, on: conn)
		let timeSlowWithoutID = Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 60)
		_ = try Timeslot.create(model: timeSlowWithoutID, on: conn)
		
		let recievedTimeslots = try app.getResponse(to: "\(getURI())\(artist.id!)/timeslots", decodeTo: [Timeslot].self)
		
		XCTAssertEqual(recievedTimeslots[0].title, "Foo")
		XCTAssertEqual(recievedTimeslots[0].artistID, artist.id!)
		XCTAssertEqual(recievedTimeslots[0].timeInMinutes, 60)
		XCTAssertNotNil(recievedTimeslots[0].id)
	}
	
	func testGetCalenderFromArtist() throws {
		let artist = try Artist.create(model: artistStub, on: conn)
		let timeslot = try Timeslot.create(model: Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 120), on: conn)

		_ = try Workplace.create(model: Workplace(artistID: artist.id!, workDays: workHours, numberOfDaysAllowedForBooking: 365), on: conn)
		
		let recieved = try app.getResponse(to: "\(getURI())\(artist.id!)/calender/\(timeslot.id!)", decodeTo: [ClosedDateRange].self)
		let provider = CalenderProviderMock()
		let bookedEvents = provider.getEvents()
		
		var foundAtLeastOneTuesday = false
		
		for dateRange in recieved {
			if dateRange.startDate.dayOfWeek() == Day.tuesday.rawValue {
				foundAtLeastOneTuesday = true
			}
			for bookedEvent in bookedEvents {
				if bookedEvent.contains(dateRange) {
					XCTFail("Events conflict")
				}
			}
		}
		
		XCTAssertTrue(foundAtLeastOneTuesday)

	}
	
	func testCalenderShouldSuggestDatesConnectingToStartAndEndofWorkday() throws {
		let artist = try Artist.create(model: artistStub, on: conn)
		let timeslot = try Timeslot.create(model: Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 120), on: conn)

		_ = try Workplace.create(model: Workplace(artistID: artist.id!, workDays: workHours, numberOfDaysAllowedForBooking: 365), on: conn)
		
		
		let recieved = try app.getResponse(to: "\(getURI())\(artist.id!)/calender/\(timeslot.id!)", decodeTo: [ClosedDateRange].self)
		
		for dateRange in recieved {
			let workhour = workHours.first(where: {$0.day.rawValue == dateRange.startDate.dayOfWeek()})!
			let daysInDateRange = recieved.filter{$0.startDate.dayOfWeek() == workhour.day.rawValue}
			for dayInDateRange in daysInDateRange {
				let minuteStart = Calendar.current.component(.minute, from: dayInDateRange.startDate)
				let hourStart = Calendar.current.component(.hour, from: dayInDateRange.startDate)
				let minuteEnd = Calendar.current.component(.minute, from: dayInDateRange.endDate)
				let hourEnd = Calendar.current.component(.hour, from: dayInDateRange.endDate)
				let timeStart = try Time(hour: hourStart, minute: minuteStart)
				let timeEnd = try Time(hour: hourEnd, minute: minuteEnd)
				 
				let endMorning = try workhour.start.time(byAddingMinutes: timeslot.timeInMinutes)
				let isBookedInTheMorning = timeStart == workhour.start && timeEnd == endMorning
				
				let startAfternoon = try workhour.end.time(byAddingMinutes: -timeslot.timeInMinutes)
				let isBookedInTheAfternoon = timeStart == startAfternoon && timeEnd == workhour.end
				
				XCTAssertTrue(isBookedInTheMorning || isBookedInTheAfternoon)
			}
		}
	}
	

	
	func testGetTattooSizesFromArtist() throws {

		let artist = try Artist.create(model: artistStub, on: conn)
		let timeslot = try Timeslot.create(model: Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 120), on: conn)
		let bigSize = try TattooSize.create(model: TattooSize(timeslotID: timeslot.id!, artistID: artist.id!, title: "Big"), on: conn)
		let smallSize = try TattooSize.create(model: TattooSize(timeslotID: timeslot.id!, artistID: artist.id!, title: "Small"), on: conn)
		
		let recieved = try app.getResponse(to: "\(getURI())\(artist.id!)/tattoo-sizes", decodeTo: [TattooSize].self)
		
		XCTAssertTrue(recieved.count == 2)
		XCTAssertTrue(recieved[0].title == bigSize.title)
		XCTAssertTrue(recieved[0].artistID == artist.id!)
		XCTAssertTrue(recieved[0].timeslotID == timeslot.id!)
		XCTAssertTrue(recieved[1].title == smallSize.title)
		XCTAssertTrue(recieved[1].artistID == artist.id!)
		XCTAssertTrue(recieved[1].timeslotID == timeslot.id!)
	}
	
	func testMeasureYearlyEvents() {
		measure {
			_ = yearlyDatesFromCurrentDate()
		}
	}
}
