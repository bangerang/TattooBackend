//
//  BookingsTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-18.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

extension String {
	static let monday = Day.monday.rawValue
	static let tuesday = Day.tuesday.rawValue
	static let wednesday = Day.wednesday.rawValue
	static let thursday = Day.thursday.rawValue
	static let friday = Day.friday.rawValue
	static let saturday = Day.saturday.rawValue
	static let sunday = Day.sunday.rawValue
}

func createWorkhours(with workplaceID: Workplace.ID, on connection: PostgreSQLConnection) throws -> [WorkDay] {
	
	
	let monday = try WorkDay.create(model: WorkDay(day: .monday,
												   workhours: ClosedTimeRange(start: try! Time(hour: 8, minute: 00), end: try! Time(hour: 17, minute: 00)),
												   breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00), end: try! Time(hour: 13, minute: 00))],
												   workPlaceID: workplaceID),
									on: connection)
	let tuesday = try WorkDay.create(model: WorkDay(day: .tuesday,
													workhours: ClosedTimeRange(start: try! Time(hour: 9, minute: 00), end: try! Time(hour: 18, minute: 00)),
													breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00), end: try! Time(hour: 13, minute: 00))],
													workPlaceID: workplaceID),
									 on: connection)
	let thursday = try WorkDay.create(model: WorkDay(day: .thursday,
													 workhours: ClosedTimeRange(start: try! Time(hour: 7, minute: 00),
													 end: try! Time(hour: 16, minute: 00)), breaks: [ClosedTimeRange(start: try! Time(hour: 12, minute: 00),end: try! Time(hour: 13, minute: 00))],
													 workPlaceID: workplaceID),
									  on: connection)
	
	
	return [monday, tuesday, thursday]
	
}

class BookingsTests: ModelTests<Booking> {
	
	let testDate = Date()
	
	lazy var artist: Artist = {
		return try! Artist.create(model: artistStub, on: self.conn)
	}()
	
	lazy var customer: Customer = {
		return try! Customer.create(model: customerStub, on: self.conn)
	}()
	
	lazy var bookingStub: Booking = {
		return Booking(pickedSettings: settingsStub, state: .initial, artistID: artist.id!, customerID: customer.id!)
	}()
	
