//
//  CustomerTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-17.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

let customerStub = Customer(email: "foo@hotmail.com")
class CustomerTests: XCTestCase {

	var app: Application!
	var conn: PostgreSQLConnection!
	let customersURI = "/api/customers/"
	var test = ModelTests()

	var customer: Customer!
	
	override func setUp() {
		try! Application.reset()
		app = try! Application.testable()
		conn = try! app.newConnection(to: .psql).wait()
		customer = try! Customer.create(model: customerStub, on: conn)
		test.invokeTest()
	}
	
	override func tearDown() {
		conn.close()
		try? app.syncShutdownGracefully()
	}
	
	func testCustomertCanBeRetrievedByAPI() throws {
		
		let receivedCustomers = try app.getResponse(to: customersURI, decodeTo: [Customer].self)
		
		XCTAssert(receivedCustomers.count == 1)
		XCTAssert(receivedCustomers[0].email == customer.email)
		
	}

    func testTattooArtistCanBeSavedbyAPI() throws {
		
		let receivedCustomer = try app.getResponse(
		  to: customersURI,
		  method: .POST,
		  headers: ["Content-Type": "application/json"],
		  data: customer,
		  decodeTo: Customer.self)
		
		XCTAssertEqual(receivedCustomer.email, customer.email)
		XCTAssertNotNil(receivedCustomer.id)
		
		let allCustomers = try app.getResponse(to: customersURI, decodeTo: [Customer].self)
		
		XCTAssert(allCustomers.count == 1)
		XCTAssert(allCustomers[0].email == customer.email)
    }
	
	func testGettingASingleArtistSettingFromAPI() throws {
		
		let receivedCustomer = try app.getResponse(to: "\(customersURI)\(customer.id!)", decodeTo: Customer.self)
		
		XCTAssertEqual(receivedCustomer.email, customer.email)
		XCTAssertNotNil(receivedCustomer.id)
		
	}
	
}
