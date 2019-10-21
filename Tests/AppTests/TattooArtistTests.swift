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
											 .size(["Big", "Small"]),
											 .color(hasColor: true),
											 .image(data: File(data: FileMock(),
															   filename: "Foo"))]

let workHours = [WorkHour(day: .monday,
						  start: try! Time(hour: 8, minute: 00),
						  end: try! Time(hour: 16, minute: 00)),
				 WorkHour(day: .tuesday,
						  start: try! Time(hour: 9, minute: 00),
						  end: try! Time(hour: 18, minute: 00)),
				 WorkHour(day: .thursday,
						  start: try! Time(hour: 7, minute: 00),
						  end: try! Time(hour: 16, minute: 00)),
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

		_ = try Workplace.create(model: Workplace(artistID: artist.id!, workHours: workHours, numberOfDaysAllowedForBooking: 365), on: conn)
		
		let recieved = try app.getResponse(to: "\(getURI())\(artist.id!)/calender/\(timeslot.id!)", decodeTo: [ClosedDateRange].self)
		let provider = CalenderProviderMock()
		let bookedEvents = provider.getEvents()
		
		var tuesday = Date()
		let gregorian:NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
		while (tuesday.dayOfWeek() != Day.tuesday.rawValue) {
			var dateComponents = DateComponents()
			dateComponents.day = 1
			tuesday = gregorian.date(byAdding: dateComponents, to: tuesday)!
		}
		
		var foundAtLeastOneTuesday = false
		
		for dateRange in recieved {
			if dateRange.startDate.dayOfWeek() == Day.tuesday.rawValue {
				foundAtLeastOneTuesday = true
			}
			for bookedEvent in bookedEvents {
				if bookedEvent.startDate.isBetweenDates(beginDate: dateRange.startDate, endDate: dateRange.endDate) || bookedEvent.endDate.isBetweenDates(beginDate: dateRange.startDate, endDate: dateRange.endDate) {
					XCTFail("Events conflict")
				}
			}
		}
		
		XCTAssertTrue(foundAtLeastOneTuesday)
		XCTAssertTrue(recieved.count > 100)

	}
}