	var mockData: (artist: Artist, customer: Customer, timeslot: Timeslot, booking: Booking) {
		let artist = try! Artist.create(model: artistStub, on: conn)
		let customer = try! Customer.create(model: customerStub, on: conn)
		let timeslot = try! Timeslot.create(model: Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 120), on: conn)
		let date = Date()
		let bookingStub1 = Booking(pickedSettings: settingsStub, state: .booked, timeSlotID: timeslot.id!, startDate: date, artistID: artist.id!, customerID: customer.id!)
		return (artist, customer, timeslot, bookingStub1)
	}
	
	override func getURI() -> String {
		return "/api/artists/bookings/"
	}
	override func getModel() -> Booking {
		return bookingStub
	}
	override func didRecieveModel(_ model: Booking, testCase: TestCase) {
		switch testCase {
		case .saved:
			XCTAssertEqual(model.artistID, artist.id!)
			XCTAssertEqual(model.customerID, customer.id!)
			XCTAssertEqual(model.pickedSettings, settingsStub)
			XCTAssertNotNil(model.id)
		case .retrieveOne:
			XCTAssertEqual(model.artistID, artist.id!)
			XCTAssertEqual(model.customerID, customer.id!)
			XCTAssertEqual(model.pickedSettings, settingsStub)
			XCTAssertNotNil(model.id)
		case .updated:
			if case .requested = model.state {
				let receivedDateTimeInterval = model.startDate!.timeIntervalSinceReferenceDate
				let expectedDateTimeInterval = testDate.timeIntervalSinceReferenceDate
				XCTAssertEqual(receivedDateTimeInterval, expectedDateTimeInterval, accuracy: 1)
				break
			}
			XCTFail()
		default:
			XCTFail()
		}
	}
	override func didRecieveModel(_ models: [Booking], testCase: TestCase) {
		switch testCase {
		case .retrieveAll:
			XCTAssert(models.count == 1)
			XCTAssertEqual(models[0].artistID, artist.id!)
			XCTAssertEqual(models[0].customerID, customer.id!)
			XCTAssertEqual(models[0].pickedSettings, settingsStub)
		default:
			XCTFail()
		}
	}
	override func willPerformUpdatenOn(_ model: Booking) -> Booking {
		var bookingToUpdate = model
		bookingToUpdate.state = .requested
		bookingToUpdate.startDate = testDate
		return bookingToUpdate
	}
	
	
	func testMakeSureYouCantBookSameDate() throws {
		
		let models = mockData
		
		_ = try Booking.create(model: models.booking, on: conn)
		
		XCTAssertThrowsError(try app.getResponse(
			to: getURI(),
			method: .POST,
			headers: ["Content-Type": "application/json"],
			data: models.booking,
			decodeTo: Booking.self)
		)
		
		let recieved = try app.getResponse(to: "/api/artists/\(models.artist.id!)/bookings", decodeTo: [Booking].self)
		
		XCTAssertTrue(recieved.count == 1)
		
	}
	
	func testMakeSureYouCantBookDateThatEndsWithinAnother() throws {
		
		var models = mockData
		
		_ = try Booking.create(model: models.booking, on: conn)
		
		models.booking.startDate! = models.booking.startDate!.addingTimeInterval(-(60*60))
		XCTAssertThrowsError(try app.getResponse(
			to: getURI(),
			method: .POST,
			headers: ["Content-Type": "application/json"],
			data: models.booking,
			decodeTo: Booking.self)
		)
		
		let recieved = try app.getResponse(to: "/api/artists/\(models.artist.id!)/bookings", decodeTo: [Booking].self)
		
		XCTAssertTrue(recieved.count == 1)
	}
	
	func testBookDateAfterMorningBooking() throws {
		
		var models = mockData
		
		let timeslot = try! Timeslot.create(model: Timeslot(artistID: artist.id!, title: "Foo", timeInMinutes: 120), on: conn)
		models.booking.timeSlotID = timeslot.id!
		
		
		let workplace = try Workplace.create(model: Workplace(artistID: artist.id!, numberOfDaysAllowedForBooking: 365), on: conn)
		
		_ = try createWorkhours(with: workplace.id!, on: self.conn)
		
		let monday = try workplace.workDays.query(on: self.conn).all().wait().first{$0.day == .monday}!
		
		let startDate = Calendar.current.date(bySettingHour: monday.start.hour, minute: monday.start.minute, second: 0, of: Date.nextOccurrenceOfDay(.monday))!
		
		models.booking.startDate = startDate
		
		_ = try Booking.create(model: models.booking, on: conn)
		
		models.booking.startDate! = startDate.addingTimeInterval(TimeInterval(models.timeslot.timeInMinutes * 60))
		
		XCTAssertNoThrow(try app.getResponse(
			to: getURI(),
			method: .POST,
			headers: ["Content-Type": "application/json"],
			data: models.booking,
			decodeTo: Booking.self)
		)
		
		let recieved = try app.getResponse(to: "/api/artists/\(models.artist.id!)/bookings", decodeTo: [Booking].self)
		
		XCTAssertTrue(recieved.count == 2)
	}
	
	func testShouldGetSuggestionAboutEventAfterMorningBooking() throws {
		
		var models = mockData
		
		let timeslot = try! Timeslot.create(model: Timeslot(artistID: models.artist.id!, title: "Foo", timeInMinutes: 120), on: conn)
		models.booking.timeSlotID = timeslot.id!
		
		let workplace = try Workplace.create(model: Workplace(artistID: models.artist.id!, numberOfDaysAllowedForBooking: 365), on: conn)
		
		_ = try createWorkhours(with: workplace.id!, on: self.conn)
		
		let monday = try workplace.workDays.query(on: self.conn).all().wait().first{$0.day == .monday}!
		
		let startDate = Calendar.current.date(bySettingHour: monday.start.hour, minute: monday.start.minute, second: 0, of: Date.nextOccurrenceOfDay(.monday))!
		
		let dateToFind = startDate.addingTimeInterval(TimeInterval(models.timeslot.timeInMinutes * 60))
		
		models.booking.startDate = startDate
		
		_ = try Booking.create(model: models.booking, on: conn)
		
		let recieved = try app.getResponse(to: "/api/artists/\(models.artist.id!)/calender/\(timeslot.id!)", decodeTo: [ClosedDateRange].self)
		
		let dateRange = recieved.first{ $0.startDate == dateToFind }
		XCTAssertNotNil(dateRange)
		XCTAssertEqual(dateToFind.addingTimeInterval(TimeInterval(models.timeslot.timeInMinutes * 60)).timeIntervalSinceReferenceDate, dateRange!.endDate.timeIntervalSinceReferenceDate, accuracy: 1)
		
		let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: dateToFind)
		XCTAssertTrue(recieved.filter { dateRange -> Bool in
			let components = Calendar.current.dateComponents([.year, .month, .day], from: dateRange.startDate)
			return dateComponent == components
		}.count == 1)
		
	}
	
	func testShouldGetSuggestionAboutEventBeforeAfternoonBooking() throws {
		var models = mockData
		
		let timeslot = try! Timeslot.create(model: Timeslot(artistID: models.artist.id!, title: "Foo", timeInMinutes: 120), on: conn)
		models.booking.timeSlotID = timeslot.id!
		
		let workplace = try Workplace.create(model: Workplace(artistID: models.artist.id!, numberOfDaysAllowedForBooking: 365), on: conn)
		
		_ = try createWorkhours(with: workplace.id!, on: self.conn)
		
		let monday = try workplace.workDays.query(on: self.conn).all().wait().first{$0.day == .monday}!
		
		let start = try monday.end.time(byAddingMinutes: -models.timeslot.timeInMinutes)
		
		let startDate = Calendar.current.date(bySettingHour: start.hour, minute: start.minute, second: 0, of: Date.nextOccurrenceOfDay(.monday))!
		
		let dateToFind = startDate.addingTimeInterval(-TimeInterval(models.timeslot.timeInMinutes * 60))
		
		models.booking.startDate = startDate
		
		_ = try Booking.create(model: models.booking, on: conn)
		
		let recieved = try app.getResponse(to: "/api/artists/\(models.artist.id!)/calender/\(timeslot.id!)", decodeTo: [ClosedDateRange].self)
		recieved.forEach{print($0.startDate)}
		let dateRange = recieved.first{ $0.startDate == dateToFind }
		XCTAssertNotNil(dateRange)
		XCTAssertEqual(dateToFind.addingTimeInterval(TimeInterval(models.timeslot.timeInMinutes * 60)).timeIntervalSinceReferenceDate, dateRange!.endDate.timeIntervalSinceReferenceDate, accuracy: 1)
		
		let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: dateToFind)
		XCTAssertTrue(recieved.filter { dateRange -> Bool in
			let components = Calendar.current.dateComponents([.year, .month, .day], from: dateRange.startDate)
			return dateComponent == components
		}.count == 1)
	}
}
