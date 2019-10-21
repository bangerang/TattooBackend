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

class BookingsTests: ModelTests<Booking> {

	let testDate = Date()
	
	lazy var artist: Artist = {
		return try! Artist.create(model: artistStub, on: self.conn)
	}()
	
	lazy var customer: Customer = {
		return try! Customer.create(model: customerStub, on: self.conn)
	}()
	
	
	lazy var bookingStub: Booking = {
		let booking = Booking(pickedSettings: settingsStub, state: .initial(true), artistID: artist.id!, customerID: customer.id!)
		return booking
	}()
	
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
			if case let .requested(date) = model.state {
			let receivedDateTimeInterval = date.timeIntervalSinceReferenceDate
			let expectedDateTimeInterval = testDate.timeIntervalSinceReferenceDate
			XCTAssertEqual(receivedDateTimeInterval, expectedDateTimeInterval, accuracy: 0.1)
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
		bookingToUpdate.state = .requested(testDate)
		return bookingToUpdate
	}
}
